#!/bin/bash
# PowerElyan HSA Kernel Build Script
# Builds Debian kernel with CONFIG_HSA_AMD=y for POWER8 ROCm support

set -e

KERNEL_VERSION="6.1"
LOCALVERSION="-powerelyan-hsa"

echo "=========================================="
echo "PowerElyan HSA Kernel Builder"
echo "=========================================="

# Check if running on ppc64le
if [ "$(uname -m)" != "ppc64le" ]; then
    echo "Warning: Not running on ppc64le - cross-compile mode"
fi

# Install dependencies
echo "Installing build dependencies..."
apt-get update
apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev \
    bc kmod cpio dpkg-dev debhelper

# Get kernel source
echo "Getting Debian kernel source..."
apt-get source linux

cd linux-${KERNEL_VERSION}*/

# Copy existing config as base
if [ -f /boot/config-$(uname -r) ]; then
    cp /boot/config-$(uname -r) .config
else
    echo "Using default ppc64le config"
    make defconfig
fi

# Enable HSA_AMD and dependencies
echo "Enabling HSA_AMD..."
scripts/config --enable CONFIG_HSA_AMD
scripts/config --enable CONFIG_MMU_NOTIFIER
scripts/config --enable CONFIG_DRM_AMDGPU
scripts/config --module CONFIG_DRM_AMDGPU
scripts/config --enable CONFIG_DRM_AMDGPU_SI
scripts/config --enable CONFIG_DRM_AMDGPU_CIK
scripts/config --enable CONFIG_DRM_AMDGPU_USERPTR

# Disable problematic options for faster build
scripts/config --disable CONFIG_DEBUG_INFO_BTF
scripts/config --disable CONFIG_MODULE_SIG
scripts/config --disable CONFIG_SYSTEM_TRUSTED_KEYRING

# Update config
make olddefconfig

# Verify HSA_AMD is enabled
if grep -q "CONFIG_HSA_AMD=y" .config; then
    echo "✅ CONFIG_HSA_AMD=y confirmed"
else
    echo "❌ Failed to enable CONFIG_HSA_AMD"
    grep HSA_AMD .config
    exit 1
fi

# Build kernel package
echo "Building kernel (this takes 2-4 hours on POWER8)..."
make -j$(nproc) bindeb-pkg LOCALVERSION=${LOCALVERSION}

echo "=========================================="
echo "Build complete!"
echo "Kernel packages in parent directory:"
ls -la ../*.deb
echo "=========================================="
echo "Install with: dpkg -i ../linux-image-*${LOCALVERSION}*.deb"
