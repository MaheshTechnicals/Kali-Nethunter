#!/bin/bash

# Check system architecture (64-bit or 32-bit)
ARCHITECTURE=$(uname -m)
echo "Detected architecture: $ARCHITECTURE"

# Define the base URL for Kali NetHunter rootfs (updated URL)
BASE_URL="https://kali.download/nethunter-images/kali-2024.2/rootfs/"

# Choose the correct rootfs based on architecture
if [ "$ARCHITECTURE" == "x86_64" ]; then
    ROOTFS_URL="${BASE_URL}kalifs-amd64-full.tar.xz"
    echo "Downloading 64-bit (amd64) rootfs..."
elif [ "$ARCHITECTURE" == "aarch64" ]; then
    ROOTFS_URL="${BASE_URL}kalifs-arm64-full.tar.xz"
    echo "Downloading 64-bit (arm64) rootfs..."
else
    echo "Unsupported architecture: $ARCHITECTURE"
    exit 1
fi

# Define the location of the rootfs file
ROOTFS_FILE="/data/data/com.termux/files/home/kali-rootfs.tar.xz"
KALI_DIR="/data/data/com.termux/files/home/kali-arm64"

# Check if the rootfs file already exists
if [ -f "$ROOTFS_FILE" ]; then
    echo "Rootfs file already exists. Proceeding with extraction if needed..."
else
    # Download the rootfs file if not already present
    echo "Downloading Kali NetHunter rootfs..."
    wget -O $ROOTFS_FILE $ROOTFS_URL
fi

# Check if the rootfs has already been extracted
if [ -d "$KALI_DIR" ]; then
    echo "Kali NetHunter rootfs already extracted. Skipping extraction..."
else
    # Install required dependencies
    pkg update && pkg upgrade -y
    pkg install -y wget proot tar git x11-repo

    # Extract the rootfs to the home directory using proot to avoid permission issues
    echo "Extracting Kali NetHunter rootfs..."
    proot --link2symlink tar --exclude='*/dev/*' -xf $ROOTFS_FILE -C /data/data/com.termux/files/home/kali-arm64 --no-same-owner
fi

# Set up the Kali NetHunter environment
mkdir -p /data/data/com.termux/files/home/kali-arm64

# Create the 'nh' start script
cat > /data/data/com.termux/files/home/nh << 'EOF'
#!/bin/bash
# Unset LD_PRELOAD to bypass termux-exec conflict
unset LD_PRELOAD

# Set correct path to proot and environment
export PATH=/data/data/com.termux/files/usr/bin:$PATH

# Start Kali NetHunter with proot
proot -S /data/data/com.termux/files/home/kali-arm64 /bin/bash
EOF
chmod +x /data/data/com.termux/files/home/nh

# Create 'nh -r' for root access
cat > /data/data/com.termux/files/home/nh-r << 'EOF'
#!/bin/bash
# Unset LD_PRELOAD to bypass termux-exec conflict
unset LD_PRELOAD

# Set correct path to proot and environment
export PATH=/data/data/com.termux/files/usr/bin:$PATH

# Start Kali NetHunter with root access
proot -S /data/data/com.termux/files/home/kali-arm64 /bin/bash --login
EOF
chmod +x /data/data/com.termux/files/home/nh-r

# Create 'kex' script to start VNC
cat > /data/data/com.termux/files/home/kex << 'EOF'
#!/bin/bash
# Unset LD_PRELOAD to bypass termux-exec conflict
unset LD_PRELOAD

# Set correct path to proot and environment
export PATH=/data/data/com.termux/files/usr/bin:$PATH

# Start the Kali NetHunter VNC server (Kali Desktop)
vncserver :1 -geometry 1280x800
echo "VNC started. Connect to localhost:5901"
EOF
chmod +x /data/data/com.termux/files/home/kex

# Create 'kex stop' script to stop VNC
cat > /data/data/com.termux/files/home/kex-stop << 'EOF'
#!/bin/bash
# Unset LD_PRELOAD to bypass termux-exec conflict
unset LD_PRELOAD

# Set correct path to proot and environment
export PATH=/data/data/com.termux/files/usr/bin:$PATH

# Stop the Kali NetHunter VNC server
vncserver -kill :1
echo "VNC server stopped."
EOF
chmod +x /data/data/com.termux/files/home/kex-stop

echo "Kali NetHunter installation completed. Use the following commands to manage NetHunter:"
echo "nh      - Start Kali NetHunter"
echo "nh -r   - Start Kali NetHunter with root access"
echo "kex &   - Start VNC server (Kali Desktop)"
echo "kex stop - Stop VNC server"

