#!/bin/bash

set -ex

unset FFLAGS F77 F90 F95

export CC="${CC}"
export CXX="${CXX}"
export FC="${FC}"
export CFLAGS="${CFLAGS} -std=c11"
export CPPFLAGS="${CPPFLAGS} -I/usr/include -D_POSIX_C_SOURCE=200809L"
export LDFLAGS="${LDFLAGS} -L/usr/lib64"

cd $SRC_DIR/psmpi

./autogen.sh

mkdir -p build
cd build

../configure \
    --prefix="${PREFIX}" \
    --with-confset=gcc \
    --enable-confset-overwrite \
    --with-pscom-allin="${SRC_DIR}/pscom" \
    --with-hwloc="${PREFIX}" \
    --with-pmix="${PREFIX}" \
    --enable-msa-awareness \
    --enable-threading \
    CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" 

make V=1 -j"${CPU_COUNT}"

make V=1 install
