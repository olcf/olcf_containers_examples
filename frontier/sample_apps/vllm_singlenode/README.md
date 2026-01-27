# vLLM single node inference example

This example starts a vLLM server with a container, and then queries the running
server with a Python script.

Current versions of vLLM don't seem to work well for multinode inference with vLLM, so sticking to single node inference is recommended for now. 


Build the Apptainer container with 

```
apptainer build vllm0141rocm72.sif vllm0141rocm72.def
```

Download the gpt-oss-20b modele
```
module load git-lfs
git lfs install
git clone https://huggingface.co/openai/gpt-oss-20b
```


Submit the job with
```
sbatch launchsinglenode_lustre.sbatch
```

The script launches the vLLM inference server with srun in the background, and then
runs a Python client that continuously checks if the server is ready and if it is, will 
send the server a prompt and receive a response. The job exits once the Python client gets
the response from the server.

You can find the output in the `logs` directory. The `vllmsingle_$SLURMJOBID.out` 
contains the debug output for the vLLM inference server. The `inference_output_$SLURM_JOBID.out`
file contains the Python client output.
