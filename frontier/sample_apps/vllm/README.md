# vLLM example running astrollama-2-7b-base_abstract 

Example showing how to get download AMD's vLLM container release and run it on Frontier

Download the vLLM container from Dockerhub:
```
apptainer pull --disable-cache vllm_rocm.sif docker://docker.io/rocm/vllm:rocm6.3.1_vllm_0.8.5_20250513
```

Download the astrollama model
```
module load git-lfs
git lfs install
git clone https://huggingface.co/AstroMLab/astrollama-2-7b-base_abstract
```

If you plan on moving the model to the burst buffer first, then tar the model directory
```
tar --use-compress-program="pigz -p 16" -cf astrollama-2-7b-base_abstract.tar.gz ./astrollama-2-7b-base_abstract/
```



Submit the job with
```
# running the model directly from Lustre
sbatch launchmultinode_lustre.sbatch

# copying the model to burst buffer first before running
sbatch launchmultinode_bb.sbatch
```
