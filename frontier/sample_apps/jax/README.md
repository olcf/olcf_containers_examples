# JAX MNIST example

Pull the latest Jax container from the official ROCm container registry
```
apptainer pull jax_latest.sif docker://rocm/jax-community:latest
```
The MNIST test has already been downloaded and located in the examples folder here.

Proceed to submit the job with:
```
sbatch submit.sbatch
```
