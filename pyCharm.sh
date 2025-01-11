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

# Function to Install PyCharm (Community or Professional)
install_pycharm() {
    echo -e "${CYAN}Installing PyCharm...${RESET}"

    # Ask for version choice
    echo -e "${YELLOW}Choose PyCharm version:${RESET}"
    echo -e "${GREEN}1. Community Edition${RESET}"
    echo -e "${RED}2. Professional Edition${RESET}"
    echo -e "${CYAN}3. Uninstall PyCharm${RESET}"

    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1)
            # Community version installation
            echo -e "${CYAN}Downloading PyCharm Community Edition...${RESET}"
            DOWNLOAD_LINK="https://download.jetbrains.com/python/pycharm-community-2023.3.3.tar.gz"
            ;;
        2)
            # Professional version installation
            echo -e "${CYAN}Downloading PyCharm Professional Edition...${RESET}"
            DOWNLOAD_LINK="https://download.jetbrains.com/python/pycharm-professional-2023.3.3.tar.gz"
            ;;
        3)
            # Uninstall PyCharm
            echo -e "${RED}Uninstalling PyCharm...${RESET}"
            sudo rm -rf /opt/pycharm
            rm -f /usr/bin/pycharm
            echo -e "${GREEN}PyCharm has been uninstalled successfully!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Exiting...${RESET}"
            exit 1
            ;;
    esac

    # Download PyCharm
    wget "$DOWNLOAD_LINK" -O pycharm.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download PyCharm.${RESET}"
        exit 1
    fi

    # Create directory for PyCharm
    sudo mkdir -p /opt/pycharm
    sudo tar -xzf pycharm.tar.gz -C /opt/pycharm --strip-components=1
    rm -f pycharm.tar.gz

    # Create terminal alias for PyCharm
    echo -e "${CYAN}Adding terminal alias for PyCharm...${RESET}"
    echo "alias pycharm='/opt/pycharm/bin/pycharm.sh'" >> ~/.bashrc
    source ~/.bashrc

    # Create a symlink to launch PyCharm from anywhere
    sudo ln -s /opt/pycharm/bin/pycharm.sh /usr/bin/pycharm

    echo -e "${GREEN}PyCharm has been successfully installed!${RESET}"
    echo -e "${CYAN}To start PyCharm, run the following command:${RESET}"
    echo -e "${YELLOW}pycharm${RESET}"
}

# UI - Display options to the user
echo -e "${CYAN}########################################"
echo -e "${CYAN}       PyCharm Installation Menu        "
echo -e "${CYAN}########################################"
echo -e "${GREEN}Please choose an option:${RESET}"
echo -e "${YELLOW}1. Install PyCharm${RESET}"
echo -e "${RED}2. Install Java${RESET}"
echo -e "${CYAN}3. Exit${RESET}"

read -p "Enter your choice (1/2/3): " choice

if [ "$choice" -eq 1 ]; then
    install_pycharm
elif [ "$choice" -eq 2 ]; then
    install_java
elif [ "$choice" -eq 3 ]; then
    echo -e "${GREEN}Exiting...${RESET}"
    exit 0
else
    echo -e "${RED}Invalid choice. Exiting...${RESET}"
    exit 1
fi
