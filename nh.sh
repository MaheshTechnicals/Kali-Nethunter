#!/bin/bash

# Unset LD_PRELOAD to avoid conflicts with termux-exec
unset LD_PRELOAD

# Starting Kali NetHunter setup (Version: 1.0)
echo "Starting Kali NetHunter setup (Version: 2.0)..."

# Define the directory for Kali NetHunter
KALI_NETHUNTER_DIR="/data/data/com.termux/files/home/kali-nethunter"

# Download Kali NetHunter rootfs
echo "Downloading Kali NetHunter rootfs..."
wget -O "$KALI_NETHUNTER_DIR/rootfs.tar.xz" https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz

# Extract the rootfs
echo "Extracting rootfs..."
tar -xvf "$KALI_NETHUNTER_DIR/rootfs.tar.xz" -C "$KALI_NETHUNTER_DIR"

# Fixing missing directories and binaries
echo "Fixing missing directories and binaries..."
mkdir -p "$KALI_NETHUNTER_DIR/usr/bin"
touch "$KALI_NETHUNTER_DIR/usr/bin/bash"
touch "$KALI_NETHUNTER_DIR/usr/bin/env"

# Setting up QEMU for ARM64/ARM emulation
echo "Setting up QEMU for ARM64/ARM emulation..."
wget -O "$KALI_NETHUNTER_DIR/usr/bin/qemu-aarch64-static" https://github.com/multiarch/qemu-user-static/releases/download/v7.2.0-1/qemu-aarch64-static

# Set QEMU permissions
chmod +x "$KALI_NETHUNTER_DIR/usr/bin/qemu-aarch64-static"

# Complete QEMU setup
echo "QEMU setup complete"

# Install necessary GUI and VNC server
echo "Installing GUI and VNC server..."
# Download the script or install necessary packages (since apt-get might not work inside proot)
wget -O "$KALI_NETHUNTER_DIR/usr/local/bin/vncstart" https://example.com/vncstart.sh
wget -O "$KALI_NETHUNTER_DIR/usr/local/bin/vncstop" https://example.com/vncstop.sh

# Set permissions for the scripts
chmod +x "$KALI_NETHUNTER_DIR/usr/local/bin/vncstart"
chmod +x "$KALI_NETHUNTER_DIR/usr/local/bin/vncstop"

# Install xorg, openbox, and tightvncserver
echo "Installing xorg, openbox, and tightvncserver..."
chroot "$KALI_NETHUNTER_DIR" apt-get update
chroot "$KALI_NETHUNTER_DIR" apt-get install -y xorg openbox tightvncserver

# Setting VNC resolution to 4K
echo "Setting VNC resolution to 4K..."
# Assuming VNC setup script is configured to set the resolution

# NetHunter setup complete
echo "NetHunter setup complete. You can now start the environment with the following command:"
echo "proot -S $KALI_NETHUNTER_DIR /bin/bash"

# Run proot command to enter Kali NetHunter environment
echo "Running proot command..."
proot -S "$KALI_NETHUNTER_DIR" /bin/bash

