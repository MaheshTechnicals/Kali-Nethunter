#!/bin/bash
# Kali NetHunter Installer Script v1.1
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

# Install required packages
echo "Installing required packages..."
pkg update -y
pkg upgrade -y
pkg install wget tar proot proot-distro curl -y

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

# Fix missing directories and binaries
echo "Fixing missing directories and binaries..."
mkdir -p ~/kali-nethunter/{root,proc,sys,dev,tmp,run,var/tmp,usr/bin}
touch ~/kali-nethunter/usr/bin/env
chmod +x ~/kali-nethunter/usr/bin/env

# Add a fallback for `env` to avoid issues
cat > ~/kali-nethunter/usr/bin/env << 'EOF'
#!/bin/bash
exec "$@"
EOF

# Bind required directories and set up environment
cat > ~/kali-nethunter-fix.sh << 'EOF'
#!/bin/bash
cd ~/kali-nethunter
proot --link2symlink -0 -r ~/kali-nethunter -b /dev -b /proc -b /sys -b /tmp -b /data/data/com.termux/files/home:/root -w /root /bin/bash << "EOC"
# Install essential packages
apt update && apt install -y coreutils binutils curl wget

# Recreate the missing env file properly
echo "Restoring /usr/bin/env..."
rm -f /usr/bin/env
apt install -y coreutils

# Exit from the fix script
exit
EOC
EOF

chmod +x ~/kali-nethunter-fix.sh
echo "Running fix script to resolve '/usr/bin/env' issue..."
~/kali-nethunter-fix.sh

# Create the start script
echo "Setting up NetHunter start script..."
cat > start-nethunter.sh << 'EOF'
#!/bin/bash
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

# Cleanup
rm -f ~/kali-nethunter-fix.sh

echo "Installation complete!"
echo "To start NetHunter, run: ./start-nethunter.sh"
echo "Inside NetHunter, use the following commands:"
echo "  vncstart - to start the VNC server"
echo "  vncstop  - to stop the VNC server"

