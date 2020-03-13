#!/usr/bin/env bash

set -ex

# Download
URL="https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz"
pushd "${DOWNLOADS}"
wget -N "$URL"
popd

# Extract
tar xzf "${DOWNLOADS}/Python-3.8.1.tgz"
pushd Python-3.8.1

# Ensure Python can find libffi
ln -s ${RPI_SYSROOT}/usr/local/lib/libffi-3.2.1/include/* \
      ${RPI_SYSROOT}/usr/local/include/

# Configure
echo -e "ac_cv_file__dev_ptmx=yes\nac_cv_file__dev_ptc=no" > config.site
CONFIG_SITE="$PWD/config.site" \
./configure \
    --enable-ipv6 \
    --enable-shared --with-lto --enable-optimizations \
    --enable-loadable-sqlite-extensions --with-dbmliborder=bdb:gdbm \
    --with-ensurepip=install \
    --build="$(gcc -dumpmachine)" \
    --host="${HOST_TRIPLE}" \
    --prefix="/usr/local" \
    CFLAGS="--sysroot=${RPI_SYSROOT} \
                -I${RPI_SYSROOT}/usr/local/include \
                -L${RPI_SYSROOT}/usr/local/lib \
                -L${RPI_SYSROOT}/usr/local/lib64" \
    CPPFLAGS="--sysroot=${RPI_SYSROOT} \
                -I${RPI_SYSROOT}/usr/local/include" \
    CXXFLAGS="--sysroot=${RPI_SYSROOT} \
                -I${RPI_SYSROOT}/usr/local/include \
                -L${RPI_SYSROOT}/usr/local/lib \
                -L${RPI_SYSROOT}/usr/local/lib64" \
    LDFLAGS="--sysroot=${RPI_SYSROOT} \
                -L${RPI_SYSROOT}/usr/local/lib \
                -L${RPI_SYSROOT}/usr/local/lib64"
cat config.log

# Build
make -j$(($(nproc) * 2))

# Install
make altinstall DESTDIR="${RPI_SYSROOT}"
make altinstall DESTDIR="${RPI_STAGING}"

# Cleanup
popd
rm -rf Python-3.8.1