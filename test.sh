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

# Download the rootfs file
echo "Downloading Kali NetHunter rootfs..."
wget -O /data/data/com.termux/files/home/kali-rootfs.tar.xz $ROOTFS_URL

# Install required dependencies
pkg update && pkg upgrade -y
pkg install -y wget proot tar git x11-repo

# Extract the rootfs to the home directory using proot to avoid permission issues
echo "Extracting Kali NetHunter rootfs..."
proot --link2symlink tar -xf /data/data/com.termux/files/home/kali-rootfs.tar.xz -C /data/data/com.termux/files/home --no-same-owner

# Set up the Kali NetHunter environment
mkdir -p /data/data/com.termux/files/home/kali

# Create the 'nh' start script
cat > /data/data/com.termux/files/home/nh << 'EOF'
#!/bin/bash
# Start Kali NetHunter with proot
proot -S /data/data/com.termux/files/home /bin/bash
EOF
chmod +x /data/data/com.termux/files/home/nh

# Create 'nh -r' for root access
cat > /data/data/com.termux/files/home/nh-r << 'EOF'
#!/bin/bash
# Start Kali NetHunter with root access
proot -S /data/data/com.termux/files/home /bin/bash --login
EOF
chmod +x /data/data/com.termux/files/home/nh-r

# Create 'kex' script to start VNC
cat > /data/data/com.termux/files/home/kex << 'EOF'
#!/bin/bash
# Start the Kali NetHunter VNC server (Kali Desktop)
vncserver :1 -geometry 1280x800
echo "VNC started. Connect to localhost:5901"
EOF
chmod +x /data/data/com.termux/files/home/kex

# Create 'kex stop' script to stop VNC
cat > /data/data/com.termux/files/home/kex-stop << 'EOF'
#!/bin/bash
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

