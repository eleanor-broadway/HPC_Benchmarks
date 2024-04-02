#!/bin/bash

#SBATCH --job-name=mlperf-deepcam-benchmark
#SBATCH --gres=gpu:4
#SBATCH --time=24:00:00
#SBATCH --account=z04
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --exclusive
#SBATCH --nodes=16 

eval "$(/work/z04/z04/ebroadwa/miniconda3/bin/conda shell.bash hook)"
conda activate mlperf-torch
cat $0 

module load openmpi/4.1.6-cuda-11.6
module load nvidia/cudnn/8.6.0-cuda-11.6  

export OMP_NUM_THREADS=10
export SRUN_CPUS_PER_TASK=10
export OMPI_MCA_mpi_warn_on_fork=0

nvidia-smi --loop=10 --filename=smi-${SLURM_JOBID}.txt &

#the local batch size may be adjusted
#under the constraint that the global batch size is fixed to 2048,
#i.e. processes * local_batch_size = 2048.
#for example: local_batch_size=$(( 2048 / ${SLURM_NTASKS} ))
local_batch_size=1

#other options within this script may be adjusted freely
data_dir=/work/z04/shared/mlperf-hpc/deepcam/full/
output_dir=/work/z04/z04/ebroadwa/benchmarks/deepcam/output/$SLURM_JOB_ID
run_tag="${SLURM_JOB_NAME}-${SLURM_JOB_ID}"

time srun --ntasks=64 --tasks-per-node=4 python3 train.py \
    --gradient_accumulation_frequency 1 \
    --logging_frequency 10 \
    --save_frequency 0 \
    --target_iou 0.80 \
    --batchnorm_group_size 1 \
    --start_lr 0.0055 \
    --lr_schedule type="multistep",milestones="800",decay_rate="0.1" \
    --lr_warmup_steps 400 \
    --lr_warmup_factor 1. \
    --weight_decay 1e-2 \
    --optimizer_betas 0.9 0.999 \
    --wireup_method "nccl-slurm" \
    --run_tag ${run_tag} \
    --data_dir_prefix ${data_dir} \
    --output_dir ${output_dir} \
    --model_prefix "segmentation" \
    --optimizer "Adam" \
    --max_epochs 64 \
    --max_inter_threads 0 \
    --local_batch_size ${local_batch_size}

# LAMB requires APEX which has been deprecated...
