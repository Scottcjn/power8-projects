# Darwin PowerPC Cross-Compiler for POWER8

Build Mac OS X PowerPC software on IBM POWER8 - 128 threads = blazing fast builds!

## Why Cross-Compile on POWER8?

| Platform | Threads | Speed |
|----------|---------|-------|
| G4 PowerBook | 1 | 1x |
| Dual G5 | 2-4 | 3x |
| **POWER8 S824** | **128** | **~50-100x** |

The POWER8 can cross-compile a G4/G5 Mac project faster than the Mac can natively!

## Setup Instructions

### 1. Install Build Dependencies
```bash
sudo apt install -y \
    clang llvm-dev \
    libxml2-dev libssl-dev \
    libbz2-dev zlib1g-dev \
    cmake ninja-build \
    git curl wget
```

### 2. Build osxcross for PowerPC
```bash
cd ~/darwin-ppc-crosscompile
git clone https://github.com/tpoechtrager/osxcross.git
cd osxcross

# Download PowerPC SDK (need Xcode 3.x DMG)
# Extract SDK to tarballs/
# SDK versions: 10.4, 10.5, 10.6 for PPC

# Build with PowerPC target
TARGET_DIR=/opt/osxcross-ppc ./build.sh
```

### 3. Build GCC PowerPC-Darwin Cross-Compiler
Since osxcross focuses on x86_64/arm64, we need to build gcc manually:

```bash
# Download sources
wget https://ftp.gnu.org/gnu/gcc/gcc-7.5.0/gcc-7.5.0.tar.xz
wget https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz

# Build binutils for powerpc-apple-darwin9
cd binutils-2.35
./configure --target=powerpc-apple-darwin9 --prefix=/opt/darwin-ppc
make -j128  # All 128 threads!
make install

# Build GCC cross-compiler
cd gcc-7.5.0
./configure --target=powerpc-apple-darwin9 \
            --prefix=/opt/darwin-ppc \
            --with-sysroot=/opt/darwin-ppc/SDK \
            --enable-languages=c,c++ \
            --disable-multilib
make -j128
make install
```

## Usage

```bash
export PATH=/opt/darwin-ppc/bin:$PATH

# Compile for PowerPC Mac
powerpc-apple-darwin9-gcc -O2 -o myapp myapp.c

# With AltiVec optimizations
powerpc-apple-darwin9-gcc -maltivec -O3 -o myapp_altivec myapp.c
```

## Target Architectures

| Target | Mac OS X Version | CPU |
|--------|------------------|-----|
| powerpc-apple-darwin8 | 10.4 Tiger | G3/G4/G5 |
| powerpc-apple-darwin9 | 10.5 Leopard | G4/G5 |
| powerpc64-apple-darwin9 | 10.5 Leopard | G5 64-bit |

## Build Projects

### 1. Classic Mac Apps
```bash
# Build a Carbon app
powerpc-apple-darwin9-gcc -framework Carbon -o MyApp MyApp.c
```

### 2. AltiVec-optimized Libraries
```bash
# Build with AltiVec (for G4/G5)
powerpc-apple-darwin9-gcc -maltivec -mabi=altivec -O3 -c altivec_lib.c
```

### 3. Universal Binaries (on Mac)
After cross-compiling PPC binary, combine with x86:
```bash
lipo -create myapp_ppc myapp_x86 -output myapp_universal
```

---
*PowerElyan Project - Elyan Labs 2025*
