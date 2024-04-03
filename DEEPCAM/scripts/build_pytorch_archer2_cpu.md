# Building PyTorch from source on ARCHER2
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

# launch slurm job
```bash
sbatch build.slurm
```
                                                    

## Example submission script:

```bash 
#!/bin/bash 
#SBATCH --job-name=deepcam-torch
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=16
#SBATCH --time=04:00:00

#SBATCH --account=d183
#SBATCH --partition=standard
#SBATCH --qos=standard

eval  "$(/work/d183/d183/eleanor-d183/miniconda3/bin/conda shell.bash hook)"
conda activate mlperf-torch

export SRUN_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
export OMP_NUM_THREADS=16

module load PrgEnv-gnu

time srun --distribution=block:block --hint=nomultithread --ntasks=32 --ntasks-per-node=8 python train.py \
        --wireup_method "mpi" \
        --run_tag i_wish_this_stupid_thing_worked \
        --data_dir_prefix /work/z19/shared/mlperf-hpc-eleanor/deepcam/mini/deepcam-data-n512/ \
        --output_dir /work/d183/d183/eleanor-d183/output/$SLURM_JOB_ID \
        --local_batch_size 1 \
        --max_epochs 5 \

```

Remember: 
* Set the CPU frequency 
* Experiment with `tasks-per-node` vs `cpus-per-task`