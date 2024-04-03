# Building PyTorch from source on Cirrus
Instructions adapted from [Chris Rae's](https://github.com/EPCCed/chris-ml-intern/blob/main/HOW_TO/build_torch/cirrus.md). 


## Setup Miniconda

```bash
PRFX=/work/d183/d183/eleanor-d183
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
cd $PRFX/gpu-build
git clone --single-branch --branch release/2.0 https://github.com/pytorch/pytorch.git
cd pytorch
git submodule sync
git submodule update --init --recursive
```

## Install Dependancies
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
source $PREFIX/miniconda/bin/activate build-torch
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
source $PREFIX/miniconda/bin/activate build-torch
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


-------------------


## Example submission script for NCCL: 
```bash 
#!/bin/bash

#SBATCH --job-name=mlperf-deepcam-benchmark
#SBATCH --time=02:00:00
#SBATCH --exclusive
#SBATCH --nodes=1 #MAKE SURE TO UPDATE SRUN

#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=d183

cat $0 

eval "$(/work/d183/d183/eleanor-d183/miniconda3/bin/conda shell.bash hook)"
conda activate mlperf-torch

module load openmpi/4.1.5-cuda-11.6
module load nvidia/cudnn/8.9.4-cuda-11.6  

export OMPI_MCA_mpi_warn_on_fork=0

export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
export OMP_NUM_THREADS=10

nvidia-smi --loop=10 --filename=smi-${SLURM_JOBID}.txt &

time srun --ntasks=4 --tasks-per-node=4 python train.py \
        --wireup_method "nccl-slurm" \
        --run_tag i_wish_this_stupid_thing_worked \
        --data_dir_prefix /work/z04/shared/mlperf-hpc/deepcam/mini/deepcam-data-n512/ \
        --output_dir /work/d183/d183/eleanor-d183/output/$SLURM_JOB_ID \
        --local_batch_size 1 \
        --max_epochs 10 \

```

## Example submission script for MPI (only works within a node): 

```bash 
#!/bin/bash

#SBATCH --job-name=mlperf-deepcam-benchmark
#SBATCH --time=02:00:00
#SBATCH --exclusive
#SBATCH --nodes=1 #MAKE SURE TO UPDATE SRUN

#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gres=gpu:4
#SBATCH --account=d183

cat $0 

eval "$(/work/d183/d183/eleanor-d183/miniconda3/bin/conda shell.bash hook)"
conda activate build-new-torch

module load openmpi/4.1.5-cuda-11.6

export OMPI_MCA_mpi_warn_on_fork=0
export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
export OMP_NUM_THREADS=10

# Without this, it doesn't work
OMPI_MCA_pml=ob1

nvidia-smi --loop=10 --filename=smi-${SLURM_JOBID}.txt &

time srun --ntasks=4 --tasks-per-node=4 python train.py \
        --wireup_method "mpi" \
        --run_tag i_wish_this_stupid_thing_worked \
        --data_dir_prefix /work/z04/shared/mlperf-hpc/deepcam/mini/deepcam-data-n512/ \
        --output_dir /work/d183/d183/eleanor-d183/output/$SLURM_JOB_ID \
        --local_batch_size 1 \
        --max_epochs 5 \
```