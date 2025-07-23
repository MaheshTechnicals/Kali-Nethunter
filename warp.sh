#!/bin/bash

# ┌────────────────────────────────────────────┐
# │               WARP AI IDE                 │
# │       Installer & Uninstaller Script       │
# │         by Mahesh Technicals 🛠️           │
# └────────────────────────────────────────────┘

# Color codes
RED='\033[0;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

# Banner
clear
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════╗"
echo "║               🌌  W A R P   A I  I D E         ║"
echo "║          Stylish Installer for Linux 💻        ║"
echo "║           Script by Mahesh Technicals 🛠️       ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to install Warp
install_warp() {
    echo -e "${YELLOW}🔄 Updating system...${NC}"
    sudo apt update && sudo apt upgrade -y

    ARCH=$(uname -m)
    echo -e "${CYAN}🔍 Detected architecture: $ARCH${NC}"

    if [[ "$ARCH" == "x86_64" ]]; then
        URL="https://app.warp.dev/download?package=deb"
        FILE="warp_amd64.deb"
    elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
        URL="https://app.warp.dev/download?package=deb_arm64"
        FILE="warp_arm64.deb"
    else
        echo -e "${RED}❌ Unsupported architecture: $ARCH${NC}"
        exit 1
    fi

    echo -e "${GREEN}🌐 Downloading Warp IDE...${NC}"
    curl -L "$URL" -o "$FILE"

    echo -e "${CYAN}📦 Installing Warp...${NC}"
    sudo dpkg -i "$FILE"

    echo -e "${GREEN}✅ Warp installed successfully!${NC}"
    echo -e "${YELLOW}🚀 You can launch it by typing: warp${NC}"

    rm -f "$FILE"
}

# Function to uninstall Warp
uninstall_warp() {
    echo -e "${RED}⚠️ Uninstalling Warp IDE...${NC}"
    sudo apt remove --purge warp-terminal -y
    echo -e "${GREEN}✅ Warp has been removed.${NC}"
}

# Menu
echo -e "${CYAN}"
echo "Choose an option:"
echo -e "${NC}"
echo "1. 🚀 Install Warp"
echo "2. 🗑️  Uninstall Warp"
echo "3. ❌ Exit"
echo
read -p "Enter your choice [1/2/3]: " choice

case "$choice" in
    1)
        install_warp
        ;;
    2)
        uninstall_warp
        ;;
    3)
        echo -e "${YELLOW}👋 Exiting... Thank you!${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Invalid choice! Exiting.${NC}"
        exit 1
        ;;
esac
