#!/bin/bash

set -ex

pkg-config --modversion pmix || echo "pkg-config for pmix failed"

unset FFLAGS F77 F90 F95

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

export CFLAGS="$CFLAGS -I$CONDA_PREFIX/$HOST/sysroot/usr/include"
export CPPFLAGS="$CPPFLAGS -I$CONDA_PREFIX/$HOST/sysroot/usr/include"

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
             --enable-msa-awareness \
             --enable-threading

make -j"${CPU_COUNT}"

make install
