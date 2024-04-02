#!/bin/bash 

#SBATCH --partition=gpu 
#SBATCH --qos=gpu 
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --exclusive 
#SBATCH --time=01:00:00 
#SBATCH --account=z04

module load openmpi/4.1.6-cuda-11.6
module load nvidia/nvhpc-nompi/22.2

# spec.txt provides the input specification
# by defining the variables spec and BENCH_SPEC
source nano_spec.txt

mkdir lammps_$spec.$SLURM_JOB_ID
cd    lammps_$spec.$SLURM_JOB_ID
ln -s ../../common .
cp ${0} .
cp ../nano_spec.txt .

install_dir="/work/z04/z04/ebroadwa/benchmarks/lammps/lammps_v100_kokkos_snap"
export LD_LIBRARY_PATH=${install_dir}/lib64:$LD_LIBRARY_PATH
EXE=${install_dir}/bin/lmp

export OMP_NUM_THREADS=10 
export OMP_PLACES=cores

gpus_per_node=1

input="-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC}"
command="srun --ntasks=1 --tasks-per-node=1 $EXE $input"

echo $command
$command
