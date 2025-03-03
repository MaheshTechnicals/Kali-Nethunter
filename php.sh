#!/bin/bash

# Define Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m' # Reset color

# Check if script is run as root/sudo
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run with sudo privileges${RESET}"
    echo -e "Please run: ${CYAN}sudo $0${RESET}"
    exit 1
fi

# Function to Install & Configure Apache + PHP
install_php() {
    echo -e "${GREEN}Starting Apache & PHP Installation...${RESET}"
    
    # Step 1: Update System Packages
    echo -e "${BLUE}Updating system packages...${RESET}"
    apt update && apt upgrade -y
    
    # Step 2: Install Apache
    echo -e "${BLUE}Installing Apache Web Server...${RESET}"
    apt install apache2 -y
    
    # Step 3: Install PHP and Required Modules
    echo -e "${BLUE}Installing PHP and extensions...${RESET}"
    apt install php libapache2-mod-php php-cli php-curl php-mbstring php-xml php-zip php-gd php-mysql php-bcmath -y
    
    # Step 4: Configure Apache to Listen on Port 2080
    echo -e "${BLUE}Configuring Apache to use port 2080...${RESET}"
    
    # Backup original configs
    cp /etc/apache2/ports.conf /etc/apache2/ports.conf.bak
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
    
    # Use port 2080
    sed -i "s/Listen 80/Listen 2080/" /etc/apache2/ports.conf
    sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:2080>/" /etc/apache2/sites-available/000-default.conf
    
    # Step 5: Restart Apache to Apply Changes
    echo -e "${BLUE}Restarting Apache...${RESET}"
    systemctl restart apache2
    
    # Step 6: Create info.php File
    echo -e "${BLUE}Creating PHP info file...${RESET}"
    echo "<?php phpinfo(); ?>" > /var/www/html/info.php
    
    # Step 7: Set Correct Permissions
    echo -e "${BLUE}Setting permissions for web directory...${RESET}"
    chmod -R 755 /var/www/html/
    chown -R www-data:www-data /var/www/html/
    
    # Enable rewrite module
    a2enmod rewrite
    systemctl restart apache2
    
    # Completion Message
    echo -e "${GREEN}Installation Complete!${RESET}"
    echo -e "${YELLOW}Open your browser and visit: ${CYAN}http://localhost:2080/info.php${RESET}"
    sleep 3
}

# Function to Start Apache (PHP)
start_php() {
    echo -e "${GREEN}Starting Apache (PHP Server)...${RESET}"
    systemctl start apache2
    echo -e "${GREEN}Apache Server Started on Port 2080!${RESET}"
    echo -e "${CYAN}Visit: http://localhost:2080/info.php${RESET}"
    sleep 2
}

# Function to Stop Apache (PHP)
stop_php() {
    echo -e "${RED}Stopping Apache (PHP Server)...${RESET}"
    systemctl stop apache2
    echo -e "${RED}Apache Server Stopped!${RESET}"
    sleep 2
}

# Function to Check Status
check_status() {
    echo -e "${CYAN}Checking Apache Status...${RESET}"
    
    # Check if Apache is running
    if systemctl is-active --quiet apache2; then
        echo -e "${GREEN}Apache is running on port 2080${RESET}"
    else
        echo -e "${RED}Apache is not running${RESET}"
    fi
    
    # Check PHP version
    if command -v php &> /dev/null; then
        PHP_VER=$(php -v | head -n 1 | cut -d ' ' -f 2)
        echo -e "${GREEN}PHP $PHP_VER is installed${RESET}"
    else
        echo -e "${RED}PHP is not installed${RESET}"
    fi
    
    sleep 3
}

# Main program - Use arguments instead of interactive menu
if [ $# -eq 0 ]; then
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${YELLOW}Apache & PHP Manager - Mahesh Technicals${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${GREEN}Usage: $0 [OPTION]${RESET}"
    echo -e "${BLUE}Options:${RESET}"
    echo -e "  ${GREEN}1, install${RESET}  - Install & Configure Apache + PHP"
    echo -e "  ${BLUE}2, start${RESET}    - Start PHP (Apache Server)"
    echo -e "  ${RED}3, stop${RESET}     - Stop PHP (Stop Apache Server)"
    echo -e "  ${YELLOW}4, status${RESET}   - Check Status"
    echo -e "${CYAN}==========================================${RESET}"
    echo
    echo -e "${YELLOW}Example: $0 install${RESET}"
    
    # Alternative menu using select command
    echo
    echo -e "${CYAN}Or select an option below:${RESET}"
    OPTIONS=("Install & Configure Apache + PHP" "Start PHP (Apache Server)" "Stop PHP (Stop Apache Server)" "Check Status" "Exit")
    select opt in "${OPTIONS[@]}"
    do
        case $REPLY in
            1) install_php; break ;;
            2) start_php; break ;;
            3) stop_php; break ;;
            4) check_status; break ;;
            5) echo -e "${RED}Exiting...${RESET}"; exit 0 ;;
            *) echo -e "${RED}Invalid option $REPLY${RESET}" ;;
        esac
    done
else
    # Process command line arguments
    case "$1" in
        1|install) install_php ;;
        2|start) start_php ;;
        3|stop) stop_php ;;
        4|status) check_status ;;
        *) echo -e "${RED}Invalid option: $1${RESET}" 
           echo -e "${YELLOW}Use: $0 [install|start|stop|status]${RESET}" ;;
    esac
fi

exit 0
