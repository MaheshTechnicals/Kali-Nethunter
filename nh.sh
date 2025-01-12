#!/bin/bash

# Script version
SCRIPT_VERSION="1.0"

echo "Starting Kali NetHunter setup (Version: $SCRIPT_VERSION)..."

# Define architecture (set based on your architecture)
ARCH=$(uname -m)

# The directory for Kali NetHunter installation
KALI_NETHUNTER_DIR="$HOME/kali-nethunter"

# The URL for the appropriate rootfs based on architecture
ROOTFS_URL_AMD64="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-amd64.tar.xz"
ROOTFS_URL_ARM64="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz"
ROOTFS_URL_ARMHF="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-armhf.tar.xz"
ROOTFS_URL_I386="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-i386.tar.xz"

# Download the appropriate rootfs based on architecture
echo "Downloading Kali NetHunter rootfs..."

case "$ARCH" in
    "x86_64")
        ROOTFS_URL="$ROOTFS_URL_AMD64"
        ;;
    "aarch64")
        ROOTFS_URL="$ROOTFS_URL_ARM64"
        ;;
    "armv7l")
        ROOTFS_URL="$ROOTFS_URL_ARMHF"
        ;;
    "i686")
        ROOTFS_URL="$ROOTFS_URL_I386"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Create the Kali NetHunter directory if it doesn't exist
mkdir -p "$KALI_NETHUNTER_DIR"

# Download and extract the rootfs
echo "Extracting rootfs..."
wget -O "$KALI_NETHUNTER_DIR/rootfs.tar.xz" "$ROOTFS_URL"
tar -xJf "$KALI_NETHUNTER_DIR/rootfs.tar.xz" -C "$KALI_NETHUNTER_DIR"

# Fix missing directories and binaries
echo "Fixing missing directories and binaries..."
mkdir -p "$KALI_NETHUNTER_DIR/usr/bin"
mkdir -p "$KALI_NETHUNTER_DIR/usr/lib"
mkdir -p "$KALI_NETHUNTER_DIR/bin"
mkdir -p "$KALI_NETHUNTER_DIR/lib"

# Create fallback for /bin/bash and /usr/bin/env
echo "Creating fallback for /bin/bash and /usr/bin/env..."
echo -e "#!/bin/sh\nexit 0" > "$KALI_NETHUNTER_DIR/bin/bash"
chmod +x "$KALI_NETHUNTER_DIR/bin/bash"
echo -e "#!/bin/sh\nexit 0" > "$KALI_NETHUNTER_DIR/usr/bin/env"
chmod +x "$KALI_NETHUNTER_DIR/usr/bin/env"

# Setting up QEMU for ARM64/ARM emulation if necessary
if [ "$ARCH" != "x86_64" ]; then
    echo "Setting up QEMU for ARM64/ARM emulation..."
    mkdir -p "$KALI_NETHUNTER_DIR/usr/bin"
    # Manually download the correct QEMU binary for ARM64
    wget -O "$KALI_NETHUNTER_DIR/usr/bin/qemu-aarch64-static" "https://github.com/multiarch/qemu-user-static/releases/download/v7.2.0-1/qemu-aarch64-static"
    chmod +x "$KALI_NETHUNTER_DIR/usr/bin/qemu-aarch64-static"
    echo "QEMU setup complete"
fi

# Install GUI and VNC server
echo "Installing GUI and VNC server..."

# Installing required packages (you can modify to suit your needs)
chroot "$KALI_NETHUNTER_DIR" apt-get update
chroot "$KALI_NETHUNTER_DIR" apt-get install -y xorg openbox tightvncserver

# Set up VNC resolution to 4K
echo "Setting VNC resolution to 4K..."
echo "#!/bin/bash" > "$KALI_NETHUNTER_DIR/usr/local/bin/vncstart"
echo "export DISPLAY=:1" >> "$KALI_NETHUNTER_DIR/usr/local/bin/vncstart"
echo "tightvncserver :1 -geometry 3840x2160" >> "$KALI_NETHUNTER_DIR/usr/local/bin/vncstart"
chmod +x "$KALI_NETHUNTER_DIR/usr/local/bin/vncstart"

# Set up VNC stop command
echo "#!/bin/bash" > "$KALI_NETHUNTER_DIR/usr/local/bin/vncstop"
echo "vncserver -kill :1" >> "$KALI_NETHUNTER_DIR/usr/local/bin/vncstop"
chmod +x "$KALI_NETHUNTER_DIR/usr/local/bin/vncstop"

# Finish setup
echo "NetHunter setup complete. You can now start the environment with the following command:"
echo "  proot -S $KALI_NETHUNTER_DIR /bin/bash"

# Clean up
rm -f "$KALI_NETHUNTER_DIR/rootfs.tar.xz"

echo "Installation complete!"

