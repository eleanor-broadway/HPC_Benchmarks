#!/bin/bash

#SBATCH --job-name=mlperf-deepcam-benchmark
#SBATCH --gres=gpu:4
#SBATCH --time=24:00:00
#SBATCH --account=z04
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --exclusive
#SBATCH --nodes=2

eval "$(/work/z04/z04/ebroadwa/miniconda3/bin/conda shell.bash hook)"
conda activate mlperf-torch
cat $0 

module load openmpi/4.1.6-cuda-11.6
module load nvidia/cudnn/8.6.0-cuda-11.6  

export OMP_NUM_THREADS=10
export SRUN_CPUS_PER_TASK=10
export OMPI_MCA_mpi_warn_on_fork=0

nvidia-smi --loop=10 --filename=smi-${SLURM_JOBID}.txt &

local_batch_size=1

#other options within this script may be adjusted freely
data_dir=/work/z04/shared/mlperf-hpc/deepcam/mini/
output_dir=/work/z04/z04/ebroadwa/benchmarks/deepcam/output/$SLURM_JOB_ID
run_tag="${SLURM_JOB_NAME}-${SLURM_JOB_ID}"

time srun --ntasks=8 --tasks-per-node=4 python3 train.py \
    --target_iou 0.80 \
    --wireup_method "nccl-slurm" \
    --run_tag ${run_tag} \
    --data_dir_prefix ${data_dir} \
    --output_dir ${output_dir} \
    --optimizer "Adam" \
    --max_epochs 64 \
    --local_batch_size ${local_batch_size}

# LAMB requires APEX which has been deprecated...
