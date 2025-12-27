#!/bin/bash
# PowerElyan - Master Build Script
# Usage: ./build_all.sh [arch] [edition]
# Example: ./build_all.sh ppc64le server

ARCH=${1:-ppc64le}
EDITION=${2:-all}

echo "Building PowerElyan $EDITION for $ARCH"

case $ARCH in
    ppc64le)
        DEBOOTSTRAP_ARCH="ppc64el"
        KERNEL_PKG="linux-image-powerpc64le"
        ;;
    x86_64)
        DEBOOTSTRAP_ARCH="amd64"
        KERNEL_PKG="linux-image-amd64"
        ;;
    aarch64)
        DEBOOTSTRAP_ARCH="arm64"
        KERNEL_PKG="linux-image-arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Using debootstrap arch: $DEBOOTSTRAP_ARCH"
echo "Kernel package: $KERNEL_PKG"

# Build logic here...
