#!/bin/bash

set -ex

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

cd $SRC_DIR/psmpi

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

./autogen.sh

mkdir -p build
cd build

../configure --prefix=$PREFIX \
             --build=${BUILD} \
             --host=${HOST} \
             --with-confset=gcc \
             --enable-confset-overwrite \
             --with-pscom-allin=$SRC_DIR/pscom \
             --with-hwloc=$PREFIX \
             --with-pmix=$PREFIX \
             --enable-msa-awareness \
             --enable-threading

make -j"${CPU_COUNT}"

make install
