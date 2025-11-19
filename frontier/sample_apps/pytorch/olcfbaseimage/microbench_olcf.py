#microbench_olcf.py
import torch
import torchvision
import time
import argparse
import os
import copy
import csv



def forwardbackward(inp, optimizer, network, target, step=0, opt_step=1):
    if step % opt_step == 0:
        optimizer.zero_grad()

    out = network(inp)
    # If using HuggingFace model outputs logits, we need to extract them
    if hasattr(out, 'logits'):
        logits = out.logits
    else:
        logits = out
    loss_fn = torch.nn.CrossEntropyLoss().to(device="cuda")

    loss = loss_fn(logits, target)

    loss.backward()
    if (step + 1) % opt_step == 0:
        optimizer.step()
        optimizer.zero_grad()


def run_benchmarking(local_rank, global_rank, world_size, params):
    batch_size = params.batch_size
    iterations = params.iterations

    net = torchvision.models.resnet50
    network = net().to(device="cuda")

    param_copy = network.parameters()

    ## MLPerf Setting
    sgd_opt_base_learning_rate = 0.01
    sgd_opt_weight_decay = 0.0001
    sgd_opt_momentum = 0.9

    optimizer = torch.optim.SGD(param_copy, lr = sgd_opt_base_learning_rate, momentum = sgd_opt_momentum, weight_decay=sgd_opt_weight_decay)

    devices_to_run_on = [local_rank]
    print (f"Rank {global_rank} running on device: {devices_to_run_on}")
    network = torch.nn.parallel.DistributedDataParallel(network, device_ids=devices_to_run_on)
    batch_size = int(batch_size / world_size)

    inp = torch.randn(batch_size, 3, 224, 224, device="cuda")

    # number of classes is 1000 for imagenet
    target = torch.randint(0, 1000, (batch_size,), device="cuda")

    forward_fn = forwardbackward
    network.train()

    ## warmup.
    if global_rank == 0:
        print (f"running forward and backward for warmup.")
    for i in range(2):
        forward_fn(inp, optimizer, network, target, step=0, opt_step=args.opt_step)

    time.sleep(1)
    torch.cuda.synchronize()

    ## benchmark.
    if global_rank == 0:
        print (f"running the benchmark..")

    tm = time.time()
    with torch.autograd.profiler.emit_nvtx(enabled=False):
        for i in range(iterations):
            forward_fn(inp, optimizer, network, target, step=i, opt_step=args.opt_step)
    torch.cuda.synchronize()

    tm2 = time.time()
    time_per_batch = (tm2 - tm) / iterations
    throughput = batch_size / time_per_batch

    dtype = 'FP32'

    result = None
    if not args.output_dir:
        args.output_dir = "."

    print (f"Rank {global_rank} finished: Mini batch size: {batch_size}, Throughput: {throughput}, Time per mini-batch: {time_per_batch}")

    #min_time = comm.reduce(time_per_batch,op=MPI.MIN, root=0)
    #max_time = comm.reduce(time_per_batch,op=MPI.MAX, root=0)
    #avg_time = comm.reduce(time_per_batch,op=MPI.SUM, root=0) # prep for avg later
    #tot_thru = comm.reduce(throughput,op=MPI.SUM, root=0)

    time_per_batch = torch.tensor([time_per_batch], dtype=torch.float32, device='cuda')
    min_time = time_per_batch.clone().detach()
    max_time = time_per_batch.clone().detach()
    avg_time = time_per_batch.clone().detach()
    throughput = torch.tensor([throughput], dtype=torch.float32, device='cuda')
    tot_thru = throughput.clone().detach()
    torch.distributed.reduce(min_time, dst=0, op=torch.distributed.ReduceOp.MIN)
    torch.distributed.reduce(max_time, dst=0, op=torch.distributed.ReduceOp.MAX)
    torch.distributed.reduce(avg_time, dst=0, op=torch.distributed.ReduceOp.SUM)
    torch.distributed.reduce(throughput, dst=0, op=torch.distributed.ReduceOp.SUM)

    time.sleep(3)
    if global_rank == 0:
        print ("")
        print ("--------Overall Summary--------")
        print (f"Num devices: {world_size}")
        print (f"Dtype: {dtype}")
        print (f"Mini batch size [img] : {batch_size*world_size}")
        print (f"Mini batch size [img/gpu] : {batch_size}")
        print (f"Total Throughput [img/sec] : {tot_thru.item()}")
        print (f"Time per mini-batch [sec] : Min: {min_time.item()}, Max: {max_time.item()}, Avg: {avg_time.item()/world_size}")
        result = {
            "GPUs": world_size,
            "Mini batch size [img]": batch_size * world_size,
            "Mini batch size [img/gpu]": batch_size,
            "Total Throughput [img/sec]": tot_thru,
            "Min Time [sec]": min_time,
            "Max Time [sec]": max_time,
            "Avg Time [sec]": avg_time/world_size
        }

    csv_filename = f"{args.output_dir}/benchmark_summary.csv"
    file_exists = os.path.isfile(csv_filename)
    if result:
        with open(csv_filename, "a", newline='') as csvfile:
            writer = csv.writer(csvfile)
            if not file_exists:
                writer.writerow(result.keys())
            writer.writerow(result.values())
        print(f"Benchmark result saved to {csv_filename}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch-size" , type=int, required=False, default=64, help="Batch size (will be split among devices used by this invocation)")
    parser.add_argument("--iterations", type=int, required=False, default=20, help="Iterations")
    parser.add_argument("--opt-step", type=int, required=False, default=1, help="Optimizer update step")
    parser.add_argument("--output-dir", type=str, default="", help="assign output directory name.")
    parser.add_argument("--master_addr", type=str, required=True)
    parser.add_argument("--master_port", type=str, required=True)

    args = parser.parse_args()

    num_gpus_per_rank = torch.cuda.device_count()

    world_size = int(os.environ["SLURM_NTASKS"])
    global_rank = rank = int(os.environ["SLURM_PROCID"])
    local_rank = int(rank) % int(num_gpus_per_rank) # local_rank and device are 0 when using 1 GPU per task
    backend = None
    os.environ['WORLD_SIZE'] = str(world_size)
    os.environ['RANK'] = str(global_rank)
    os.environ['LOCAL_RANK'] = str(local_rank)
    os.environ['MASTER_ADDR'] = str(args.master_addr)
    os.environ['MASTER_PORT'] = str(args.master_port)
    os.environ['NCCL_SOCKET_IFNAME'] = 'hsn0'

    torch.distributed.init_process_group(
        backend="nccl",
        #init_method=f"tcp://{args.master_addr}:{args.master_port}",
        init_method='env://',
        rank=global_rank,
        world_size=world_size,
    )

    print (f"Rank {global_rank} GPUs Visible: {num_gpus_per_rank}", flush=True)

    torch.cuda.set_device(local_rank) # local_rank and device are 0 when using 1 GPU per task

    run_benchmarking(local_rank,global_rank,world_size,copy.deepcopy(args))

    torch.distributed.destroy_process_group()
