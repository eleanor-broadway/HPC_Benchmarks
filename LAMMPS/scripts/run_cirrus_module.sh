#!/bin/bash 

#SBATCH --partition=gpu 
#SBATCH --qos=gpu 
#SBATCH --gres=gpu:4 
#SBATCH --nodes=2
#SBATCH --exclusive 
#SBATCH --time=02:00:00 
#SBATCH --account=z04

module load lammps-gpu/15Dec2023-gcc10.2-impi20.4-cuda11.8

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source micro_spec.txt

mkdir lammps_$spec.$SLURM_JOB_ID
cd    lammps_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../micro_spec.txt .

export OMP_NUM_THREADS=1

#GPUs per node
NGPUS=4
#TASKS per node
NTASKS=$(expr 10 \* ${NGPUS})
PRMS="--ntasks=${NTASKS} --hint=nomultithread --cpus-per-task=1"

input="-sf gpu -pk gpu ${NGPUS} neigh no ${BENCH_SPEC} " 

command="srun ${PRMS} lmp $input"
echo $command
$command
