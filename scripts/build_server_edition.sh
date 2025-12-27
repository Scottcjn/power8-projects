#!/bin/bash
set -e

echo "=========================================="
echo " PowerElyan Server Edition Builder"
echo "=========================================="

ROOTFS="rootfs-server"
ISO_DIR="iso-server"

# Clean previous
sudo rm -rf $ROOTFS $ISO_DIR

# Debootstrap fresh
echo "[1/5] Creating base system with debootstrap..."
sudo debootstrap --arch=ppc64el bookworm $ROOTFS http://deb.debian.org/debian

# Mount for chroot
sudo mount --bind /dev $ROOTFS/dev
sudo mount --bind /proc $ROOTFS/proc
sudo mount --bind /sys $ROOTFS/sys
sudo cp /etc/resolv.conf $ROOTFS/etc/

# Install packages
echo "[2/5] Installing server packages..."
sudo chroot $ROOTFS /bin/bash << "CHROOT"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
    systemd systemd-sysv dbus udev init login passwd sudo \
    apt apt-utils aptitude dpkg software-properties-common gnupg ca-certificates \
    openssh-server openssh-client network-manager iproute2 iputils-ping net-tools \
    ifupdown isc-dhcp-client netcat-openbsd dnsutils curl wget rsync nfs-common \
    openvpn \
    iptables nftables ufw fail2ban apparmor openssl \
    e2fsprogs xfsprogs btrfs-progs dosfstools lvm2 mdadm cryptsetup parted gdisk \
    vim nano bash bash-completion zsh tmux screen \
    build-essential gcc g++ make cmake git python3 python3-pip python3-venv \
    numactl libnuma-dev \
    docker.io \
    sqlite3 postgresql mariadb-server redis-server \
    nginx \
    htop iotop sysstat ncdu lsof procps \
    cron logrotate rsyslog chrony tree zip unzip xz-utils tar gzip \
    lshw smartmontools hdparm pciutils usbutils man-db \
    linux-image-powerpc64le live-boot

# Create user
useradd -m -s /bin/bash -G sudo,docker powerelyan
echo "powerelyan:powerelyan" | chpasswd
echo "root:powerelyan" | chpasswd

# Branding
echo "PowerElyan Server 1.0" > /etc/powerelyan-release
echo "powerelyan-server" > /etc/hostname
CHROOT

# Unmount
sudo umount $ROOTFS/dev $ROOTFS/proc $ROOTFS/sys 2>/dev/null || true

# Copy llama.cpp
echo "[3/5] Adding llama.cpp with PSE..."
sudo mkdir -p $ROOTFS/home/powerelyan/llama.cpp
sudo cp -r ~/llama.cpp/build-pse-collapse $ROOTFS/home/powerelyan/llama.cpp/
sudo chown -R 1000:1000 $ROOTFS/home/powerelyan/

# Build ISO
echo "[4/5] Creating squashfs..."
mkdir -p $ISO_DIR/{boot/grub,live}
sudo mksquashfs $ROOTFS $ISO_DIR/live/filesystem.squashfs -comp xz -noappend

sudo cp $ROOTFS/boot/vmlinux-* $ISO_DIR/live/vmlinuz
sudo cp $ROOTFS/boot/initrd.img-* $ISO_DIR/live/initrd.img

cat > $ISO_DIR/boot/grub/grub.cfg << "GRUB"
set timeout=10
set default=0
menuentry "PowerElyan Server 1.0 (Live)" {
    linux /live/vmlinuz boot=live toram quiet
    initrd /live/initrd.img
}
menuentry "PowerElyan Server 1.0 (Install)" {
    linux /live/vmlinuz boot=live toram installer
    initrd /live/initrd.img
}
GRUB

echo "[5/5] Building ISO..."
sudo xorriso -as mkisofs \
    -o powerelyan-server-1.0-ppc64le.iso \
    -R -J -V "PowerElyan_Server" \
    $ISO_DIR/

echo "=========================================="
echo " Server Edition Complete!"
ls -lh powerelyan-server-1.0-ppc64le.iso
echo "=========================================="
