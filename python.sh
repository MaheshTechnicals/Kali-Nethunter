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

# Stylish header (Printed only once)
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

# Function to install Python
install_python() {
    # Install software-properties-common to enable add-apt-repository command
    print_title "Installing software-properties-common"
    sudo apt install -y software-properties-common
    clear

    # Update and upgrade system packages
    print_title "Step 1: Updating and Upgrading System Packages"
    sudo apt update && sudo apt upgrade -y
    clear

    # Add the deadsnakes PPA
    print_title "Step 2: Adding the Deadsnakes PPA"
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update
    clear

    # Fetch the latest Python version from the PPA
    print_title "Step 3: Fetching the Latest Python Version"
    LATEST_PYTHON_VERSION=$(apt-cache search "^python3.[0-9]+$" | awk '{print $1}' | grep -E '^python3\.[0-9]+$' | sort -V | tail -n 1)
    echo -e "${CYAN}Latest Python version available: ${LATEST_PYTHON_VERSION}${RESET}"
    clear

    # Install the latest Python version
    print_title "Step 4: Installing ${LATEST_PYTHON_VERSION}"
    sudo apt install -y "${LATEST_PYTHON_VERSION}"
    clear

    # Install the venv module for the latest Python version
    print_title "Step 5: Installing venv Module for ${LATEST_PYTHON_VERSION}"
    sudo apt install -y "${LATEST_PYTHON_VERSION}-venv"
    clear

    # Install pip
    print_title "Step 6: Installing pip for Python"
    sudo apt install -y python3-pip
    clear

    # Set the latest Python version as default
    print_title "Step 7: Setting ${LATEST_PYTHON_VERSION} as the Default Python"
    PYTHON_BIN_PATH=$(which "${LATEST_PYTHON_VERSION}")
    sudo update-alternatives --install /usr/bin/python python "$PYTHON_BIN_PATH" 1
    sudo update-alternatives --config python <<EOF
1
EOF
    clear

    # Verify the default Python version
    print_title "Step 8: Verifying Default Python Version"
    DEFAULT_PYTHON_VERSION=$(python --version 2>&1)
    echo -e "${GREEN}Default Python version is now: ${DEFAULT_PYTHON_VERSION}${RESET}"
    clear

    # Set up a virtual environment
    print_title "Step 9: Setting Up a Virtual Environment"
    python -m venv myenv
    clear

    # Add a permanent alias for activating the virtual environment
    print_title "Step 10: Adding Permanent Alias for Virtual Environment Activation"
    ALIAS_COMMAND="alias activate=\"source $(pwd)/myenv/bin/activate\""

    # Add alias to ~/.bashrc
    if ! grep -Fxq "$ALIAS_COMMAND" "$HOME/.bashrc"; then
        echo "$ALIAS_COMMAND" >> "$HOME/.bashrc"
        echo -e "${GREEN}Alias 'activate' added to ~/.bashrc${RESET}"
    else
        echo -e "${YELLOW}Alias 'activate' already exists in ~/.bashrc${RESET}"
    fi

    # Reload ~/.bashrc
    source "$HOME/.bashrc"
    clear

    # Activate the virtual environment
    print_title "Step 11: Activating the Virtual Environment"
    echo -e "${GREEN}Activating the virtual environment...${RESET}"
    source myenv/bin/activate
    echo -e "${GREEN}You are now in the virtual environment 'myenv'.${RESET}"
    echo -e "${CYAN}Use 'deactivate' to exit the virtual environment.${RESET}"
}

# Function to uninstall Python
uninstall_python() {
    # Install software-properties-common to enable add-apt-repository command
    print_title "Installing software-properties-common"
    sudo apt install -y software-properties-common
    clear
    
    print_title "Uninstalling All Python Versions"
    
    # Remove Python versions
    echo -e "${RED}Removing all Python versions...${RESET}"
    sudo apt remove --purge python3* python-pip* -y
    sudo apt autoremove -y
    sudo apt clean
    clear

    # Remove Deadsnakes PPA
    echo -e "${RED}Removing Deadsnakes PPA...${RESET}"
    sudo add-apt-repository --remove ppa:deadsnakes/ppa -y
    sudo apt update
    clear

    # Remove virtual environments
    echo -e "${RED}Removing virtual environment directory...${RESET}"
    rm -rf myenv
    clear

    # Revert default Python configuration
    echo -e "${RED}Reverting default Python configuration...${RESET}"
    sudo update-alternatives --remove python /usr/bin/python
    sudo update-alternatives --remove python3 /usr/bin/python3
    clear

    # Reset the alternatives to default system Python
    echo -e "${RED}Resetting alternatives to system Python...${RESET}"
    sudo update-alternatives --auto python
    sudo update-alternatives --auto python3
    clear

    # Reload ~/.bashrc to remove alias
    echo -e "${RED}Reloading bashrc and removing Python-related aliases...${RESET}"
    sed -i '/alias activate=/d' "$HOME/.bashrc"
    source "$HOME/.bashrc"
    clear

    print_title "Python Uninstallation Completed!"
    echo -e "${GREEN}All Python versions and related configurations have been removed.${RESET}"
}

# Menu for selecting an option
echo -e "${CYAN}Please select an option:${RESET}"
echo "1. Install Python"
echo "2. Uninstall Python"
echo -n "Enter your choice (1/2): "
read -r choice

case $choice in
    1)
        install_python
        ;;
    2)
        uninstall_python
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${RESET}"
        ;;
esac

