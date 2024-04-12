git clone --single-branch --branch stable https://github.com/lammps/lammps.git
cd lammps && git checkout 7d5fc356fe

mkdir build_kokkos && cd build_kokkos 

module load cmake/3.25.2
module load fftw/3.3.10-gcc10.2-impi20.4
module load intel-20.4/cmkl
module load nvidia/nvhpc-byo-compiler/22.11
module load eigen 

export LAMMPS_INSTALL=/work/z04/z04/ebroadwa/benchmarks/lammps/new_lammps_kokkos

cmake -C ../cmake/presets/most.cmake            \
      -D BUILD_MPI=on                           \
      -D BUILD_SHARED_LIBS=yes                  \
      -D CMAKE_BUILD_TYPE=Release               \
      -D CMAKE_CXX_COMPILER=mpicxx              \
      -D CMAKE_C_COMPILER=mpicc                 \
      -D CMAKE_Fortran_COMPILER=mpif90          \
      -D CMAKE_EXE_LINKER_FLAGS="-m64 -L${MKLROOT}/lib/intel64 -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl " \
      -D FFT=FFTW3                              \
      -D PKG_KOKKOS=on                          \
      -D PKG_MPIIO=yes                          \
      -D PKG_GPU=no                            \
      -D Kokkos_ARCH_VOLTA70=ON                \
       -D Kokkos_ENABLE_CUDA=yes \
      -D GPU_ARCH=sm_80                         \
      -D CMAKE_INSTALL_PREFIX=${LAMMPS_INSTALL} \
      -D CMAKE_CXX_FLAGS="-Wall -Wextra -pedantic" \
      ../cmake/

make -j 8
make install

# /work/z04/z04/ebroadwa/benchmarks/lammps/new_lammps_kokkos/

