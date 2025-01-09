#!/bin/bash

# Define colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Author Info
AUTHOR="${CYAN}Script Author: Mahesh Technicals${RESET}"

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

    # Download and install Java
    echo -e "${YELLOW}Downloading Java from $JAVA_URL...${RESET}"
    wget "$JAVA_URL" -O openjdk-23.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download Java.${RESET}"
        exit 1
    fi

    # Extract and install Java
    echo -e "${CYAN}Extracting Java...${RESET}"
    sudo tar -xzf openjdk-23.tar.gz -C /usr/lib/jvm
    sudo update-alternatives --install /usr/bin/java /usr/bin/java /usr/lib/jvm/jdk-23/bin/java 1
    sudo update-alternatives --set java /usr/lib/jvm/jdk-23/bin/java

    # Clean up
    rm -f openjdk-23.tar.gz
    echo -e "${CYAN}Java 23 has been installed successfully!${RESET}"
}

# Function to Install Burp Suite
install_burp() {
    echo -e "${GREEN}Installing Burp Suite...${RESET}"

    # Check if Java 23 is installed
    if ! command -v java &> /dev/null || [[ $(java -version 2>&1 | head -n 1 | awk '{print $3}' | tr -d '"') != "23" ]]; then
        install_java
    fi

    # Display the installed Java version
    echo -e "${CYAN}Java Version Installed:${RESET}"
    java -version
    echo -e "${CYAN}-------------------------------------------------${RESET}"

    # Download Burp Suite Community Latest Version
    echo -e "${YELLOW}Downloading Burp Suite Community...${RESET}"
    Link="https://portswigger-cdn.net/burp/releases/download?product=community&type=jar"
    wget "$Link" -O Burp.jar --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download Burp Suite.${RESET}"
        exit 1
    fi
    sleep 2

    # Create directory for Burp Suite if it does not exist
    BURP_DIR="/root/Burp_Suite"
    if [ ! -d "$BURP_DIR" ]; then
        echo -e "${CYAN}Creating directory for Burp Suite...${RESET}"
        mkdir "$BURP_DIR"
    fi

    # Move the downloaded file to the directory
    echo -e "${CYAN}Moving Burp Suite to $BURP_DIR...${RESET}"
    mv Burp.jar "$BURP_DIR/"
    
    # Create a launcher script
    echo -e "${CYAN}Creating Burp Suite launcher...${RESET}"
    echo "java -jar $BURP_DIR/Burp.jar" > /usr/bin/burp
    chmod +x /usr/bin/burp

    echo -e "${CYAN}Burp Suite has been successfully installed!${RESET}"
    echo -e "${GREEN}To start Burp Suite, run the following command:${RESET}"
    echo -e "${YELLOW}burp${RESET}"
    echo -e "${CYAN}-------------------------------------------------${RESET}"

    # Optionally, you can offer to open Burp after installation (if desired)
    # Uncomment the next line to auto-launch Burp after installation (if you want this option)
    # burp
}

# Function to Uninstall Burp Suite and Java
uninstall_burp() {
    echo -e "${RED}Uninstalling Burp Suite...${RESET}"
    rm -rf /root/Burp_Suite
    rm -f /usr/bin/burp

    # Uninstall Java completely
    echo -e "${RED}Uninstalling Java...${RESET}"
    sudo apt-get remove --purge -y openjdk-* && sudo update-alternatives --remove-all java && sudo rm -rf /usr/lib/jvm/* && sudo rm -f /usr/bin/java

    echo -e "${GREEN}Burp Suite and Java have been uninstalled.${RESET}"
}

# UI - Display options to the user
echo -e "${CYAN}#######################################"
echo -e "${CYAN}           Burp Suite Installer        "
echo -e "${CYAN}#######################################"
echo -e "${AUTHOR}"
echo -e "${GREEN}Please choose an option:${RESET}"
echo -e "${YELLOW}1. Install Burp Suite${RESET}"
echo -e "${RED}2. Uninstall Burp Suite${RESET}"

read -p "Enter your choice (1/2): " choice

if [ "$choice" -eq 1 ]; then
    install_burp
elif [ "$choice" -eq 2 ]; then
    uninstall_burp
else
    echo -e "${RED}Invalid choice. Exiting...${RESET}"
    exit 1
fi

