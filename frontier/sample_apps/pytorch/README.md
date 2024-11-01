# Pytorch MNIST example using DistributedDataParallel

Example borrowed from: [PrincetonUniversity/multi_gpu_training](https://github.com/PrincetonUniversity/multi_gpu_training/tree/main)

to build container:
```
apptainer build pytorch.sif pytorch.def
```

Download the MNIST dataset first before submitting the job:
```
./downloadmnist.sh
```

Submit the job with: 
```
sbatch submit.sbatch
```
