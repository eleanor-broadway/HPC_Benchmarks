git clone --single-branch --branch stable https://github.com/lammps/lammps.git
cd lammps && git checkout 7d5fc356fe

# mkdir build_v100_kokkos && cd build_v100_kokkos

mkdir build_kokkos_central && cd build_kokkos_central 

module load openmpi/4.1.6-cuda-11.6
module load nvidia/nvhpc-nompi/22.2
module load cmake 

module load fftw/3.3.10-intel20.4-impi20.4 

cmake \
  -D CMAKE_INSTALL_PREFIX=/work/z04/z04/ebroadwa/benchmarks/lammps/lammps_kokkos_central \
  -D Kokkos_ARCH_VOLTA70=ON \
  -D CMAKE_BUILD_TYPE=Release \
  -D MPI_CXX_COMPILER=mpicxx \
  -D BUILD_MPI=yes \
  -D PKG_ML-SNAP=yes \
  -D PKG_GPU=no \
  -D PKG_KOKKOS=yes \
  -D PKG_MOLECULE=yes \
  -D Kokkos_ENABLE_CUDA=yes \
  -DCMAKE_CXX_FLAGS="-O3" \
  -D FFT=FFTW3 -D PKG_ASPHERE=yes \
  -D PKG_BODY=yes -D PKG_CLASS2=yes -D PKG_COLLOID=yes        \
  -D PKG_COMPRESS=yes -D PKG_CORESHELL=yes -D PKG_DIPOLE=yes  \
  -D PKG_GRANULAR=yes -D PKG_MC=yes          \
  -D PKG_KSPACE=yes -D PKG_MANYBODY=yes -D PKG_MOLECULE=yes   \
  -D PKG_OPT=yes -D PKG_PERI=yes             \
  -D PKG_QEQ=yes -D PKG_SHOCK=yes -D PKG_SRD=yes              \
  -D PKG_RIGID=yes                                         \
  ../cmake

make -j8
make install -j8
