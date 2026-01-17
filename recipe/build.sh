#!/bin/bash

set -ex

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

if [[ $CONDA_BUILD_CROSS_COMPILATION == 1 ]]; then
  export CROSS_F77_SIZEOF_INTEGER=4
  export CROSS_F77_SIZEOF_REAL=4
  export CROSS_F77_SIZEOF_DOUBLE_PRECISION=8
  export CROSS_F77_TRUE_VALUE=1
  export CROSS_F77_FALSE_VALUE=0
  export CROSS_F90_ADDRESS_KIND=8
  export CROSS_F90_OFFSET_KIND=8
  export CROSS_F90_INTEGER_KIND=4
  export CROSS_F90_REAL_MODEL=" 6 , 37"
  export CROSS_F90_DOUBLE_MODEL=" 15 , 307"
fi

# Build shs-libfabric (non-CUDA version)
cd ${SRC_DIR}/shs-libfabric

autoreconf -ivf

./configure --prefix=${PREFIX} \
            --enable-cxi \
            --with-cassini-headers=${PREFIX} \
            --with-cxi-uapi-headers=${PREFIX} \
            --with-curl=${PREFIX} \
            --with-json-c=${PREFIX} \
            --with-libnl=${PREFIX} \
            --docdir=$PWD/noinst/doc \
            --mandir=$PWD/noinst/man \
            --disable-lpp \
            --disable-psm3 \
            --disable-opx \
            --disable-efa \
            --disable-static

make -j${CPU_COUNT} src/libfabric.la
make -j${CPU_COUNT} util/fi_info util/fi_pingpong util/fi_strerror util/fi_mon_sampler

make install-exec install-data

# Build psmpi (vendor branch)
cd ${SRC_DIR}/psmpi/mpich2

./autogen.sh

mkdir -p build
cd build

../configure --prefix="${PREFIX}" \
             --build="${BUILD}" \
             --host="${HOST}" \
             --with-device=ch4:ucx,ofi \
             --with-ucx="${PREFIX}" \
             --with-libfabric="${PREFIX}" \
             --with-hwloc="${PREFIX}" \
             --enable-threads=runtime \
	     --with-pm=hydra \
	     -with-pmi=pmi2 \
             --enable-romio \
             --enable-cxx \
             --enable-fast=all \
             --enable-g=none \
             --disable-doc \
             --disable-static \
             --disable-dependency-tracking \
             --with-wrapper-dl-type=none

make -j${CPU_COUNT}

make install

# Clean embedded reproducibility flags (-fdebug-prefix-map=...) from MPI wrappers
for wrapper in "${PREFIX}/bin/"*mpi*; do
  if [[ -f "${wrapper}" ]]; then
    sed -i '/-fdebug-prefix-map=/d' "${wrapper}"
  fi
done
