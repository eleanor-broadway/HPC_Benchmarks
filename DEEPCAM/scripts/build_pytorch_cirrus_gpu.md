# Building PyTorch from source on Cirrus GPU 

Instructions adapted from [Chris Rae's](https://github.com/EPCCed/chris-ml-intern/blob/main/HOW_TO/build_torch/cirrus.md). 


## Setup Miniconda

```bash
PRFX=/work/z04/z04/ebroadwa
cd $PRFX

# wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
# bash ./Miniconda3-latest-Linux-x86_64.sh
#When installing make sure you install miniconda in the correct PREFIX 
#Make sure that miniconda is install in /work not /home

eval "$($PRFX/miniconda3/bin/conda shell.bash hook)"

# conda env list 
# conda remove --name ENV_NAME --all

conda create --name mlperf-torch python=3.10
conda activate mlperf-torch
```

```bash
module unload cmake
module swap gcc gcc/10.2.0
module load openmpi/4.1.6-cuda-11.6
```

## Download Torch

```bash
cd $PRFX/ai4nz/gpu-build
git clone --single-branch --branch release/2.0 https://github.com/pytorch/pytorch.git
cd pytorch
git submodule sync
git submodule update --init --recursive
```

## Install dependencies

```bash
source $PRFX/miniconda3/bin/activate mlperf-torch

conda install -c "nvidia/label/cuda-11.6.0" cuda-toolkit
conda install -c nvidia cudatoolkit=11.6
conda install -c nvidia cudnn
conda install -c "nvidia/label/cuda-11.6.0" libcusparse-dev
conda install -c "nvidia/label/cuda-11.6.0" libcusolver-dev
conda install cmake ninja
#cd into pytorch if not already
pip install -r requirements.txt
conda install mkl mkl-include
conda install -c pytorch magma-cuda118
```

## Build Pytorch
```bash
srun --exclusive --nodes=1 --time=10:00:00 --partition=gpu --qos=gpu --gres=gpu:1 --account=z04 --pty /usr/bin/bash --login
source /work/z04/z04/ebroadwa/miniconda3/bin/activate mlperf-torch
export USE_ROCM=0
export BUILD_TEST=0
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
export PATH=$CONDA_PREFIX/bin:$PATH
export CUDA_NVCC_EXECUTABLE=$CONDA_PREFIX/bin/nvcc
export CUDA_BIN_PATH=$CONDA_PREFIX/bin
export CUDA_HOME=$CONDA_PREFIX
export LDFLAGS=-L/$CONDA_PREFIX/lib
export BUILD_CAFFE2=0
export BUILD_CAFFE2_OPS=0
module unload cmake
module swap gcc gcc/10.2.0
module load openmpi/4.1.6-cuda-11.6
#cd into pytorch if not already
#python setup.py clean
python setup.py develop
```


## Clean up
```bash
source $PRFX/miniconda3/bin/activate mlperf-torch
conda uninstall -c "nvidia/label/cuda-11.6.0" cuda-toolkit
conda uninstall -c nvidia cudatoolkit=11.6
conda uninstall -c nvidia cudnn
conda uninstall -c "nvidia/label/cuda-11.6.0" libcusparse-dev
conda uninstall -c "nvidia/label/cuda-11.6.0" libcusolver-dev
#cupti not installed in local nvhpc 
conda install nvidia/label/cuda-11.6.0::cuda-cupti
```

## Test
```bash
srun --nodes=1 --time=01:30:00 --partition=gpu --qos=gpu --gres=gpu:1 --account=[CODE] --pty /usr/bin/bash --login
source $PRFX/miniconda3/bin/activate mlperf-torch
module load openmpi/4.1.5-cuda-11.6
module load nvidia/nvhpc/22.11 nvidia/cudnn/8.6.0-cuda-11.6 nvidia/tensorrt/8.4.3.1-u2
python
Python 3.10.13 (main, Sep 11 2023, 13:44:35) [GCC 11.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import torch
>>> torch.cuda.is_available()
True
>>> torch.distributed.is_mpi_available()
True
>>> exit()
```
If both don't return True the install has gone wrong in the setup.py stage
