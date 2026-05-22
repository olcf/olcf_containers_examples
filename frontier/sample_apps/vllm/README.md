# vLLM multi-node example running gemma-4-31B-it and/or gpt-oss-120b

Example showing how to build from vLLM's ROCm container release and run it on Frontier

## Build the image

Build the vLLM container from DockerHub using the included build spec, which includes `ray`:
```
apptainer build vllm_rocm.sif vllm_rocm.def
```

## Download the model

### `gemma-4-31B-it`
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

### `gpt-oss-120b`
Download the GPT-OSS model
```
module load git-lfs
git lfs install
git clone https://huggingface.co/openai/gpt-oss-120b
```

If you plan on moving the model to the burst buffer first, then tar the model directory
```
tar --use-compress-program="pigz -p 16" -cf gpt-oss-120b.tar.gz ./gpt-oss-120b/
```

[!NOTE]
`gpt-oss-120b` requires an additional step from login nodes.
Please additionally run the following commands to fetch the vocab file:
```bash
mkdir vocab_cache
TIKTOKEN_RS_CACHE_DIR=./vocab_cache apptainer exec vllm_rocm.sif python -c 'from openai_harmony import load_harmony_encoding; load_harmony_encoding("HarmonyGptOss")'
```

## Run inference
Submit the job with
```
# running the model directly from Lustre
sbatch launchmultinode_lustre.sbatch

# copying the model to burst buffer first before running
sbatch launchmultinode_bb.sbatch
```
