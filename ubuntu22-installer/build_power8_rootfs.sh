#!/bin/bash
# Ubuntu 22.04 for POWER8 Build Script
# Uses Debian as base since it still supports POWER8

set -e
BUILDDIR="$HOME/ubuntu22-power8-build"
ROOTFS="$BUILDDIR/rootfs-jammy-power8"

echo "=== Step 1: Create Debian Bookworm base (POWER8 compatible) ==="
# Debian bookworm still supports power8
sudo debootstrap --arch=ppc64el bookworm "$ROOTFS" http://deb.debian.org/debian

echo "=== Step 2: Configure for Ubuntu compatibility ==="
# Add Ubuntu repos but keep Debian glibc
sudo chroot "$ROOTFS" /bin/bash -c "
cat > /etc/apt/sources.list << EOF
# Debian base (POWER8 compatible glibc)
deb http://deb.debian.org/debian bookworm main contrib non-free
deb http://deb.debian.org/debian bookworm-updates main contrib non-free

# Ubuntu universe (for additional packages)
# deb http://ports.ubuntu.com/ubuntu-ports jammy universe
EOF
apt update
apt install -y locales-all
"

echo "=== Step 3: Create Docker image ==="
sudo tar -C "$ROOTFS" -c . | docker import - ubuntu-power8:22.04-compat

echo "Done! Test with: docker run --rm ubuntu-power8:22.04-compat uname -m"
