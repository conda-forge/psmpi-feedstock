#!/bin/bash

set -ex

unset FFLAGS F77 F90 F95

export CC="${CC}"
export CXX="${CXX}"
export FC="${FC}"
export CFLAGS="${CFLAGS} -std=c99"

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
             --enable-threading \
	     --with-sysroot="${PREFIX}/x86_64-conda-linux-gnu/sysroot

make -j"${CPU_COUNT}"

make install
