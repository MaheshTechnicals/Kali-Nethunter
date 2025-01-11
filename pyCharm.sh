#!/bin/bash

#===============================#
#       PyCharm Installer       #
#  Script by MaheshTechnicals   #
#===============================#

# Define colors for the UI
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Stylish header
echo -e "${CYAN}"
echo "############################################################"
echo "#                   PyCharm Installer                      #"
echo "#                 Author: MaheshTechnicals                #"
echo "############################################################"
echo -e "${RESET}"

# Function to print a title
print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

# Update and upgrade system packages
print_title "Step 1: Updating and Upgrading System Packages"
sudo apt update && sudo apt upgrade -y

# Detect system architecture
print_title "Step 2: Detecting System Architecture"
ARCH=$(uname -m)
echo -e "${CYAN}Detected system architecture: $ARCH${RESET}"

# Determine download URL based on architecture
if [[ "$ARCH" == "x86_64" ]]; then
    PYCHARM_URL="https://download.jetbrains.com/python/pycharm-community-2024.3.1.1.tar.gz"
elif [[ "$ARCH" == "aarch64" ]]; then
    PYCHARM_URL="https://download.jetbrains.com/python/pycharm-community-2024.3.1.1-aarch64.tar.gz"
else
    echo -e "${RED}Unsupported architecture: $ARCH${RESET}"
    exit 1
fi

# Download PyCharm
print_title "Step 3: Downloading PyCharm"
wget -q --show-progress "$PYCHARM_URL" -O pycharm.tar.gz

# Extract PyCharm
print_title "Step 4: Extracting PyCharm"
tar -xzf pycharm.tar.gz
rm pycharm.tar.gz

# Move PyCharm to /opt directory
print_title "Step 5: Installing PyCharm to /opt"
sudo mv pycharm-* /opt/pycharm

# Create a desktop entry for PyCharm
print_title "Step 6: Creating Desktop Entry"
cat <<EOF | sudo tee /usr/share/applications/pycharm.desktop
[Desktop Entry]
Version=1.0
Name=PyCharm
Comment=Python IDE
Exec=/opt/pycharm/bin/pycharm.sh
Icon=/opt/pycharm/bin/pycharm.png
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

# Add an alias to start PyCharm from the terminal
print_title "Step 7: Adding Terminal Alias for PyCharm"
ALIAS_COMMAND="alias pycharm=\"/opt/pycharm/bin/pycharm.sh\""

# Add alias to ~/.bashrc
if ! grep -Fxq "$ALIAS_COMMAND" "$HOME/.bashrc"; then
    echo "$ALIAS_COMMAND" >> "$HOME/.bashrc"
    echo -e "${GREEN}Alias 'pycharm' added to ~/.bashrc${RESET}"
else
    echo -e "${YELLOW}Alias 'pycharm' already exists in ~/.bashrc${RESET}"
fi

# Reload ~/.bashrc
source "$HOME/.bashrc"

# Verify Installation
print_title "Step 8: Verifying PyCharm Installation"
if command -v pycharm &> /dev/null; then
    echo -e "${GREEN}PyCharm is ready to use! Run 'pycharm' to launch.${RESET}"
else
    echo -e "${RED}Something went wrong. Please try installing again.${RESET}"
fi

# Final message
print_title "🎉 PyCharm Installation Completed!"
echo -e "${GREEN}PyCharm Community Edition has been installed successfully.${RESET}"
echo -e "${CYAN}Use 'pycharm' in your terminal to launch it.${RESET}"
