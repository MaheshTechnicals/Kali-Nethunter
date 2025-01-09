#!/bin/bash

# Define colors for UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Function to Install Burp Suite
install_burp() {
    echo -e "${GREEN}Installing Burp Suite...${RESET}"

    # Check if Java 23 is installed
    if ! command -v java &> /dev/null; then
        echo -e "${YELLOW}Java is not installed. Installing Java 23...${RESET}"
        # [Insert Java installation steps here (same as previous script)]
        # Refer to previous code for installing Java
    fi

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

    # Check if running in headless mode (no X11 display)
    if [ -z "$DISPLAY" ]; then
        echo -e "${YELLOW}No X11 display detected. Running Burp Suite with xvfb...${RESET}"
        xvfb-run java -jar $BURP_DIR/Burp.jar
    else
        echo -e "${GREEN}Opening Burp Suite...${RESET}"
        burp
    fi

    # Display Java Version
    echo -e "${CYAN}Java Version Installed:${RESET}"
    java -version
}

# Function to Uninstall Burp Suite
uninstall_burp() {
    echo -e "${RED}Uninstalling Burp Suite...${RESET}"
    rm -rf /root/Burp_Suite
    rm -f /usr/bin/burp
    echo -e "${GREEN}Burp Suite has been uninstalled.${RESET}"
}

# UI - Display options to the user
echo -e "${CYAN}#######################################"
echo -e "${CYAN}           Burp Suite Installer        "
echo -e "${CYAN}#######################################"
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

