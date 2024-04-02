#!/bin/bash 

#SBATCH --partition=standard
#SBATCH --qos=standard
#SBATCH --nodes=1024
#SBATCH --tasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=0:05:00 
#SBATCH --account=z19 

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source medium_spec.txt

mkdir lammps_$spec.$SLURM_JOB_ID
cd    lammps_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../medium_spec.txt .

# Match the build env.
module load lammps/15Dec2023

input="${BENCH_SPEC} " 

command="srun --hint=nomultithread --distribution=block:block lmp $input"
echo $command
$command
