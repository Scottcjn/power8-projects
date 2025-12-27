#!/bin/bash
# PowerElyan Linux - Master Build Script
# Build a complete POWER8-compatible Linux distribution

set -e

echo ""
cat << "LOGO"
  ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███████╗██╗  ██╗   ██╗ █████╗ ███╗   ██╗
  ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝██║  ╚██╗ ██╔╝██╔══██╗████╗  ██║
  ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝█████╗  ██║   ╚████╔╝ ███████║██╔██╗ ██║
  ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██╔══╝  ██║    ╚██╔╝  ██╔══██║██║╚██╗██║
  ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║███████╗███████╗██║   ██║  ██║██║ ╚████║
  ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
                              Build System v1.0
                              by Elyan Labs
LOGO
echo ""

VERSION="1.0"
BUILD_DIR="$HOME/powerelyan-build"
ROOTFS_DIR="$BUILD_DIR/rootfs"
ISO_DIR="$BUILD_DIR/iso"

usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  rootfs    - Build base rootfs from Debian Bookworm"
    echo "  docker    - Build Docker image"
    echo "  iso       - Build bootable ISO installer"
    echo "  all       - Build everything"
    echo "  clean     - Clean build directory"
    echo ""
}

build_rootfs() {
    echo "[PowerElyan] Building rootfs..."
    mkdir -p "$ROOTFS_DIR"
    
    # Debootstrap Debian Bookworm (POWER8 compatible)
    sudo debootstrap --arch=ppc64el bookworm "$ROOTFS_DIR" http://deb.debian.org/debian
    
    # PowerElyan customization
    sudo chroot "$ROOTFS_DIR" /bin/bash << "CHROOT"
    # Set hostname
    echo "powerelyan" > /etc/hostname
    
    # Create PowerElyan release file
    cat > /etc/powerelyan-release << RELEASE
PowerElyan Linux 1.0
Based on Debian GNU/Linux 12 (bookworm)
Built for IBM POWER8 Systems
https://github.com/Scottcjn/power8-projects

Copyright (c) 2025 Elyan Labs
RELEASE
    
    # Install essential packages
    apt update
    apt install -y \
        linux-image-powerpc64le \
        grub2 \
        openssh-server \
        sudo \
        vim nano \
        htop \
        git curl wget \
        build-essential \
        python3 python3-pip
    
    # Create default user
    useradd -m -s /bin/bash -G sudo powerelyan
    echo "powerelyan:powerelyan" | chpasswd
    
    # Enable SSH
    systemctl enable ssh
CHROOT
    
    echo "[PowerElyan] Rootfs complete: $ROOTFS_DIR"
}

build_docker() {
    echo "[PowerElyan] Building Docker image..."
    
    if [ -d "$ROOTFS_DIR" ]; then
        sudo tar -C "$ROOTFS_DIR" -c . | sudo docker import - powerelyan:$VERSION
        echo "[PowerElyan] Docker image: powerelyan:$VERSION"
    else
        echo "Error: Rootfs not found. Run: $0 rootfs"
        exit 1
    fi
}

build_iso() {
    echo "[PowerElyan] Building ISO installer..."
    mkdir -p "$ISO_DIR"
    
    # TODO: Create bootable ISO with yaboot/grub for POWER8
    echo "ISO build not yet implemented"
    echo "For now, use the Docker image or rootfs tarball"
}

clean() {
    echo "[PowerElyan] Cleaning build directory..."
    sudo rm -rf "$BUILD_DIR"
    echo "Done."
}

# Main
case "$1" in
    rootfs) build_rootfs ;;
    docker) build_docker ;;
    iso)    build_iso ;;
    all)    build_rootfs && build_docker && build_iso ;;
    clean)  clean ;;
    *)      usage ;;
esac
