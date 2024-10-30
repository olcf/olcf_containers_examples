#multinode_olcf.py
import torch
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader

import torch.multiprocessing as mp
from torch.utils.data.distributed import DistributedSampler
from torch.nn.parallel import DistributedDataParallel as DDP

import torch.distributed as dist

import os


class MyTrainDataset(Dataset):
    def __init__(self, size):
        self.size = size
        self.data = [(torch.rand(20), torch.rand(1)) for _ in range(size)]

    def __len__(self):
        return self.size

    def __getitem__(self, index):
        return self.data[index]


class Trainer:
    def __init__(
        self,
        model: torch.nn.Module,
        train_data: DataLoader,
        optimizer: torch.optim.Optimizer,
        save_every: int,
        snapshot_path: str,
        local_rank: int,
        global_rank: int,

    ) -> None:
        self.local_rank = local_rank
        self.global_rank = global_rank 

        self.model = model.to(self.local_rank)
        self.train_data = train_data
        self.optimizer = optimizer
        self.save_every = save_every
        self.epochs_run = 0
        self.snapshot_path = snapshot_path
        if os.path.exists(snapshot_path):
            print("Loading snapshot")
            self._load_snapshot(snapshot_path)

        self.model = DDP(self.model, device_ids=[self.local_rank])

    def _load_snapshot(self, snapshot_path):
        loc = f"cuda:{self.local_rank}"
        snapshot = torch.load(snapshot_path, map_location=loc)
        self.model.load_state_dict(snapshot["MODEL_STATE"])
        self.epochs_run = snapshot["EPOCHS_RUN"]
        print(f"Resuming training from snapshot at Epoch {self.epochs_run}")

    def _run_batch(self, source, targets):
        self.optimizer.zero_grad()
        output = self.model(source)
        loss = F.cross_entropy(output, targets)
        loss.backward()
        self.optimizer.step()

    def _run_epoch(self, epoch):
        b_sz = len(next(iter(self.train_data))[0])
        print(f"[GPU{self.global_rank}] Epoch {epoch} | Batchsize: {b_sz} | Steps: {len(self.train_data)}")
        self.train_data.sampler.set_epoch(epoch)
        for source, targets in self.train_data:
            source = source.to(self.local_rank)
            targets = targets.to(self.local_rank)
            self._run_batch(source, targets)

    def _save_snapshot(self, epoch):
        snapshot = {
            "MODEL_STATE": self.model.module.state_dict(),
            "EPOCHS_RUN": epoch,
        }
        torch.save(snapshot, self.snapshot_path)
        print(f"Epoch {epoch} | Training snapshot saved at {self.snapshot_path}")

    def train(self, max_epochs: int):
        for epoch in range(self.epochs_run, max_epochs):
            self._run_epoch(epoch)
            if self.local_rank == 0 and epoch % self.save_every == 0:
                self._save_snapshot(epoch)


def load_train_objs():
    train_set = MyTrainDataset(2048)  # load your dataset
    model = torch.nn.Linear(20, 1)  # load your model
    optimizer = torch.optim.SGD(model.parameters(), lr=1e-3)
    return train_set, model, optimizer


def prepare_dataloader(dataset: Dataset, batch_size: int):
    return DataLoader(
        dataset,
        batch_size=batch_size,
        pin_memory=True,
        shuffle=False,
        sampler=DistributedSampler(dataset)
    )


def main(save_every: int, total_epochs: int, batch_size: int, local_rank: int, world_rank: int, snapshot_path: str = "snapshot.pt"):
    dataset, model, optimizer = load_train_objs()
    train_data = prepare_dataloader(dataset, batch_size)

    trainer = Trainer(model, train_data, optimizer, save_every, snapshot_path, local_rank, global_rank)

    trainer.train(total_epochs)

    dist.destroy_process_group()


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='simple distributed training job')
    parser.add_argument('total_epochs', type=int, help='Total epochs to train the model')
    parser.add_argument('save_every', type=int, help='How often to save a snapshot')
    parser.add_argument('--batch_size', default=32, type=int, help='Input batch size on each device (default: 32)')
    parser.add_argument("--master_addr", type=str, required=True)
    parser.add_argument("--master_port", type=str, required=True)

    args = parser.parse_args()

    num_gpus_per_node = torch.cuda.device_count()
    print ("num_gpus_per_node = " + str(num_gpus_per_node), flush=True)

    from mpi4py import MPI
    import os
    comm = MPI.COMM_WORLD
    world_size = comm.Get_size()
    global_rank = rank = comm.Get_rank()
    local_rank = int(rank) % int(num_gpus_per_node) # local_rank and device are 0 when using 1 GPU per task
    backend = None
    os.environ['WORLD_SIZE'] = str(world_size)
    os.environ['RANK'] = str(global_rank)
    os.environ['LOCAL_RANK'] = str(local_rank)
    os.environ['MASTER_ADDR'] = str(args.master_addr)
    os.environ['MASTER_PORT'] = str(args.master_port)
    os.environ['NCCL_SOCKET_IFNAME'] = 'hsn0'

    dist.init_process_group(
        backend="nccl",
        #init_method="tcp://{}:{}".format(args.master_addr, args.master_port),
        init_method='env://',
        rank=rank,
        world_size=world_size,
    )

    torch.cuda.set_device(local_rank)

    main(args.save_every, args.total_epochs, args.batch_size, local_rank, global_rank)
