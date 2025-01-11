#!/bin/bash

# Define colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Function to Install Java 23
install_java() {
    echo -e "${GREEN}Installing Java 23...${RESET}"

    # Check system architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-x64_bin.tar.gz"
    elif [[ "$ARCH" == "aarch64" ]]; then
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-aarch64_bin.tar.gz"
    else
        echo -e "${RED}Unsupported architecture: $ARCH. Exiting...${RESET}"
        exit 1
    fi

    # Download Java
    echo -e "${YELLOW}Downloading Java from $JAVA_URL...${RESET}"
    wget "$JAVA_URL" -O openjdk-23.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download Java.${RESET}"
        exit 1
    fi

    # Create /usr/lib/jvm directory if it doesn't exist
    echo -e "${CYAN}Creating /usr/lib/jvm directory...${RESET}"
    sudo mkdir -p /usr/lib/jvm

    # Extract Java
    echo -e "${CYAN}Extracting Java...${RESET}"
    sudo tar -xzf openjdk-23.tar.gz -C /usr/lib/jvm
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to extract Java.${RESET}"
        exit 1
    fi

    # Find the extracted Java directory
    JAVA_DIR=$(tar -tf openjdk-23.tar.gz | head -n 1 | cut -f1 -d"/")
    JAVA_PATH="/usr/lib/jvm/$JAVA_DIR"

    # Set up Java alternatives
    echo -e "${CYAN}Setting up Java alternatives...${RESET}"
    sudo update-alternatives --install /usr/bin/java java "$JAVA_PATH/bin/java" 1
    sudo update-alternatives --set java "$JAVA_PATH/bin/java"

    # Clean up
    rm -f openjdk-23.tar.gz
    echo -e "${CYAN}Java 23 has been installed successfully!${RESET}"

    # Display installed Java version
    java -version
}

# Function to Install PyCharm (Community/Professional)
install_pycharm() {
    echo -e "${GREEN}Installing PyCharm...${RESET}"

    # Install Java first
    install_java

    # Check if PyCharm is already installed
    if [ -d "/opt/pycharm-community" ] || [ -d "/opt/pycharm-professional" ]; then
        echo -e "${RED}PyCharm is already installed. Uninstall it first before installing again.${RESET}"
        return
    fi

    # Ask user for PyCharm version
    echo -e "${CYAN}Which version of PyCharm would you like to install?${RESET}"
    echo -e "${YELLOW}1. Community Edition${RESET}"
    echo -e "${RED}2. Professional Edition${RESET}"
    read -p "Enter your choice (1/2): " version_choice

    # Define download links
    if [ "$version_choice" -eq 1 ]; then
        echo -e "${CYAN}Installing PyCharm Community Edition...${RESET}"
        DOWNLOAD_URL="https://download.jetbrains.com/python/pycharm-community-2023.2.2.tar.gz"
        INSTALL_DIR="/opt/pycharm-community"
    elif [ "$version_choice" -eq 2 ]; then
        echo -e "${CYAN}Installing PyCharm Professional Edition...${RESET}"
        DOWNLOAD_URL="https://download.jetbrains.com/python/pycharm-professional-2023.2.2.tar.gz"
        INSTALL_DIR="/opt/pycharm-professional"
    else
        echo -e "${RED}Invalid option selected. Exiting...${RESET}"
        exit 1
    fi

    # Download PyCharm
    echo -e "${YELLOW}Downloading PyCharm from $DOWNLOAD_URL...${RESET}"
    wget "$DOWNLOAD_URL" -O pycharm.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download PyCharm.${RESET}"
        exit 1
    fi

    # Create directory for installation
    echo -e "${CYAN}Creating installation directory...${RESET}"
    sudo mkdir -p "$INSTALL_DIR"

    # Extract PyCharm
    echo -e "${CYAN}Extracting PyCharm...${RESET}"
    sudo tar -xzf pycharm.tar.gz -C "$INSTALL_DIR"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to extract PyCharm.${RESET}"
        exit 1
    fi

    # Remove downloaded tar file
    rm -f pycharm.tar.gz

    # Create a symlink for easy access
    echo -e "${CYAN}Creating a symlink for easy access...${RESET}"
    sudo ln -s "$INSTALL_DIR/pycharm-*/bin/pycharm.sh" /usr/bin/pycharm

    # Confirm successful installation
    echo -e "${GREEN}PyCharm has been installed successfully!${RESET}"
}

# Function to Uninstall PyCharm
uninstall_pycharm() {
    echo -e "${RED}Uninstalling PyCharm...${RESET}"

    # Remove the PyCharm installation directory
    if [ -d "/opt/pycharm-community" ]; then
        sudo rm -rf /opt/pycharm-community
        echo -e "${GREEN}PyCharm Community version removed from /opt.${RESET}"
    fi

    if [ -d "/opt/pycharm-professional" ]; then
        sudo rm -rf /opt/pycharm-professional
        echo -e "${GREEN}PyCharm Professional version removed from /opt.${RESET}"
    fi

    # Remove the PyCharm symlink
    if [ -L "/usr/bin/pycharm" ]; then
        sudo rm -f /usr/bin/pycharm
        echo -e "${GREEN}PyCharm symlink removed from /usr/bin.${RESET}"
    fi

    # Check if there are any lingering files in the user's home directory
    if [ -d "$HOME/.PyCharm*" ]; then
        sudo rm -rf "$HOME/.PyCharm*"
        echo -e "${GREEN}PyCharm configuration and cache files removed from $HOME.${RESET}"
    fi

    echo -e "${CYAN}PyCharm has been fully uninstalled.${RESET}"
}

# UI - Display options to the user
echo -e "${CYAN}#######################################"
echo -e "${CYAN}           PyCharm Installer          "
echo -e "${CYAN}#######################################"
echo -e "${GREEN}Please choose an option:${RESET}"
echo -e "${YELLOW}1. Install PyCharm Community Edition${RESET}"
echo -e "${RED}2. Install PyCharm Professional Edition${RESET}"
echo -e "${CYAN}3. Uninstall PyCharm${RESET}"
echo -e "${YELLOW}4. Exit${RESET}"

read -p "Enter your choice (1/2/3/4): " choice

if [ "$choice" -eq 1 ]; then
    install_pycharm
elif [ "$choice" -eq 2 ]; then
    install_pycharm
elif [ "$choice" -eq 3 ]; then
    uninstall_pycharm
elif [ "$choice" -eq 4 ]; then
    echo -e "${CYAN}Exiting...${RESET}"
    exit 0
else
    echo -e "${RED}Invalid choice. Exiting...${RESET}"
    exit 1
fi

