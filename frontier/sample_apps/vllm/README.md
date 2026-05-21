# vLLM example running gemma-4-31B-it 

Example showing how to get download AMD's vLLM container release and run it on Frontier

Download the vLLM container from DockerHub using the included build spec:
```
apptainer build vllm_rocm.sif vllm_rocm.def
```

Download the gemma-4 model
```
module load git-lfs
git lfs install
git clone https://huggingface.co/google/gemma-4-31B-it
```

If you plan on moving the model to the burst buffer first, then tar the model directory
```
tar --use-compress-program="pigz -p 16" -cf gemma-4-31B-it.tar.gz ./gemma-4-31B-it/
```



Submit the job with
```
# running the model directly from Lustre
sbatch launchmultinode_lustre.sbatch

# copying the model to burst buffer first before running
sbatch launchmultinode_bb.sbatch
```
