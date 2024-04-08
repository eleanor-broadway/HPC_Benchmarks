#!/bin/bash 

#SBATCH --job-name=deepcam
#SBATCH --time=24:0:0
#SBATCH --nodes=256
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=16
#SBATCH --account=z19
#SBATCH --partition=standard
#SBATCH --qos=standard

source /work/z19/z19/eleanorb/miniconda3/bin/activate mlperf-torch
cat $0 

export OMP_NUM_THREADS=1
export SRUN_CPUS_PER_TASK=10

local_batch_size=1
data_dir=/work/z19/shared/mlperf-hpc/deepcam/full/
output_dir=/work/z19/z19/eleanorb/CPU/deepcam/output/$SLURM_JOB_ID
run_tag="${SLURM_JOB_NAME}-${SLURM_JOB_ID}"

# tasks = 8 * 256 = 2048 

time srun --ntasks=2048 --tasks-per-node=8 python3 train.py \
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
    --wireup_method "mpi" \
    --run_tag ${run_tag} \
    --data_dir_prefix ${data_dir} \
    --output_dir ${output_dir} \
    --model_prefix "segmentation" \
    --optimizer "Adam" \
    --max_epochs 20 \
    --max_inter_threads 0 \
    --local_batch_size ${local_batch_size}
