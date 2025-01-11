#!/bin/bash

#===============================#
#         Python Installer      #
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
echo "#                   Python Installer                       #"
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
echo -e "${GREEN}Updating system packages...${RESET}"
sudo apt update && sudo apt upgrade -y
echo -e "${GREEN}System updated successfully!${RESET}"

# Add the deadsnakes PPA
print_title "Step 2: Adding the Deadsnakes PPA"
echo -e "${GREEN}Adding the deadsnakes repository...${RESET}"
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
echo -e "${GREEN}Deadsnakes repository added successfully!${RESET}"

# Fetch the latest Python version from the PPA
print_title "Step 3: Fetching the Latest Python Version"
echo -e "${GREEN}Finding the latest Python version available...${RESET}"
LATEST_PYTHON_VERSION=$(apt-cache search "^python3.[0-9]+$" | awk '{print $1}' | grep -E '^python3\.[0-9]+$' | sort -V | tail -n 1)
echo -e "${CYAN}Latest Python version available: ${LATEST_PYTHON_VERSION}${RESET}"

# Install the latest Python version
print_title "Step 4: Installing ${LATEST_PYTHON_VERSION}"
echo -e "${GREEN}Installing ${LATEST_PYTHON_VERSION}...${RESET}"
sudo apt install -y "${LATEST_PYTHON_VERSION}"
echo -e "${GREEN}${LATEST_PYTHON_VERSION} installed successfully!${RESET}"

# Install the venv module for the latest Python version
print_title "Step 5: Installing venv Module for ${LATEST_PYTHON_VERSION}"
echo -e "${GREEN}Installing venv module...${RESET}"
sudo apt install -y "${LATEST_PYTHON_VERSION}-venv"
echo -e "${GREEN}venv module installed successfully!${RESET}"

# Set up a virtual environment
print_title "Step 6: Setting Up a Virtual Environment"
echo -e "${GREEN}Creating a virtual environment named 'myenv' using ${LATEST_PYTHON_VERSION}...${RESET}"
"${LATEST_PYTHON_VERSION}" -m venv myenv
echo -e "${GREEN}Virtual environment 'myenv' created successfully!${RESET}"

# Add a permanent alias for activating the virtual environment
print_title "Step 7: Adding Permanent Alias for Virtual Environment Activation"
ALIAS_COMMAND="alias activate=\"source $(pwd)/myenv/bin/activate\""
SHELL_CONFIG=""

# Detect the shell and update the appropriate configuration file
if [ "$SHELL" == "/bin/bash" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ "$SHELL" == "/bin/zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    echo -e "${RED}Unsupported shell. Please manually add the alias to your shell configuration file.${RESET}"
    exit 1
fi

# Add the alias if it doesn't already exist
if ! grep -Fxq "$ALIAS_COMMAND" "$SHELL_CONFIG"; then
    echo "$ALIAS_COMMAND" >> "$SHELL_CONFIG"
    echo -e "${GREEN}Alias 'activate' added to $SHELL_CONFIG!${RESET}"
else
    echo -e "${YELLOW}Alias 'activate' already exists in $SHELL_CONFIG.${RESET}"
fi

# Reload the shell configuration
source "$SHELL_CONFIG"
echo -e "${GREEN}Alias 'activate' is now available. Use it to activate your virtual environment.${RESET}"

# Activate the virtual environment
print_title "Step 8: Activating the Virtual Environment"
echo -e "${GREEN}Activating the virtual environment...${RESET}"
source myenv/bin/activate
echo -e "${GREEN}You are now in the virtual environment 'myenv'.${RESET}"
echo -e "${CYAN}Use 'deactivate' to exit the virtual environment.${RESET}"

# Final message
print_title "🎉 Python Installation and Setup Completed!"
echo -e "${GREEN}Everything is ready. Enjoy coding with the latest Python version!${RESET}"
