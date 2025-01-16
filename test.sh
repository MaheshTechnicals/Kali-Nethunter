#!/bin/bash

# Check system architecture (64-bit or 32-bit)
ARCHITECTURE=$(uname -m)
echo "Detected architecture: $ARCHITECTURE"

# Define the base URL for Kali NetHunter rootfs
BASE_URL="https://kali.download/nethunter-images/kali-2024.2/rootfs/"

# Choose the correct rootfs based on architecture
if [ "$ARCHITECTURE" == "aarch64" ]; then
    ROOTFS_URL="${BASE_URL}kali-linux-2024.2-arm64.tar.xz"
    echo "Downloading 64-bit (arm64) rootfs..."
elif [ "$ARCHITECTURE" == "armv7l" ]; then
    ROOTFS_URL="${BASE_URL}kali-linux-2024.2-armhf.tar.xz"
    echo "Downloading 32-bit (armhf) rootfs..."
else
    echo "Unsupported architecture: $ARCHITECTURE"
    exit 1
fi

# Download the rootfs file
wget -O /data/data/com.termux/files/home/kali-rootfs.tar.xz $ROOTFS_URL

# Install required dependencies
pkg update && pkg upgrade -y
pkg install -y wget proot tar git

# Extract the rootfs to the home directory
echo "Extracting Kali NetHunter rootfs..."
proot --link2symlink tar -xf /data/data/com.termux/files/home/kali-rootfs.tar.xz -C /data/data/com.termux/files/home

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

