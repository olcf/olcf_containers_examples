# Tensorflow MNIST example

Pull the latest Tensorflow container from the official ROCm container registry
```
apptainer pull tensorflow_latest.sif docker://rocm/tensorflow:latest
```

Submit the job with:
```
sbatch submit.sbatch
```
