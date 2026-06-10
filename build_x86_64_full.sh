#!/bin/bash
# PowerElyan x86_64 Full Edition Build Script
# Creates a bootable USB image with MATE desktop
# By Elyan Labs

set -e

# === CONFIGURATION ===
EDITION="full"
ARCH="amd64"
VERSION="1.0"
BUILDDIR="$HOME/powerelyan-x86_64-build"
ROOTFS="$BUILDDIR/rootfs"
OUTPUT_IMG="$BUILDDIR/powerelyan-${EDITION}-${VERSION}-x86_64.img"
OUTPUT_ISO="$BUILDDIR/powerelyan-${EDITION}-${VERSION}-x86_64.iso"
IMG_SIZE="8G"  # 8GB image for Full edition

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

banner() {
    echo -e "${CYAN}"
    cat << "LOGO"
  ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███████╗██╗  ██╗   ██╗ █████╗ ███╗   ██╗
  ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝██║  ╚██╗ ██╔╝██╔══██╗████╗  ██║
  ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝█████╗  ██║   ╚████╔╝ ███████║██╔██╗ ██║
  ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██╔══╝  ██║    ╚██╔╝  ██╔══██║██║╚██╗██║
  ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║███████╗███████╗██║   ██║  ██║██║ ╚████║
  ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
                         x86_64 Full Edition Builder
LOGO
    echo -e "${NC}"
}

log() { echo -e "${GREEN}[PowerElyan]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

check_deps() {
    log "Checking dependencies..."
    local deps="debootstrap grub-pc-bin grub-efi-amd64-bin xorriso mtools squashfs-tools"
    for dep in $deps; do
        if ! dpkg -l | grep -q "^ii  $dep"; then
            warn "Installing $dep..."
            sudo apt-get install -y "$dep"
        fi
    done
}

create_image() {
    log "Creating ${IMG_SIZE} disk image..."
    mkdir -p "$BUILDDIR"

    # Create sparse image file
    truncate -s "$IMG_SIZE" "$OUTPUT_IMG"

    # Create partition table with EFI + root
    log "Creating GPT partition table..."
    sudo parted -s "$OUTPUT_IMG" mklabel gpt
    sudo parted -s "$OUTPUT_IMG" mkpart ESP fat32 1MiB 513MiB
    sudo parted -s "$OUTPUT_IMG" set 1 esp on
    sudo parted -s "$OUTPUT_IMG" mkpart primary ext4 513MiB 100%

    # Setup loop device
    LOOP=$(sudo losetup --find --show --partscan "$OUTPUT_IMG")
    log "Loop device: $LOOP"

    # Format partitions
    sudo mkfs.vfat -F 32 -n POWERELYAN "${LOOP}p1"
    sudo mkfs.ext4 -L powerelyan-root "${LOOP}p2"

    # Mount
    sudo mkdir -p "$ROOTFS"
    sudo mount "${LOOP}p2" "$ROOTFS"
    sudo mkdir -p "$ROOTFS/boot/efi"
    sudo mount "${LOOP}p1" "$ROOTFS/boot/efi"
}

bootstrap_system() {
    log "Bootstrapping Debian Bookworm (x86_64)..."
    sudo debootstrap --arch=amd64 bookworm "$ROOTFS" http://deb.debian.org/debian
}

configure_system() {
    log "Configuring system..."

    # Set hostname
    echo "powerelyan" | sudo tee "$ROOTFS/etc/hostname"

    # Set hosts
    cat << 'EOF' | sudo tee "$ROOTFS/etc/hosts"
127.0.0.1   localhost
127.0.1.1   powerelyan

::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

    # Create fstab
    cat << 'EOF' | sudo tee "$ROOTFS/etc/fstab"
# PowerElyan fstab
LABEL=powerelyan-root   /           ext4    defaults,noatime    0 1
LABEL=POWERELYAN        /boot/efi   vfat    umask=0077          0 1
tmpfs                   /tmp        tmpfs   defaults,noatime    0 0
EOF

    # Set locale
    echo "en_US.UTF-8 UTF-8" | sudo tee "$ROOTFS/etc/locale.gen"

    # Set timezone
    sudo ln -sf /usr/share/zoneinfo/America/Chicago "$ROOTFS/etc/localtime"

    # PowerElyan release info
    cat << EOF | sudo tee "$ROOTFS/etc/powerelyan-release"
PowerElyan Linux ${VERSION}
Edition: Full (MATE + extras)
Architecture: x86_64
Build Date: $(date -u +%Y-%m-%d)
Based on: Debian Bookworm
By: Elyan Labs
EOF

    # OS release
    cat << EOF | sudo tee "$ROOTFS/etc/os-release"
PRETTY_NAME="PowerElyan Linux ${VERSION} (Full)"
NAME="PowerElyan"
VERSION_ID="${VERSION}"
VERSION="${VERSION} (Full)"
VERSION_CODENAME=bookworm
ID=powerelyan
ID_LIKE=debian
HOME_URL="https://github.com/Scottcjn/power8-projects"
BUG_REPORT_URL="https://github.com/Scottcjn/power8-projects/issues"
EOF
}

install_packages() {
    log "Installing Full edition packages..."

    # Mount necessary filesystems
    sudo mount --bind /dev "$ROOTFS/dev"
    sudo mount --bind /dev/pts "$ROOTFS/dev/pts"
    sudo mount -t proc proc "$ROOTFS/proc"
    sudo mount -t sysfs sysfs "$ROOTFS/sys"

    # Copy resolv.conf for network
    sudo cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf"

    # Create package install script
    cat << 'CHROOT_SCRIPT' | sudo tee "$ROOTFS/tmp/install_packages.sh"
#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "=== Updating package lists ==="
apt-get update

echo "=== Installing kernel and bootloader ==="
apt-get install -y linux-image-amd64 grub-efi-amd64 grub-pc-bin

echo "=== Installing core packages ==="
apt-get install -y \
    systemd systemd-sysv dbus udev \
    apt apt-utils aptitude software-properties-common gnupg ca-certificates \
    locales locales-all sudo

echo "=== Generating locales ==="
locale-gen en_US.UTF-8

echo "=== Installing networking ==="
apt-get install -y \
    openssh-server openssh-client network-manager \
    iproute2 iputils-ping net-tools curl wget rsync \
    wireless-tools wpasupplicant

echo "=== Installing MATE Desktop ==="
apt-get install -y \
    mate-desktop-environment mate-desktop-environment-extras \
    lightdm lightdm-gtk-greeter \
    firefox-esr \
    mate-terminal caja pluma eom atril

echo "=== Installing development tools ==="
apt-get install -y \
    build-essential gcc g++ make cmake git \
    python3 python3-pip python3-venv python3-dev \
    vim nano htop neofetch tmux

echo "=== Installing editors ==="
apt-get install -y \
    vim vim-gtk3 nano neovim

echo "=== Installing shells ==="
apt-get install -y \
    bash bash-completion zsh fish

echo "=== Installing system tools ==="
apt-get install -y \
    htop btop iotop iftop ncdu lsof tree \
    zip unzip p7zip-full xz-utils \
    parted gdisk fdisk dosfstools ntfs-3g \
    smartmontools hdparm nvme-cli \
    lshw hwinfo dmidecode pciutils usbutils

echo "=== Installing multimedia ==="
apt-get install -y \
    ffmpeg vlc audacious gimp inkscape \
    pulseaudio pavucontrol

echo "=== Installing containers ==="
apt-get install -y docker.io docker-compose || true

echo "=== Installing RustChain dependencies ==="
apt-get install -y \
    python3-tk python3-pil python3-pil.imagetk \
    python3-requests python3-cryptography python3-nacl \
    libsodium23 \
    fonts-liberation

echo "=== Cleaning up ==="
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "=== Done installing packages ==="
CHROOT_SCRIPT

    sudo chmod +x "$ROOTFS/tmp/install_packages.sh"
    sudo chroot "$ROOTFS" /tmp/install_packages.sh
}

create_user() {
    log "Creating powerelyan user..."

    sudo chroot "$ROOTFS" /bin/bash -c "
        # Create user
        useradd -m -s /bin/bash -G sudo,adm,cdrom,audio,video,plugdev,netdev powerelyan
        echo 'powerelyan:powerelyan' | chpasswd

        # Allow sudo without password for initial setup
        echo 'powerelyan ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/powerelyan
        chmod 440 /etc/sudoers.d/powerelyan

        # Set root password
        echo 'root:powerelyan' | chpasswd
    "
}

install_branding() {
    log "Installing PowerElyan branding..."

    # MOTD banner
    cat << 'MOTD' | sudo tee "$ROOTFS/etc/profile.d/powerelyan-motd.sh"
#!/bin/bash
if [ -t 1 ]; then
    echo ""
    echo -e "\033[0;36m"
    cat << "LOGO"
  ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███████╗██╗  ██╗   ██╗ █████╗ ███╗   ██╗
  ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝██║  ╚██╗ ██╔╝██╔══██╗████╗  ██║
  ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝█████╗  ██║   ╚████╔╝ ███████║██╔██╗ ██║
  ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██╔══╝  ██║    ╚██╔╝  ██╔══██║██║╚██╗██║
  ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║███████╗███████╗██║   ██║  ██║██║ ╚████║
  ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
LOGO
    echo -e "\033[0m"
    echo "       PowerElyan Linux 1.0 - Full Edition (x86_64)"
    echo "       https://github.com/Scottcjn/power8-projects"
    echo ""
fi
MOTD
    sudo chmod +x "$ROOTFS/etc/profile.d/powerelyan-motd.sh"

    # LightDM greeter config
    sudo mkdir -p "$ROOTFS/etc/lightdm"
    cat << 'EOF' | sudo tee "$ROOTFS/etc/lightdm/lightdm-gtk-greeter.conf"
[greeter]
background=/usr/share/backgrounds/powerelyan.png
theme-name=Adwaita-dark
icon-theme-name=Adwaita
font-name=Sans 11
xft-antialias=true
xft-hintstyle=slight
EOF

    # Create a simple background (gradient)
    sudo mkdir -p "$ROOTFS/usr/share/backgrounds"
}

install_rustchain() {
    log "Installing RustChain components..."

    # Create RustChain directory
    sudo mkdir -p "$ROOTFS/opt/rustchain"
    sudo mkdir -p "$ROOTFS/usr/share/applications"
    sudo mkdir -p "$ROOTFS/usr/share/pixmaps"

    # Download RustChain miner
    log "Downloading RustChain miner..."
    sudo curl -L -o "$ROOTFS/opt/rustchain/rustchain_linux_miner.py" \
        "https://raw.githubusercontent.com/Scottcjn/Rustchain/main/miners/linux/rustchain_linux_miner.py" || \
        warn "Could not download miner (will need manual install)"

    # Download fingerprint checks
    sudo curl -L -o "$ROOTFS/opt/rustchain/fingerprint_checks.py" \
        "https://raw.githubusercontent.com/Scottcjn/Rustchain/main/miners/linux/fingerprint_checks.py" || true

    # Create RustChain Wallet GUI
    cat << 'WALLET_GUI' | sudo tee "$ROOTFS/opt/rustchain/rustchain_wallet_gui.py"
#!/usr/bin/env python3
"""
RustChain Wallet GUI for PowerElyan Linux
By Elyan Labs
"""
import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import json
import os
import hashlib
import requests
from datetime import datetime

class RustChainWallet:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("RustChain Wallet - PowerElyan Edition")
        self.root.geometry("800x600")
        self.root.configure(bg='#1a1a2e')

        self.api_url = "https://50.28.86.131"
        self.wallet_file = os.path.expanduser("~/.rustchain/wallet.json")
        self.wallet_data = self.load_wallet()

        self.setup_ui()

    def load_wallet(self):
        os.makedirs(os.path.dirname(self.wallet_file), exist_ok=True)
        if os.path.exists(self.wallet_file):
            with open(self.wallet_file) as f:
                return json.load(f)
        return {"wallets": [], "active": None}

    def save_wallet(self):
        with open(self.wallet_file, 'w') as f:
            json.dump(self.wallet_data, f, indent=2)

    def setup_ui(self):
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('TFrame', background='#1a1a2e')
        style.configure('TLabel', background='#1a1a2e', foreground='#eee')
        style.configure('TButton', padding=10)
        style.configure('Header.TLabel', font=('Helvetica', 24, 'bold'), foreground='#00d9ff')

        # Header
        header = ttk.Frame(self.root)
        header.pack(fill='x', padx=20, pady=20)

        ttk.Label(header, text="RustChain Wallet", style='Header.TLabel').pack(side='left')
        ttk.Label(header, text="PowerElyan Edition", foreground='#888').pack(side='left', padx=10)

        # Main content
        main = ttk.Frame(self.root)
        main.pack(fill='both', expand=True, padx=20)

        # Balance display
        bal_frame = ttk.Frame(main)
        bal_frame.pack(fill='x', pady=20)

        ttk.Label(bal_frame, text="Balance:", font=('Helvetica', 14)).pack(side='left')
        self.balance_var = tk.StringVar(value="Loading...")
        ttk.Label(bal_frame, textvariable=self.balance_var,
                  font=('Helvetica', 24, 'bold'), foreground='#00ff88').pack(side='left', padx=10)
        ttk.Label(bal_frame, text="RTC", font=('Helvetica', 14)).pack(side='left')

        # Wallet selector
        wallet_frame = ttk.Frame(main)
        wallet_frame.pack(fill='x', pady=10)

        ttk.Label(wallet_frame, text="Wallet:").pack(side='left')
        self.wallet_combo = ttk.Combobox(wallet_frame, width=40)
        self.wallet_combo.pack(side='left', padx=10)
        self.wallet_combo.bind('<<ComboboxSelected>>', self.on_wallet_change)

        ttk.Button(wallet_frame, text="New", command=self.new_wallet).pack(side='left', padx=5)
        ttk.Button(wallet_frame, text="Refresh", command=self.refresh_balance).pack(side='left')

        # Actions
        actions = ttk.Frame(main)
        actions.pack(fill='x', pady=20)

        ttk.Button(actions, text="Send RTC", command=self.send_rtc).pack(side='left', padx=5)
        ttk.Button(actions, text="Receive", command=self.show_address).pack(side='left', padx=5)
        ttk.Button(actions, text="History", command=self.show_history).pack(side='left', padx=5)
        ttk.Button(actions, text="Start Miner", command=self.start_miner).pack(side='left', padx=5)

        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        ttk.Label(self.root, textvariable=self.status_var,
                  foreground='#888').pack(side='bottom', fill='x', padx=20, pady=10)

        self.update_wallet_list()
        self.refresh_balance()

    def update_wallet_list(self):
        wallets = [w['name'] for w in self.wallet_data.get('wallets', [])]
        self.wallet_combo['values'] = wallets
        if wallets and self.wallet_data.get('active'):
            self.wallet_combo.set(self.wallet_data['active'])

    def on_wallet_change(self, event):
        self.wallet_data['active'] = self.wallet_combo.get()
        self.save_wallet()
        self.refresh_balance()

    def new_wallet(self):
        name = simpledialog.askstring("New Wallet", "Enter wallet name:")
        if name:
            wallet_id = f"{name.lower().replace(' ', '-')}-{hashlib.sha256(os.urandom(16)).hexdigest()[:8]}"
            self.wallet_data['wallets'].append({'name': name, 'id': wallet_id})
            self.wallet_data['active'] = name
            self.save_wallet()
            self.update_wallet_list()
            messagebox.showinfo("Wallet Created", f"Wallet ID:\n{wallet_id}")

    def get_active_wallet_id(self):
        active = self.wallet_data.get('active')
        for w in self.wallet_data.get('wallets', []):
            if w['name'] == active:
                return w['id']
        return None

    def refresh_balance(self):
        wallet_id = self.get_active_wallet_id()
        if not wallet_id:
            self.balance_var.set("0.000000")
            return

        try:
            self.status_var.set("Fetching balance...")
            resp = requests.get(f"{self.api_url}/wallet/balance/{wallet_id}",
                               timeout=10, verify=False)
            if resp.ok:
                data = resp.json()
                balance = data.get('balance_rtc', 0)
                self.balance_var.set(f"{balance:.6f}")
                self.status_var.set(f"Updated: {datetime.now().strftime('%H:%M:%S')}")
            else:
                self.balance_var.set("0.000000")
                self.status_var.set("Wallet not found (start mining to create)")
        except Exception as e:
            self.status_var.set(f"Error: {e}")

    def send_rtc(self):
        wallet_id = self.get_active_wallet_id()
        if not wallet_id:
            messagebox.showerror("Error", "No wallet selected")
            return

        to_addr = simpledialog.askstring("Send RTC", "Recipient wallet ID:")
        if not to_addr:
            return

        amount = simpledialog.askfloat("Send RTC", "Amount (RTC):")
        if not amount or amount <= 0:
            return

        # Confirmation
        if not messagebox.askyesno("Confirm", f"Send {amount} RTC to {to_addr}?"):
            return

        messagebox.showinfo("Info", "Signed transfers require wallet setup.\nUse the secure wallet for real transfers.")

    def show_address(self):
        wallet_id = self.get_active_wallet_id()
        if wallet_id:
            # Copy to clipboard
            self.root.clipboard_clear()
            self.root.clipboard_append(wallet_id)
            messagebox.showinfo("Your Wallet Address",
                               f"Wallet ID (copied to clipboard):\n\n{wallet_id}")
        else:
            messagebox.showinfo("Info", "Create a wallet first")

    def show_history(self):
        messagebox.showinfo("Transaction History",
                           "View full history at:\nhttps://50.28.86.131/explorer")

    def start_miner(self):
        import subprocess
        wallet_id = self.get_active_wallet_id()
        if not wallet_id:
            messagebox.showerror("Error", "Create a wallet first")
            return

        try:
            subprocess.Popen([
                'mate-terminal', '--', 'python3',
                '/opt/rustchain/rustchain_linux_miner.py',
                '--wallet', wallet_id
            ])
            self.status_var.set("Miner started in terminal")
        except Exception as e:
            messagebox.showerror("Error", f"Could not start miner: {e}")

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    import warnings
    warnings.filterwarnings('ignore')
    app = RustChainWallet()
    app.run()
WALLET_GUI

    sudo chmod +x "$ROOTFS/opt/rustchain/rustchain_wallet_gui.py"
    sudo chmod +x "$ROOTFS/opt/rustchain/rustchain_linux_miner.py" 2>/dev/null || true

    # Create desktop entry for wallet
    cat << 'EOF' | sudo tee "$ROOTFS/usr/share/applications/rustchain-wallet.desktop"
[Desktop Entry]
Name=RustChain Wallet
Comment=RustChain Token Wallet - PowerElyan Edition
Exec=python3 /opt/rustchain/rustchain_wallet_gui.py
Icon=wallet
Terminal=false
Type=Application
Categories=Finance;Network;
Keywords=crypto;wallet;rustchain;rtc;
EOF

    # Create desktop entry for miner
    cat << 'EOF' | sudo tee "$ROOTFS/usr/share/applications/rustchain-miner.desktop"
[Desktop Entry]
Name=RustChain Miner
Comment=Mine RTC tokens with Proof-of-Antiquity
Exec=mate-terminal -- python3 /opt/rustchain/rustchain_linux_miner.py
Icon=utilities-system-monitor
Terminal=false
Type=Application
Categories=Network;System;
Keywords=crypto;miner;rustchain;rtc;
EOF

    # Create miner wrapper script
    cat << 'EOF' | sudo tee "$ROOTFS/usr/local/bin/rustchain-miner"
#!/bin/bash
cd /opt/rustchain
python3 rustchain_linux_miner.py "$@"
EOF
    sudo chmod +x "$ROOTFS/usr/local/bin/rustchain-miner"

    # Create wallet wrapper
    cat << 'EOF' | sudo tee "$ROOTFS/usr/local/bin/rustchain-wallet"
#!/bin/bash
python3 /opt/rustchain/rustchain_wallet_gui.py "$@"
EOF
    sudo chmod +x "$ROOTFS/usr/local/bin/rustchain-wallet"

    log "RustChain components installed"
}

install_bootloader() {
    log "Installing GRUB bootloader..."

    sudo chroot "$ROOTFS" /bin/bash -c "
        # Install GRUB for EFI
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=PowerElyan --recheck

        # Generate GRUB config
        update-grub
    "

    # Custom GRUB theme
    cat << 'EOF' | sudo tee "$ROOTFS/etc/default/grub"
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="PowerElyan"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
EOF

    sudo chroot "$ROOTFS" update-grub
}

cleanup() {
    log "Cleaning up..."

    # Remove install script
    sudo rm -f "$ROOTFS/tmp/install_packages.sh"

    # Unmount filesystems
    sudo umount "$ROOTFS/dev/pts" 2>/dev/null || true
    sudo umount "$ROOTFS/dev" 2>/dev/null || true
    sudo umount "$ROOTFS/proc" 2>/dev/null || true
    sudo umount "$ROOTFS/sys" 2>/dev/null || true
    sudo umount "$ROOTFS/boot/efi" 2>/dev/null || true
    sudo umount "$ROOTFS" 2>/dev/null || true

    # Detach loop device
    if [ -n "$LOOP" ]; then
        sudo losetup -d "$LOOP" 2>/dev/null || true
    fi
}

main() {
    banner
    log "Building PowerElyan x86_64 Full Edition"
    log "Output: $OUTPUT_IMG"
    echo ""

    # Allow running as root or normal user
    if [ "$EUID" -eq 0 ]; then
        log "Running as root"
    fi

    check_deps

    # Clean previous build
    if [ -d "$BUILDDIR" ]; then
        warn "Cleaning previous build..."
        cleanup
        sudo rm -rf "$BUILDDIR"
    fi

    create_image
    bootstrap_system
    configure_system
    install_packages
    create_user
    install_branding
    install_rustchain
    install_bootloader
    cleanup

    log "Build complete!"
    log "Image: $OUTPUT_IMG"
    log ""
    log "To write to USB:"
    log "  sudo dd if=$OUTPUT_IMG of=/dev/sdX bs=4M status=progress"
    log ""
    log "Default credentials:"
    log "  Username: powerelyan"
    log "  Password: powerelyan"
}

# Trap for cleanup on error
trap cleanup EXIT

main "$@"
