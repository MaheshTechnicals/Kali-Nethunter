#!/bin/bash
# Kali NetHunter Installer Script v1.9 (With Correct QEMU URL)
# Author: Mahesh
# Email: help@maheshtechnicals.com

set -e

# Function to detect architecture
detect_architecture() {
    case $(uname -m) in
        aarch64) echo "arm64";;
        arm*) echo "armhf";;
        x86_64) echo "amd64";;
        i*86) echo "i386";;
        *) echo "Unsupported architecture"; exit 1;;
    esac
}

# Install required Termux packages
echo "Installing required packages..."
pkg update -y && pkg upgrade -y
pkg install wget tar proot proot-distro curl qemu-user-static -y

# Check for architecture
ARCH=$(detect_architecture)
echo "Detected architecture: $ARCH"

# Define rootfs download URLs
declare -A ROOTFS_URLS
ROOTFS_URLS=(
    [amd64]="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-amd64.tar.xz"
    [arm64]="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz"
    [armhf]="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-armhf.tar.xz"
    [i386]="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-i386.tar.xz"
)

# Download and extract rootfs
ROOTFS_URL=${ROOTFS_URLS[$ARCH]}
echo "Downloading rootfs for architecture: $ARCH"
mkdir -p ~/kali-nethunter
cd ~/kali-nethunter
wget -O rootfs.tar.xz "$ROOTFS_URL"

echo "Extracting rootfs..."
proot --link2symlink tar -xJf rootfs.tar.xz --exclude='dev' -C ~/kali-nethunter
rm rootfs.tar.xz

# Fix missing directories and binaries
echo "Fixing missing directories and binaries..."
mkdir -p ~/kali-nethunter/{root,proc,sys,dev,tmp,run,var/tmp}
mkdir -p ~/kali-nethunter/bin ~/kali-nethunter/usr/bin ~/kali-nethunter/lib ~/kali-nethunter/lib64

# Create fallback for /bin/bash
echo "Creating fallback for /bin/bash..."
cat > ~/kali-nethunter/bin/bash << 'EOF'
#!/bin/sh
exec /usr/bin/env bash "$@"
EOF
chmod +x ~/kali-nethunter/bin/bash

# Add a simple /usr/bin/env
echo "Adding fallback for /usr/bin/env..."
cat > ~/kali-nethunter/usr/bin/env << 'EOF'
#!/bin/sh
exec "$@"
EOF
chmod +x ~/kali-nethunter/usr/bin/env

# QEMU Setup for ARM64 if necessary
if [ "$ARCH" != "amd64" ]; then
    echo "Setting up QEMU for ARM64/ARM emulation..."
    mkdir -p ~/kali-nethunter/usr/bin
    # Download the correct QEMU binary from the provided URL
    wget -O ~/kali-nethunter/usr/bin/qemu-aarch64-static "https://github.com/multiarch/qemu-user-static/releases/download/v7.2.0-1/qemu-aarch64-static"
    chmod +x ~/kali-nethunter/usr/bin/qemu-aarch64-static
    echo "QEMU setup complete"
fi

# Unset LD_PRELOAD (fix interference from Termux)
unset LD_PRELOAD

# Initialize rootfs with basic packages to ensure proper environment
echo "Initializing rootfs with basic packages..."
proot --link2symlink -0 -r ~/kali-nethunter -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /bin/bash << "EOC"
apt update && apt install -y coreutils bash wget curl binutils
exit
EOC

# Create start script for NetHunter
echo "Creating start script for NetHunter..."
cat > start-nethunter.sh << 'EOF'
#!/bin/bash
unset LD_PRELOAD
cd ~/kali-nethunter
proot --link2symlink -0 -r ~/kali-nethunter -b /dev -b /proc -b /sys -b /data/data/com.termux/files/home:/root -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login
EOF
chmod +x start-nethunter.sh

# Install GUI and VNC server inside NetHunter
echo "Installing GUI and VNC server..."
./start-nethunter.sh << 'EOF'
apt update && apt upgrade -y
apt install -y xfce4 xfce4-goodies tightvncserver dbus-x11 kali-defaults kali-root-login
echo "export DISPLAY=:1" >> ~/.bashrc
echo "alias vncstart='vncserver :1 -geometry 3840x2160 -depth 16 -localhost no'" >> ~/.bashrc
echo "alias vncstop='vncserver -kill :1'" >> ~/.bashrc
vncserver :1 -geometry 3840x2160 -depth 16 -localhost no
EOF

echo "Installation complete!"
echo "To start NetHunter, run: ./start-nethunter.sh"
echo "Inside NetHunter, use the following commands:"
echo "  vncstart - to start the VNC server"
echo "  vncstop  - to stop the VNC server"

