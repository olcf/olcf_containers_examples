# Pytorch MNIST example using DistributedDataParallel

Pytorch examples borrowed from: [PrincetonUniversity/multi_gpu_training](https://github.com/PrincetonUniversity/multi_gpu_training/tree/main)
and from the OLCF docs.

To switch between running the two available examples `./multinode_olcf_mnist_princeton_nompi4py.py`
and `./microbench_olcf.py`, uncomment the appropriate line in the `pyrun.sh`.

To build container:
```
apptainer build pytorch.sif pytorch.def
```

This builds a container based on OLCF's base images (see [here](https://docs.olcf.ornl.gov/software/containers_on_frontier.html#olcf-base-images-apptainer-modules) for info about
the base images) and installs Pytorch in them.

Download the MNIST dataset first before submitting the job:
```
./downloadmnist.sh
```

Submit the job with: 
```
sbatch submit.sbatch
```

