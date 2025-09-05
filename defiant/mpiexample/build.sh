#!/bin/bash

apptainer build rocky9opensusempich412nvidia2411.sif rocky9opensusempich412nvidia2411.def
apptainer build mpiexample.sif mpiexample.def
