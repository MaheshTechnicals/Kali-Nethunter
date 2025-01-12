#!/bin/bash

# Exit on any error
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

# Install required packages
echo "Installing required packages..."
pkg update -y
pkg upgrade -y
pkg install wget tar proot-distro proot openssh curl -y

# Detect architecture
ARCH=$(detect_architecture)
echo "Detected architecture: $ARCH"

# Define download URLs
declare -A ROOTFS_URLS
ROOTFS_URLS=(
    [amd64]="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-amd64.tar.xz"
    [arm64]="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz"
    [armhf]="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-armhf.tar.xz"
    [i386]="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-i386.tar.xz"
)

# Download and extract rootfs
ROOTFS_URL=${ROOTFS_URLS[$ARCH]}
echo "Downloading rootfs from: $ROOTFS_URL"
mkdir -p ~/kali-nethunter
cd ~/kali-nethunter
wget -O rootfs.tar.xz "$ROOTFS_URL"

echo "Extracting rootfs..."
proot --link2symlink tar -xJf rootfs.tar.xz --exclude='dev' -C ~/kali-nethunter
rm rootfs.tar.xz

# Set up NetHunter
echo "Setting up NetHunter..."
cat > start-nethunter.sh << 'EOF'
#!/bin/bash
cd ~/kali-nethunter
proot --link2symlink -0 -r ~/kali-nethunter -b /dev -b /proc -b /sys -w /root /usr/bin/env -i HOME=/root TERM="$TERM" LANG=C.UTF-8 PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login
EOF
chmod +x start-nethunter.sh

# Install GUI and VNC server inside NetHunter
echo "Installing GUI and VNC server..."
./start-nethunter.sh << 'EOF'
apt update && apt upgrade -y
apt install xfce4 xfce4-goodies tightvncserver dbus-x11 kali-defaults kali-root-login -y

# Add VNC aliases
echo "export DISPLAY=:1" >> ~/.bashrc
echo "alias vncstart='vncserver :1 -geometry 3840x2160 -depth 16 -localhost no'" >> ~/.bashrc
echo "alias vncstop='vncserver -kill :1'" >> ~/.bashrc

# Start the VNC server for initial setup
vncserver :1 -geometry 3840x2160 -depth 16 -localhost no
EOF

echo "Installation complete!"
echo "To start NetHunter, run: ./start-nethunter.sh"
echo "Inside NetHunter, use the following commands:"
echo "  vncstart - to start the VNC server"
echo "  vncstop  - to stop the VNC server"

