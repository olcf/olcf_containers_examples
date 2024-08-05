If you want to run the RCCL tests with the [aws-ofi-rccl plugin](https://github.com/ROCm/aws-ofi-rccl),
 run the `./awsofircclbuild.sh` script to build aws-ofi-rccl first. 

All aws-ofi-rccl requires to make it usable to RCCL programs 
is to make sure that its `lib` directory is added to the 
`LD_LIBRARY_PATH` environment variable. We add it to the `APPTAINERENV_LD_LIBRARY_PATH`
variable in this example to update the `LD_LIBRARY_PATH` variable inside
the container.

For more information on the use of the aws-ofi-rccl plugin, see the [slides](https://www.olcf.ornl.gov/wp-content/uploads/OLCF_AI_Training_0417_2024.pdf) 
and [recording](https://vimeo.com/938233665)
from the [OLCF AI Training Series event](https://www.olcf.ornl.gov/calendar/pytorch-on-frontier/)
