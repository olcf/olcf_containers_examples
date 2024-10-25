#!/bin/bash

apptainer build qmcpackbase.sif qmcpackbase.def
apptainer build qmcpack.sif qmcpack.def
