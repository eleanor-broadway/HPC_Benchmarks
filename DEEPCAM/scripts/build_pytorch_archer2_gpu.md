# Building PyTorch from source on ARCHER2 


```bash
export PREFIX=/work/z19/z19/eleanorb

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ./Miniconda3-latest-Linux-x86_64.sh
#When installing make sure you install miniconda in the correct PREFIX
#Make sure that miniconda is install in /work not /home

# conda env list 
# conda remove --name rocm-torch --all

eval "$($PREFIX/miniconda3/bin/conda shell.bash hook)"
conda create --name mlperf-torch-amd python=3.10
```

# Download Torch
```bash
git clone --single-branch --branch release/2.0 https://github.com/pytorch/pytorch.git
mv pytorch pytorch-2.0 && cd pytorch-2.0 
git submodule sync
git submodule update --init --recursive
```

# Fix: https://github.com/ROCm/ROCm/issues/2121
```bash 
Add ncurses to the tail of the CAFFE2 dependancies list in cmake/Dependancies.cmake. 
```


# Install dependencies
```bash
source $PREFIX/miniconda3/bin/activate mlperf-torch-amd
conda install cmake ninja
cd ./pytorch
pip install -r requirements.txt
conda install mkl mkl-include
conda install anaconda::ncurses
conda install -c conda-forge ncurses

pip install pytorch-triton-rocm
```

# Build Pytorch
```bash
srun --gpus=1 --time=01:00:00 --partition=gpu --qos=gpu-shd --account=[CODE] --pty /bin/bash
source $PREFIX/miniconda3/bin/activate mlperf-torch-amd
module load PrgEnv-gnu
module load rocm
module load craype-accel-amd-gfx90a
module load craype-x86-milan
cd /path/to/pytorch
export MPICH_GPU_SUPPORT_ENABLED=1
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
export LD_LIBRARY_PATH=$CRAY_MPICH_ROOTDIR/gtl/lib/:$LD_LIBRARY_PATH
export LD_PRELOAD=$CRAY_MPICH_ROOTDIR/gtl/lib/libmpi_gtl_hsa.so:$LD_PRELOAD
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
export PATH=$CONDA_PREFIX/bin:$PATH
export USE_CUDA=0
export USE_ROCM=1
export USE_DISTRIBUTED=1
export BUILD_CAFFE2=0
export BUILD_TEST=0
export PYTORCH_ROCM_ARCH=gfx90a
export BUILD_CAFFE2_OPS=0
export LDFLAGS="-L/$CONDA_PREFIX/lib -L${CRAY_MPICH_DIR}/lib ${PE_MPICH_GTL_DIR_amd_gfx90a}"
export CXXFLAGS=-I${CRAY_MPICH_DIR}/include
export LIBS="-lmpi ${PE_MPICH_GTL_LIBS_amd_gfx90a}"
python tools/amd_build/build_amd.py
python setup.py develop
# to re-build run: python setup.py clean 
```

