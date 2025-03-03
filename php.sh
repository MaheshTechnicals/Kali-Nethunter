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
    echo -e "${GREEN}🚀 Starting Apache & PHP Installation...${RESET}"
    
    # Step 1: Update System Packages
    echo -e "${BLUE}🔄 Updating system packages...${RESET}"
    apt update && apt upgrade -y
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to update packages. Please check your internet connection.${RESET}"
        sleep 3
        return
    fi
    
    # Step 2: Install Apache
    echo -e "${BLUE}🌐 Installing Apache Web Server...${RESET}"
    apt install apache2 -y
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install Apache.${RESET}"
        sleep 3
        return
    fi
    
    # Step 3: Install PHP and Required Modules
    echo -e "${BLUE}🛠 Installing PHP and extensions...${RESET}"
    apt install php libapache2-mod-php php-cli php-curl php-mbstring php-xml php-zip php-gd php-mysql php-bcmath -y
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install PHP and extensions.${RESET}"
        sleep 3
        return
    fi
    
    # Step 4: Configure Apache to Listen on Port 2080
    echo -e "${BLUE}⚙ Configuring Apache to use port 2080...${RESET}"
    
    # Backup original configs
    cp /etc/apache2/ports.conf /etc/apache2/ports.conf.bak
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
    
    # Use port 2080
    PORT=2080
    sed -i "s/Listen 80/Listen $PORT/" /etc/apache2/ports.conf
    sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:$PORT>/" /etc/apache2/sites-available/000-default.conf
    
    # Step 5: Restart Apache to Apply Changes
    echo -e "${BLUE}🔄 Restarting Apache...${RESET}"
    systemctl restart apache2
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to restart Apache. Reverting changes...${RESET}"
        cp /etc/apache2/ports.conf.bak /etc/apache2/ports.conf
        cp /etc/apache2/sites-available/000-default.conf.bak /etc/apache2/sites-available/000-default.conf
        systemctl restart apache2
        sleep 3
        return
    fi
    
    # Step 6: Create info.php File
    echo -e "${BLUE}📄 Creating PHP info file...${RESET}"
    echo "<?php phpinfo(); ?>" > /var/www/html/info.php
    
    # Step 7: Set Correct Permissions
    echo -e "${BLUE}🔑 Setting permissions for web directory...${RESET}"
    chmod -R 755 /var/www/html/
    chown -R www-data:www-data /var/www/html/
    
    # Enable rewrite module
    a2enmod rewrite
    systemctl restart apache2
    
    # Completion Message
    echo -e "${GREEN}✅ Installation Complete!${RESET}"
    echo -e "${YELLOW}📌 Open your browser and visit: ${CYAN}http://localhost:$PORT/info.php${RESET}"
    sleep 5
}

# Function to Start Apache (PHP)
start_php() {
    echo -e "${GREEN}🚀 Starting Apache (PHP Server)...${RESET}"
    
    # Get the current port
    PORT=$(grep -Po '(?<=Listen )(\d+)' /etc/apache2/ports.conf | head -1)
    PORT=${PORT:-2080}  # Default to 2080 if not found
    
    # Start Apache
    systemctl start apache2
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to start Apache.${RESET}"
        sleep 3
        return
    fi
    
    echo -e "${GREEN}✅ Apache Server Started on Port $PORT!${RESET}"
    echo -e "${CYAN}📌 Visit: http://localhost:$PORT/info.php${RESET}"
    sleep 3
}

# Function to Stop Apache (PHP)
stop_php() {
    echo -e "${RED}🛑 Stopping Apache (PHP Server)...${RESET}"
    
    systemctl stop apache2
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to stop Apache.${RESET}"
        sleep 3
        return
    fi
    
    echo -e "${RED}✅ Apache Server Stopped!${RESET}"
    sleep 3
}

# Function to Check Status
check_status() {
    echo -e "${CYAN}🔍 Checking Apache Status...${RESET}"
    
    # Get the current port
    PORT=$(grep -Po '(?<=Listen )(\d+)' /etc/apache2/ports.conf | head -1)
    PORT=${PORT:-2080}  # Default to 2080 if not found
    
    # Check if Apache is running
    if systemctl is-active --quiet apache2; then
        echo -e "${GREEN}✅ Apache is running on port $PORT${RESET}"
    else
        echo -e "${RED}❌ Apache is not running${RESET}"
    fi
    
    # Check PHP version
    if command -v php &> /dev/null; then
        PHP_VER=$(php -v | head -n 1 | cut -d ' ' -f 2)
        echo -e "${GREEN}✅ PHP $PHP_VER is installed${RESET}"
    else
        echo -e "${RED}❌ PHP is not installed${RESET}"
    fi
    
    sleep 5
}

# Main program loop
while true; do
    # Display Menu
    clear
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${YELLOW}   🚀 Apache & PHP Manager - Mahesh Technicals${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${GREEN} 1) Install & Configure Apache + PHP ${RESET}"
    echo -e "${BLUE} 2) Start PHP (Apache Server) ${RESET}"
    echo -e "${RED} 3) Stop PHP (Stop Apache Server) ${RESET}"
    echo -e "${YELLOW} 4) Check Status${RESET}"
    echo -e "${CYAN} 5) Exit ${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
    
    # Get user input more reliably
    echo -e "${YELLOW}Choose an option (1-5):${RESET} "
    # Use read with a timeout to prevent hanging
    read -t 60 choice
    
    # Handle empty or invalid input
    if [ -z "$choice" ]; then
        echo -e "${RED}No input received. Please try again.${RESET}"
        sleep 2
        continue
    fi
    
    # Process user choice
    case "$choice" in
        1) install_php ;;
        2) start_php ;;
        3) stop_php ;;
        4) check_status ;;
        5) echo -e "${RED}🚪 Exiting...${RESET}"; exit 0 ;;
        *) 
            echo -e "${RED}❌ Invalid Option! Please choose a valid option (1-5).${RESET}"
            sleep 2
            ;;
    esac
done
