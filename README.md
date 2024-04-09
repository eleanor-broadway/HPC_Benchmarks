HPC Benchmarks 
==============

Identifying suitable exascale benchmarks for candidate software: 

| Application                   | Notes                                             
| -------------                 | -----------------------                               
| NEMO Ocean                    |                           
| GRID                          | Used for Tursa procurement       
| VASP	                        | See paper: VASP Performance on HPE Cray EX Based on NVIDIA A100 GPUs and AMD Milan CPUs
| GROMACS                       | Potentially used for LUMI procurement. 
| OPEN SBLI	                    | Used for ARCHER2 procurement, similar investigation with GPUs might be suitable  
| [DeepCAM](DEEPCAM/README.md)  | NERSC-10 
| [LAMMPS](LAMMPS/README.md)	| NERSC-10  
| CASTEP	                    | GPU port under development  
| HemeLB	                    | Paper: Development and performance of a HemeLB GPU code for human-scale blood flow simulation


Assessing the scaling capability on ARCHER2 CPU and Cirrus GPU, assessing compiling and compatability with ARCHER2 GPU. 

Hardware: 
---------
### ARCHER2 CPU

* 2× AMD EPYC 7742, 2.25 GHz, 64-core
* 256 GiB host memory  
* 2x 100 Gb/s injection ports per node

### ARCHER2 GPU
* 1x AMD EPYC 7534P (Milan) processor, 32 core, 2.8 GHz
* 4x AMD Instinct MI210 accelerator
* 512 GiB host memory
* 2× 100 Gb/s Slingshot interfaces per node

### Cirrus GPU 
* 2x 2.5 GHz, 20-core Intel Xeon Gold 6148 (Cascade Lake) series processors
* 4x NVIDIA Tesla V100-SXM2-16GB (Volta) GPU accelerators
* 384 GB of main memory shared between the two processors
* Single ib0 interface. The IB interface is FDR, with a bandwidth of 54.5 Gb/s.