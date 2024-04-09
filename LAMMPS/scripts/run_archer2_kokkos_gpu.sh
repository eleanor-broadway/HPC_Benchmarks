#!/bin/bash 

#SBATCH --partition=gpu 
#SBATCH --qos=gpu-exc
#SBATCH --gres=gpu:1 
#SBATCH --nodes=1
#SBATCH --exclusive 
#SBATCH --time=01:00:00 

#SBATCH --account=z19

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC

module load PrgEnv-cray
module load craype-x86-milan
module load craype-accel-amd-gfx90a
module load rocm
module load cray-mpich

export MPICH_GPU_SUPPORT_ENABLED=1

source nano_spec.txt

mkdir lammps_$spec.$SLURM_JOB_ID
cd    lammps_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

install_dir="/work/z19/z19/eleanorb/GPU/lammps/"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

export OMP_NUM_THREADS=8 
export OMP_PLACES=cores

gpus_per_node=1
input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC} " 

command="srun --ntasks=1 --cpus-per-task=8 --hint=nomultithread --distribution=block:block $EXE $input"
echo $command
$command
