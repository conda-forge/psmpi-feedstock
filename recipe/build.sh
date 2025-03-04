#!/bin/bash

set -ex

unset FFLAGS F77 F90 F95

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

export CFLAGS="${CFLAGS} -std=c11"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include -D_POSIX_C_SOURCE=200809L"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/x86_64-conda-linux-gnu/sysroot/lib"

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
             --enable-msa-awareness \
             --enable-threading

make -j"${CPU_COUNT}"

make install
