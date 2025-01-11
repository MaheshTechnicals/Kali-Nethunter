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

# Function to Install PyCharm Community Edition
install_pycharm_community() {
    echo -e "${GREEN}Installing PyCharm Community Edition...${RESET}"

    # Check if Java is installed and install if necessary
    if ! command -v java &> /dev/null; then
        echo -e "${YELLOW}Java is not installed. Installing Java 23...${RESET}"
        install_java
    fi

    # Download and install PyCharm Community
    echo -e "${YELLOW}Downloading PyCharm Community Edition...${RESET}"
    wget https://download.jetbrains.com/python/pycharm-community-2023.3.tar.gz -O pycharm-community.tar.gz
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download PyCharm.${RESET}"
        exit 1
    fi

    # Extract PyCharm
    echo -e "${CYAN}Extracting PyCharm Community Edition...${RESET}"
    sudo tar -xzf pycharm-community.tar.gz -C /opt
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to extract PyCharm.${RESET}"
        exit 1
    fi

    # Clean up
    rm -f pycharm-community.tar.gz

    # Create a desktop entry
    echo -e "${CYAN}Creating PyCharm desktop entry...${RESET}"
    echo "[Desktop Entry]
    Name=PyCharm Community Edition
    Comment=Python IDE
    Exec=/opt/pycharm-community-*/bin/pycharm.sh
    Icon=/opt/pycharm-community-*/bin/pycharm.png
    Type=Application
    Categories=Development;IDE;
    " | sudo tee /usr/share/applications/pycharm.desktop

    echo -e "${GREEN}PyCharm Community Edition has been successfully installed!${RESET}"
}

# Function to Install PyCharm Professional Edition
install_pycharm_professional() {
    echo -e "${GREEN}Installing PyCharm Professional Edition...${RESET}"

    # Check if Java is installed and install if necessary
    if ! command -v java &> /dev/null; then
        echo -e "${YELLOW}Java is not installed. Installing Java 23...${RESET}"
        install_java
    fi

    # Download and install PyCharm Professional
    echo -e "${YELLOW}Downloading PyCharm Professional Edition...${RESET}"
    wget https://download.jetbrains.com/python/pycharm-professional-2023.3.tar.gz -O pycharm-professional.tar.gz
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download PyCharm.${RESET}"
        exit 1
    fi

    # Extract PyCharm
    echo -e "${CYAN}Extracting PyCharm Professional Edition...${RESET}"
    sudo tar -xzf pycharm-professional.tar.gz -C /opt
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to extract PyCharm.${RESET}"
        exit 1
    fi

    # Clean up
    rm -f pycharm-professional.tar.gz

    # Create a desktop entry
    echo -e "${CYAN}Creating PyCharm desktop entry...${RESET}"
    echo "[Desktop Entry]
    Name=PyCharm Professional Edition
    Comment=Python IDE
    Exec=/opt/pycharm-professional-*/bin/pycharm.sh
    Icon=/opt/pycharm-professional-*/bin/pycharm.png
    Type=Application
    Categories=Development;IDE;
    " | sudo tee /usr/share/applications/pycharm.desktop

    echo -e "${GREEN}PyCharm Professional Edition has been successfully installed!${RESET}"
}

# Function to Uninstall PyCharm
uninstall_pycharm() {
    echo -e "${RED}Uninstalling PyCharm...${RESET}"

    # Remove PyCharm desktop entry and application files
    sudo rm -f /usr/share/applications/pycharm.desktop
    sudo rm -rf /opt/pycharm*

    echo -e "${GREEN}PyCharm has been fully uninstalled.${RESET}"
}

# UI - Display options to the user
echo -e "${CYAN}#######################################"
echo -e "${CYAN}       PyCharm Installation/Uninstallation Script        "
echo -e "${CYAN}#######################################"
echo -e "${GREEN}Please choose an option:${RESET}"
echo -e "${YELLOW}1. Install PyCharm Community Edition${RESET}"
echo -e "${RED}2. Install PyCharm Professional Edition${RESET}"
echo -e "${RED}3. Uninstall PyCharm${RESET}"
echo -e "${CYAN}4. Exit${RESET}"

read -p "Enter your choice (1-4): " choice

if [ "$choice" -eq 1 ]; then
    install_pycharm_community
elif [ "$choice" -eq 2 ]; then
    install_pycharm_professional
elif [ "$choice" -eq 3 ]; then
    uninstall_pycharm
elif [ "$choice" -eq 4 ]; then
    echo -e "${CYAN}Exiting script...${RESET}"
    exit 0
else
    echo -e "${RED}Invalid choice. Exiting...${RESET}"
    exit 1
fi

