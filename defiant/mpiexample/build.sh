#!/bin/bash

apptainer build rocky9mpich412nvidia2411.sif rocky9mpich412nvidia2411.def
apptainer build mpiexample.sif mpiexample.def
