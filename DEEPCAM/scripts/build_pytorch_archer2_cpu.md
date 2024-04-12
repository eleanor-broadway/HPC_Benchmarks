# Building PyTorch from source on ARCHER2 CPU 

Instructions adapted from [Chris Rae's](https://github.com/EPCCed/chris-ml-intern/blob/main/HOW_TO/build_torch/archer2.md). 

## Setup Miniconda

```bash
PRFX=/work/d183/d183/eleanor-d183
cd $PRFX

# wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
# bash ./Miniconda3-latest-Linux-x86_64.sh
#When installing make sure you install miniconda in the correct PREFIX 
#Make sure that miniconda is install in /work not /home

eval "$($PRFX/miniconda3/bin/conda shell.bash hook)"

conda create --name mlperf-torch python=3.10
conda activate mlperf-torch
```

## Download Torch

```bash
cd $PRFX/CPU/pytorch 
wget https://github.com/pytorch/pytorch/releases/download/v2.0.1/pytorch-v2.0.1.tar.gz
tar -xf ./pytorch-v2.0.1.tar.gz
# OPTIONAL
# rm ./pytorch-v2.0.1.tar.gz
```

## Install dependencies
```bash
source $PRFX/miniconda3/bin/activate mlperf-torch
conda install cmake ninja
cd ./pytorch-v2.0.1
pip install -r requirements.txt
conda install mkl mkl-include
```

## Define `build.slurm`

This could be done with an interactive node

```bash
#!/bin/bash

#SBATCH --job-name=build-torch
#SBATCH --time=02:00:00
#SBATCH --nodes=1
#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --account=z19

#change to your prefix
eval "$(/work/z19/z19/eleanorb/miniconda3/bin/conda shell.bash hook)"
conda activate mlperf-torch

export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
export OMP_NUM_THREADS=1

module load PrgEnv-gnu

export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
export USE_CUDA=0
export USE_DISTRIBUTED=1
export BUILD_CAFFE2=0

python setup.py develop
```

# Launch slurm job
```bash
sbatch build.slurm
```