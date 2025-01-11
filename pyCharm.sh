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

# Function to Install PyCharm Community
install_pycharm_community() {
    echo -e "${GREEN}Installing PyCharm Community Edition...${RESET}"

    # Check if Java is installed and version is 23 or higher
    if ! command -v java &> /dev/null || [[ $(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}') -lt 23 ]]; then
        echo -e "${YELLOW}Java is not installed or version is less than 23. Installing Java 23...${RESET}"
        install_java
    fi

    # Download PyCharm Community Edition
    echo -e "${YELLOW}Downloading PyCharm Community Edition...${RESET}"
    wget "https://download.jetbrains.com/python/pycharm-community-2023.2.tar.gz" -O pycharm-community.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download PyCharm Community Edition.${RESET}"
        exit 1
    fi

    # Create installation directory
    echo -e "${CYAN}Creating /opt/pycharm-community directory...${RESET}"
    sudo mkdir -p /opt/pycharm-community

    # Extract PyCharm
    echo -e "${CYAN}Extracting PyCharm...${RESET}"
    sudo tar -xzf pycharm-community.tar.gz -C /opt/pycharm-community
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to extract PyCharm.${RESET}"
        exit 1
    fi

    # Create a symlink for easy access
    sudo ln -s /opt/pycharm-community/bin/pycharm.sh /usr/bin/pycharm

    # Create a desktop entry
    echo -e "${CYAN}Creating PyCharm desktop entry...${RESET}"
    echo -e "[Desktop Entry]\nVersion=1.0\nName=PyCharm Community Edition\nComment=Python IDE\nExec=/usr/bin/pycharm\nIcon=/opt/pycharm-community/bin/pycharm.png\nTerminal=false\nType=Application\nCategories=Development;IDE;" | sudo tee /usr/share/applications/pycharm-community.desktop > /dev/null

    # Clean up
    rm -f pycharm-community.tar.gz

    echo -e "${CYAN}PyCharm Community Edition has been successfully installed!${RESET}"
}

# Function to Install PyCharm Professional
install_pycharm_professional() {
    echo -e "${RED}Installing PyCharm Professional Edition...${RESET}"

    # Check if Java is installed and version is 23 or higher
    if ! command -v java &> /dev/null || [[ $(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}') -lt 23 ]]; then
        echo -e "${YELLOW}Java is not installed or version is less than 23. Installing Java 23...${RESET}"
        install_java
    fi

    # Download PyCharm Professional Edition
    echo -e "${YELLOW}Downloading PyCharm Professional Edition...${RESET}"
    wget "https://download.jetbrains.com/python/pycharm-professional-2023.2.tar.gz" -O pycharm-professional.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download PyCharm Professional Edition.${RESET}"
        exit 1
    fi

    # Create installation directory
    echo -e "${CYAN}Creating /opt/pycharm-professional directory...${RESET}"
    sudo mkdir -p /opt/pycharm-professional

    # Extract PyCharm
    echo -e "${CYAN}Extracting PyCharm...${RESET}"
    sudo tar -xzf pycharm-professional.tar.gz -C /opt/pycharm-professional
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to extract PyCharm.${RESET}"
        exit 1
    fi

    # Create a symlink for easy access
    sudo ln -s /opt/pycharm-professional/bin/pycharm.sh /usr/bin/pycharm

    # Create a desktop entry
    echo -e "${CYAN}Creating PyCharm desktop entry...${RESET}"
    echo -e "[Desktop Entry]\nVersion=1.0\nName=PyCharm Professional Edition\nComment=Python IDE\nExec=/usr/bin/pycharm\nIcon=/opt/pycharm-professional/bin/pycharm.png\nTerminal=false\nType=Application\nCategories=Development;IDE;" | sudo tee /usr/share/applications/pycharm-professional.desktop > /dev/null

    # Clean up
    rm -f pycharm-professional.tar.gz

    echo -e "${CYAN}PyCharm Professional Edition has been successfully installed!${RESET}"
}

# Function to Uninstall PyCharm
uninstall_pycharm() {
    echo -e "${RED}Uninstalling PyCharm...${RESET}"

    # Remove the PyCharm installation directory
    if [ -d "/opt/pycharm-community" ]; then
        echo -e "${GREEN}Removing PyCharm Community directory...${RESET}"
        sudo rm -rf /opt/pycharm-community
    fi

    if [ -d "/opt/pycharm-professional" ]; then
        echo -e "${GREEN}Removing PyCharm Professional directory...${RESET}"
        sudo rm -rf /opt/pycharm-professional
    fi

    # Remove the PyCharm symlink
    if [ -L "/usr/bin/pycharm" ]; then
        echo -e "${GREEN}Removing PyCharm symlink from /usr/bin...${RESET}"
        sudo rm -f /usr/bin/pycharm
    fi

    # Remove the PyCharm desktop entry
    if [ -f "/usr/share/applications/pycharm-community.desktop" ]; then
        echo -e "${GREEN}Removing PyCharm Community desktop entry...${RESET}"
        sudo rm -f /usr/share/applications/pycharm-community.desktop
    fi

    if [ -f "/usr/share/applications/pycharm-professional.desktop" ]; then
        echo -e "${GREEN}Removing PyCharm Professional desktop entry...${RESET}"
        sudo rm -f /usr/share/applications/pycharm-professional.desktop
    fi

    # Check if there are any lingering files in the user's home directory
    if [ -d "$HOME/.PyCharm*" ]; then
        echo -e "${GREEN}Removing PyCharm configuration and cache files from $HOME...${RESET}"
        sudo rm -rf "$HOME/.PyCharm*"
    fi

    echo -e "${CYAN}PyCharm has been fully uninstalled.${RESET}"
}

# Main Menu
echo -e "${CYAN}PyCharm Installation/Uninstallation Script${RESET}"
echo "1. Install PyCharm Community Edition"
echo "2. Install PyCharm Professional Edition"
echo "3. Uninstall PyCharm"
echo "4. Exit"

read -p "Choose an option: " option

case $option in
    1) install_pycharm_community ;;
    2) install_pycharm_professional ;;
    3) uninstall_pycharm ;;
    4) exit 0 ;;
    *) echo -e "${RED}Invalid option!${RESET}" ;;
esac

