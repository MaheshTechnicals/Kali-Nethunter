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

# Function to Install PyCharm Community Version
install_pycharm_community() {
    echo -e "${GREEN}Installing PyCharm Community Version...${RESET}"

    # Check if Java is installed and version is 23 or higher
    if command -v java &> /dev/null; then
        INSTALLED_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')
        if [[ $INSTALLED_VERSION -lt 23 ]]; then
            echo -e "${YELLOW}Java version is less than 23. Installing Java 23...${RESET}"
            install_java
        else
            echo -e "${GREEN}Java version $INSTALLED_VERSION is already installed. Skipping Java installation.${RESET}"
        fi
    else
        echo -e "${RED}Java is not installed. Installing Java 23...${RESET}"
        install_java
    fi

    # Download and Install PyCharm Community Version
    echo -e "${YELLOW}Downloading PyCharm Community Edition...${RESET}"
    wget https://download.jetbrains.com/python/pycharm-community-2023.2.tar.gz -O pycharm-community.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download PyCharm.${RESET}"
        exit 1
    fi
    sudo tar -xzf pycharm-community.tar.gz -C /opt/
    rm pycharm-community.tar.gz

    # Create a symlink to make PyCharm accessible globally
    sudo ln -s /opt/pycharm-community-*/bin/pycharm.sh /usr/bin/pycharm

    echo -e "${CYAN}PyCharm Community Version has been successfully installed!${RESET}"
    echo -e "${GREEN}To start PyCharm, run the following command:${RESET}"
    echo -e "${YELLOW}pycharm${RESET}"
}

# Function to Install PyCharm Professional Version
install_pycharm_professional() {
    echo -e "${GREEN}Installing PyCharm Professional Version...${RESET}"

    # Check if Java is installed and version is 23 or higher
    if command -v java &> /dev/null; then
        INSTALLED_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')
        if [[ $INSTALLED_VERSION -lt 23 ]]; then
            echo -e "${YELLOW}Java version is less than 23. Installing Java 23...${RESET}"
            install_java
        else
            echo -e "${GREEN}Java version $INSTALLED_VERSION is already installed. Skipping Java installation.${RESET}"
        fi
    else
        echo -e "${RED}Java is not installed. Installing Java 23...${RESET}"
        install_java
    fi

    # Download and Install PyCharm Professional Version
    echo -e "${YELLOW}Downloading PyCharm Professional Edition...${RESET}"
    wget https://download.jetbrains.com/python/pycharm-professional-2023.2.tar.gz -O pycharm-professional.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download PyCharm.${RESET}"
        exit 1
    fi
    sudo tar -xzf pycharm-professional.tar.gz -C /opt/
    rm pycharm-professional.tar.gz

    # Create a symlink to make PyCharm accessible globally
    sudo ln -s /opt/pycharm-professional-*/bin/pycharm.sh /usr/bin/pycharm

    echo -e "${CYAN}PyCharm Professional Version has been successfully installed!${RESET}"
    echo -e "${GREEN}To start PyCharm, run the following command:${RESET}"
    echo -e "${YELLOW}pycharm${RESET}"
}

# Function to Uninstall PyCharm and Java
uninstall_pycharm() {
    echo -e "${RED}Uninstalling PyCharm...${RESET}"
    sudo rm -rf /opt/pycharm-*

    # Remove symlink
    sudo rm -f /usr/bin/pycharm

    # Uninstall Java completely
    echo -e "${RED}Uninstalling Java...${RESET}"
    sudo apt-get remove --purge -y openjdk-* && sudo update-alternatives --remove-all java && sudo rm -rf /usr/lib/jvm/* && sudo rm -f /usr/bin/java

    echo -e "${GREEN}PyCharm and Java have been uninstalled.${RESET}"
}

# UI - Display options to the user
echo -e "${CYAN}#######################################"
echo -e "${CYAN}           PyCharm Installer           "
echo -e "${CYAN}#######################################"
echo -e "${GREEN}Please choose an option:${RESET}"
echo -e "${YELLOW}1. Install PyCharm Community Version${RESET}"
echo -e "${YELLOW}2. Install PyCharm Professional Version${RESET}"
echo -e "${RED}3. Uninstall PyCharm${RESET}"

read -p "Enter your choice (1/2/3): " choice

if [ "$choice" -eq 1 ]; then
    install_pycharm_community
elif [ "$choice" -eq 2 ]; then
    install_pycharm_professional
elif [ "$choice" -eq 3 ]; then
    uninstall_pycharm
else
    echo -e "${RED}Invalid choice. Exiting...${RESET}"
    exit 1
fi

