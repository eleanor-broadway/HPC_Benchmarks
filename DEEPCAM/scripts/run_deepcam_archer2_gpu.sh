#!/bin/bash

#SBATCH --job-name=1GPU-deepcam
#SBATCH --gpus=4
#SBATCH --time=00:20:00

# Replace [budget code] below with your project code (e.g. t01)
#SBATCH --account=z19
#SBATCH --partition=gpu
#SBATCH --qos=gpu-exc
#SBATCH --exclusive 
#SBATCH --nodes=1

source /work/z19/z19/eleanorb/miniconda3/bin/activate mlperf-torch-amd
cat $0 

export MPICH_GPU_SUPPORT_ENABLED=1
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
export LD_LIBRARY_PATH=$CRAY_MPICH_ROOTDIR/gtl/lib/:$LD_LIBRARY_PATH
export LD_PRELOAD=$CRAY_MPICH_ROOTDIR/gtl/lib/libmpi_gtl_hsa.so:$LD_PRELOAD
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
export PATH=$CONDA_PREFIX/bin:$PATH

module load PrgEnv-gnu
module load rocm
module load craype-accel-amd-gfx90a
module load craype-x86-milan
module load cray-mpich

export HOME=${HOME/home/work}

# Check assigned GPU
#srun --ntasks= rocm-smi

srun --ntasks=4 python train.py \
        --wireup_method "nccl-slurm" \
        --run_tag 1GPU_mini_rocm \
        --data_dir_prefix /work/z19/shared/mlperf-hpc/deepcam/mini/deepcam-data-n512/ \
        --output_dir /work/z19/z19/eleanorb/GPU/output/$SLURM_JOB_ID \
        --local_batch_size 1 \
        --max_epochs 10 \

