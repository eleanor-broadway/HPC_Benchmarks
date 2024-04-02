LAMMPS: NERSC-10 Materials by Design Benchmark 
===============================================

[EXAALT](https://gitlab.com/NERSC/N10-benchmarks/exaalt) is an ECP project aiming to optimise MD for exascale, based on a workflow using ParSplice and LAMMPS. 

MD workflows, simulated using LAMMPS, accelerate each time-step by distributing atoms across parallel processing units but keeping the series of time-steps sequential. ParSplice optimises this by managing multiple instances of LAMMPS as a hierarchical task management layer. This introduces parallelism of the time dimension as well as each individual time-step. However, LAMMPS is the performance critical component of the workflow and using **95%** of the EXAALT runtime. So, ParSlice is not included in this benchmark. 

This benchmark simulates the high-pressure BC8 phase of carbon using Spectral Neighbour Analysis Potential (SNAP). 


### Parallel decomposition: 
LAMMPS uses a 3D spatial domain decomposition to distribute atoms amongst MPI processes. The default decomposition divides the simulated space into rectangular bricks. 

<!-- LAMMPS will run correctly with any number of MPI processes but **better performance when the number of MPI processes is the product of three near-equal integers.** -->

## NERSC-10 Benchmark: 
* Input files/batch scripts/Perlmutter outputs for 7 different problem sizes. 
* The collection forms a weak scaling series where each step is 8 x bigger than the previous. 

| Size (atoms)     |  #PM GPU nodes | Total Mem(GB) | #BenchmarkTime(sec) |
| ----      | ---------- | ------------- | ---------  |
| nano (65k)     |    0.25    |      0.14     |      3     |
| micro (524k)    |    0.25    |      0.23     |     25     |
| tiny (4.16M)     |       1    |      1.33     |     54     |
| small (33.6M)    |       1    |      7.32     |    424     |
| medium (268M)   |       8    |      58.6     |    405     |
| reference (2.15B) |      32    |      453.     |    805     |
| reference |      64    |      453.     |    445     |
| reference |     128    |      453.     |    213     |
| reference |     256    |      453.     |    130     |
| reference |     512    |     453.      |     55     |
| reference |    1024    |     453.      |     31*    |

##### Table 1. Showing results for Perlmutter GPU nodes: 1x AMD EPYC 7763 CPU and 4x NVIDIA 40GB A100 GPUs. Using 4x MPI tasks per node i.e. each with 1 GPU and 16 cores. Lammps v23 June 2022 + Kokkos. 


</br>

# Results 
<!-- ### Perlmutter nano runtime options: 
```bash 
-k on g $gpus_per_node -sf kk -pk kokkos newton on neigh half ${BENCH_SPEC}

-k on g $gpus_per_node = kokkos on with X gpus 
-sf kk = kokkos 
-pk kokkos newton on = turns on pairwise (not bonded) interactions, more computation but less communication
neigh half = determines how neighbor lists are built, a value of half uses a thread-safe variant of half-neighbor lists 
```

### Cirrus nano runtime options: 
* Module ```lammps-gpu/15Dec2023-gcc10.2-impi20.4-cuda11.8```. 

```bash 
-sf gpu -pk gpu $gpus_per_node neigh no

-pk gpu $gpus_per_node = using X gpus 
neigh off = despite the GPU default being to build the neighbor list on the GPU, this is OFF because we are using a "hybrid pair style"
newton off = set Newton pairwise flag off (default for GPUs and required)
``` -->


## ARCHER2 CPU: 
Naive results (i.e copying Perlmutter's balance of 64 tasks-per-node with 2 cpus-per-task) and no repeats as of yet. 


<img src="results/gp_strong_a2_cpu_33.6Matoms_speedup.png" width="500"> 

##### Fig 1. Strong scaling speed-up of the 33.6M atom (small) benchmark on ARCHER2 CPU nodes. 

<!-- <img src="weak_a2_cpu_64taskspernode.png" width="500"> 

##### Fig 2. weak scaling of lammps on ARCHER2 CPU nodes.  -->

<img src="results/weak_a2_cpu_64taskspernode_efficiency.png" width="500"> 

##### Fig 2. Weak scaling efficiency. 

</br>

## Cirrus GPU: 

Initial testing: 
* Perlmutter A100 kokkos: `Performance: 1.373 ns/day, 17.476 hours/ns, 31.790 timesteps/s` **= 3s**
* Cirrus V100 kokkos: `Performance: 1.011 ns/day, 23.741 hours/ns, 23.401 timesteps/s` **= 6s** 
* Cirrus V100 Cuda: `Performance: 0.002 ns/day, 10271.252 hours/ns, 0.054 timesteps/s, 3.545 katom-step/s` **= 31 mins** 

Cuda build is significantly slower. Due to the pair_style chosen by the benchmark, we aren't able to offload the building of neighbour lists to the GPU without using kokkos.  

> :warning: **Issue with the benchmark**: Appears we have to use Kokkos to be performant.

<!-- Strong scaling kokkos with 1, 2, 4, 8 GPUs 
I can't run anything else on Cirrus because I am running the MLPerf and my allowance it used
-->


### Comparing Kokkos vs CUDA: 

Planning to use a different example (ethanol) which uses a more standard pair_style to test the performance of kokkos vs cuda. Prove that the above issue is due to the neighbour list/newton pairing causing a slow down.  

<!-- <img src="gp_cirrus_module_gpu_nano.png" width="500">  

##### Fig 4. Strong scaling of the nano benchmark on Cirrus using the centralised module.  
 
1 GPU: 5571831 - 0:31:18
2 GPU: 5571345 - 0:13:34
4 GPU: 5571339 - 0:06:58
8 GPU: 5571367 - 0:03:24
-->
