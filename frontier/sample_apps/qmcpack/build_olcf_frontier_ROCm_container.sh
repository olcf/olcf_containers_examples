#!/bin/bash

# Build script for Frontier
# It builds all the varaints of QMCPACK in the current directory
# last revision: Aug 19th 2024

echo "Loading QMCPACK dependency modules for frontier"
#for module_name in PrgEnv-gnu PrgEnv-cray PrgEnv-amd PrgEnv-gnu-amd PrgEnv-cray-amd \
#                   amd amd-mixed gcc gcc-mixed gcc-native cce cce-mixed rocm
#do
#  if module is-loaded $module_name ; then module unload $module_name; fi
#done
#
#module load PrgEnv-amd amd/6.0.0
#module unload darshan-runtime
unset HIP_PATH # it messed up clang as a HIP compiler.
#module unload cray-libsci
#module load cmake/3.22.2
#module load cray-fftw
#module load openblas/0.3.17-omp
#module load cray-hdf5-parallel
#
## edit this line if you are not a member of mat151
#export BOOST_ROOT=/ccs/proj/mat151/opt/boost/boost_1_81_0

#module list >& module_list.txt

TYPE=Release
Compiler=rocm600

if [[ $# -eq 0 ]]; then
  source_folder=`pwd`
elif [[ $# -eq 1 ]]; then
  source_folder=$1
else
  source_folder=$1
  install_folder=$2
fi

if [[ -f $source_folder/CMakeLists.txt ]]; then
  echo Using QMCPACK source directory $source_folder
else
  echo "Source directory $source_folder doesn't contain CMakeLists.txt. Pass QMCPACK source directory as the first argument."
  exit
fi

#for name in offload_cuda2hip_real_MP offload_cuda2hip_real offload_cuda2hip_cplx_MP offload_cuda2hip_cplx
# cpu_real_MP cpu_real cpu_cplx_MP cpu_cplx

for name in  offload_cuda2hip_real  
do

#CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=$TYPE -DMPIEXEC_EXECUTABLE=`which srun`"
CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=$TYPE"

if [[ $name == *"cplx"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DQMC_COMPLEX=ON"
fi

if [[ $name == *"_MP"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DQMC_MIXED_PRECISION=ON"
fi

if [[ $name == *"offload"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DENABLE_OFFLOAD=ON"
fi

if [[ $name == *"cuda2hip"* ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DENABLE_CUDA=ON -DQMC_CUDA2HIP=ON -DCMAKE_HIP_ARCHITECTURES=gfx90a"
fi

folder=build_frontier_${Compiler}_${name}

if [[ -v install_folder ]]; then
  CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_INSTALL_PREFIX=$install_folder/$folder"
fi

export ROCM_PATH=/opt/rocm
#CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_CXX_FLAGS='-std=c++11 -D__HIP_ROCclr__ -D__HIP_ARCH_GFX90A__=1 --rocm-path=${ROCM_PATH} --offload-arch=gfx90a -x hip -L${ROCM_PATH}/lib -lamdhip64' -DCMAKE_C_FLAGS='-std=c++11 -D__HIP_ROCclr__ -D__HIP_ARCH_GFX90A__=1 --rocm-path=${ROCM_PATH} --offload-arch=gfx90a -x hip -L${ROCM_PATH}/lib -lamdhip64' "
#CMAKE_FLAGS="$CMAKE_FLAGS -DCMAKE_C_FLAGS='-fopenmp' -DCMAKE_CXX_FLAGS='-fopenmp'"
CMAKE_FLAGS="$CMAKE_FLAGS -DROCM_ROOT=$ROCM_PATH" 
echo "**********************************"
echo "$folder"
echo "$CMAKE_FLAGS"
echo "**********************************"
mkdir $folder
cd $folder
if [ ! -f CMakeCache.txt ] ; then
cmake $CMAKE_FLAGS -DCMAKE_C_COMPILER=amdclang -DCMAKE_CXX_COMPILER=amdclang++  $source_folder
#cmake $CMAKE_FLAGS -DCMAKE_C_COMPILER=hipcc -DCMAKE_CXX_COMPILER=hipcc $source_folder
#cmake $CMAKE_FLAGS -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++  $source_folder
#cmake $CMAKE_FLAGS -DCMAKE_C_COMPILER=/opt/rocm/llvm/bin/clang -DCMAKE_CXX_COMPILER=/opt/rocm/llvm/bin/clang++  $source_folder
fi

if [[ -v install_folder ]]; then
  make -j16 install && chmod -R -w $install_folder/$folder
else
  make -j16
fi

cd ..

echo
done
