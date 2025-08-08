#!/bin/bash

set -ex

unset FFLAGS F77 F90 F95

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

if [[ "$HOST" == "aarch64-conda-linux-gnu" || "$CONDA_SUBDIR" == "linux-aarch64" ]]; then
  export CFLAGS="$CFLAGS -I$CONDA_PREFIX/$HOST/sysroot/usr/include -O2 -march=armv8-a"
  export CXXFLAGS="$CXXFLAGS -I$CONDA_PREFIX/$HOST/sysroot/usr/include -O2 -march=armv8-a"
else
  export CFLAGS="$CFLAGS -I$CONDA_PREFIX/$HOST/sysroot/usr/include -O2 -march=x86-64"
  export CXXFLAGS="$CXXFLAGS -I$CONDA_PREFIX/$HOST/sysroot/usr/include -O2 -march=x86-64"
fi

cd $SRC_DIR/psmpi

./autogen.sh

mkdir -p build
cd build

../configure --prefix=$PREFIX \
             --with-confset=gcc \
             --enable-confset-overwrite \
             --with-pscom-allin=$SRC_DIR/pscom \
             --with-hwloc=$PREFIX \
             --with-pmix=$PREFIX \
             --with-pmix-include=$PREFIX/include \
             --with-pmix-lib=$PREFIX/lib \
             --enable-threading

make -j"${CPU_COUNT}"

make install
