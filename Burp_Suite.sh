#!/bin/bash

# Define Color Variables
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'

# Banner Section
echo -e "${CYAN}
              #######  ######  ###########
              ###  ##  ## ###  ###########
              ###  ###### ###       ##
              ###         ###       ##
              ###         ###       ##
              ###         ###       ##
        ################################################
         Burp Suite Installer by Mahesh Technicals
        ################################################${RESET}"

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

    # Launch Burp Suite
    echo -e "${GREEN}Opening Burp Suite...${RESET}"
    burp
}

# Function to Uninstall Burp Suite
uninstall_burp() {
    echo -e "${RED}Uninstalling Burp Suite...${RESET}"

    # Check if Burp Suite is installed by verifying the existence of the burp command
    if command -v burp &> /dev/null; then
        echo -e "${CYAN}Burp Suite found. Proceeding with uninstallation...${RESET}"

        # Remove the Burp Suite files and the launcher script
        rm -f /usr/bin/burp
        rm -rf /root/Burp_Suite/
        
        echo -e "${GREEN}Burp Suite has been uninstalled successfully.${RESET}"
    else
        echo -e "${YELLOW}Burp Suite is not installed.${RESET}"
    fi
}

# Main Menu for Installation/Uninstallation
echo -e "${WHITE}Choose an option: ${RESET}"

# Display Table Format for Options
echo -e "${CYAN}
+---------------------+---------------------------------------+
| ${WHITE}Option${CYAN}             | ${WHITE}Action${CYAN}                            |
+---------------------+---------------------------------------+
| ${GREEN}1.${CYAN} Install Burp Suite | ${WHITE}Installs Burp Suite${CYAN}          |
| ${RED}2.${CYAN} Uninstall Burp Suite| ${WHITE}Uninstalls Burp Suite${CYAN}        |
+---------------------+---------------------------------------+${RESET}"

# Prompt for User Input
read -p "Enter 1 or 2 to choose an option: " choice

if [[ "$choice" -eq 1 ]]; then
    install_burp
elif [[ "$choice" -eq 2 ]]; then
    uninstall_burp
else
    echo -e "${RED}Invalid choice. Please choose 1 to install or 2 to uninstall.${RESET}"
    exit 1
fi

