#!/bin/bash
# Darwin PowerPC Cross-Compiler Setup Script
# For IBM POWER8 running PowerElyan (Debian Bookworm)

set -e
echo "=============================================="
echo "  Darwin PPC Cross-Compiler Setup"
echo "  PowerElyan Project - Elyan Labs"
echo "=============================================="

PREFIX=/opt/darwin-ppc
BUILD_DIR=~/darwin-ppc-build

mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Install dependencies
echo "[1/5] Installing build dependencies..."
sudo apt update
sudo apt install -y \
    build-essential gcc g++ \
    clang llvm-dev \
    libxml2-dev libssl-dev \
    libbz2-dev zlib1g-dev \
    cmake ninja-build \
    git curl wget \
    texinfo flex bison \
    libgmp-dev libmpfr-dev libmpc-dev

# Download sources
echo "[2/5] Downloading sources..."
if [ ! -f binutils-2.35.tar.xz ]; then
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz
fi
if [ ! -f gcc-7.5.0.tar.xz ]; then
    wget https://ftp.gnu.org/gnu/gcc/gcc-7.5.0/gcc-7.5.0.tar.xz
fi

# Extract
echo "[3/5] Extracting sources..."
tar -xf binutils-2.35.tar.xz 2>/dev/null || true
tar -xf gcc-7.5.0.tar.xz 2>/dev/null || true

# Build binutils
echo "[4/5] Building binutils for powerpc-apple-darwin9..."
mkdir -p build-binutils && cd build-binutils
../binutils-2.35/configure \
    --target=powerpc-apple-darwin9 \
    --prefix=$PREFIX \
    --disable-werror \
    --disable-nls
make -j$(nproc)  # Use all 128 threads!
sudo make install
cd ..

# Build GCC (minimal, no sysroot yet)
echo "[5/5] Building GCC cross-compiler..."
mkdir -p build-gcc && cd build-gcc
../gcc-7.5.0/configure \
    --target=powerpc-apple-darwin9 \
    --prefix=$PREFIX \
    --enable-languages=c,c++ \
    --disable-multilib \
    --disable-libssp \
    --disable-libgomp \
    --disable-libquadmath \
    --without-headers \
    --with-newlib
make -j$(nproc) all-gcc
sudo make install-gcc
cd ..

echo ""
echo "=============================================="
echo "  Darwin PPC Cross-Compiler Installed!"
echo ""
echo "  Add to PATH:"
echo "    export PATH=$PREFIX/bin:\$PATH"
echo ""
echo "  Test:"
echo "    powerpc-apple-darwin9-gcc --version"
echo "=============================================="
