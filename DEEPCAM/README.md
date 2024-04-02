DeepCAM: 
=========

Included in the [NERSC-10](https://gitlab.com/NERSC/N10-benchmarks/deepcam) workfow benchmarks. 

DeepCAM trains a deep learning model to identify extreme weather phenomena in CAM5 simulation data. This case has particular relevance to HPC because it uses high resolution (768x1152) scientific images produced from HPC simulations that have more channels (16) than are typically found in commercial use-cases (3 channels for RGB images).

## NERSC-10 Benchmark 

NERSC provide their own implementation with minor modifications to the MLPerf HPC implementation, provides hyperparameter settings (e.g. define a required batch size, learning rate) which must be used for baseline submissions. Submissions are trained to IOU > 0.80, but benchmark performance is evaluated using time to complete 16 training epochs. 

| Implementation | #PM GPU nodes | Benchmark <br> Time (sec) |
|---             |---    |---    |
| Baseline       |   256 | 240.0 |
| Baseline       |   512 | 204.0 |
| Optimized      |   512 |  99.2* |

##### Table 1. Showing results for Perlmutter GPU nodes: 1x AMD EPYC 7763 CPU and 4x NVIDIA 40GB A100 GPUs. Using 4x MPI tasks per node i.e. each with 1 GPU and 16 cores. Lammps v23 June 2022 + Kokkos. 


# Results: 

Submitted on Cirrus: `/work/z04/z04/ebroadwa/benchmarks/deepcam/hpc/deepcam/src/deepCam`
* Full dataset 
* 64 GPU (16 node)
* Global batch size **must** be 2048, therefore the local batch size = 32

> Currently running at ~ 18 mins per epoch.\
> Perlmutter reports benchmark time (time to 16 epochs) of 240 seconds on 1,024 A100s.\ 
> 18 mins per epoch = 288 mins (4.8 hours) to 16 epochs on 64 V100s.  
