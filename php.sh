#!/bin/bash

# Define Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m' # Reset color

# Author Info
clear
echo -e "${CYAN}==========================================${RESET}"
echo -e "${YELLOW}   🚀 Apache & PHP Manager - Mahesh Technicals${RESET}"
echo -e "${CYAN}==========================================${RESET}"

# Display Menu Options
echo -e "${GREEN} 1) Install & Configure Apache + PHP ${RESET}"
echo -e "${BLUE} 2) Start PHP (Apache Server) ${RESET}"
echo -e "${RED} 3) Stop PHP (Stop Apache Server) ${RESET}"
echo -e "${YELLOW} 4) Exit ${RESET}"
echo -e "${CYAN}==========================================${RESET}"

# Read User Choice
read -p "💡 Choose an option (1-4): " choice

# Function to Install & Configure Apache + PHP
install_php() {
    echo -e "${GREEN}🚀 Starting Apache & PHP Installation...${RESET}"
    
    # Step 1: Update System Packages
    echo -e "${BLUE}🔄 Updating system packages...${RESET}"
    sudo apt update && sudo apt upgrade -y

    # Step 2: Install Apache
    echo -e "${BLUE}🌐 Installing Apache Web Server...${RESET}"
    sudo apt install apache2 -y

    # Step 3: Install PHP and Required Modules
    echo -e "${BLUE}🛠 Installing PHP and extensions...${RESET}"
    sudo apt install php libapache2-mod-php php-cli php-curl php-mbstring php-xml php-zip php-gd php-mysql php-bcmath -y

    # Step 4: Ensure Apache Listens on Port 2080
    echo -e "${BLUE}⚙ Configuring Apache to use port 2080...${RESET}"
    sudo sed -i 's/Listen 80/Listen 2080/' /etc/apache2/ports.conf
    sudo sed -i 's/:80>/:2080>/' /etc/apache2/sites-available/000-default.conf

    # Step 5: Restart Apache to Apply Changes
    echo -e "${BLUE}🔄 Restarting Apache...${RESET}"
    sudo service apache2 restart

    # Step 6: Create info.php File
    echo -e "${BLUE}📄 Creating PHP info file...${RESET}"
    echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null

    # Step 7: Set Correct Permissions
    echo -e "${BLUE}🔑 Setting permissions for web directory...${RESET}"
    sudo chmod -R 755 /var/www/html/
    sudo chown -R www-data:www-data /var/www/html/

    # Completion Message
    echo -e "${GREEN}✅ Installation Complete!${RESET}"
    echo -e "${YELLOW}📌 Open your browser and visit: ${CYAN}http://localhost:2080/info.php${RESET}"
}

# Function to Start Apache (PHP)
start_php() {
    echo -e "${GREEN}🚀 Starting Apache (PHP Server)...${RESET}"
    sudo service apache2 start
    echo -e "${YELLOW}✅ Apache Server Started on Port 2080!${RESET}"
    echo -e "${CYAN}📌 Visit: http://localhost:2080/info.php${RESET}"
}

# Function to Stop Apache (PHP)
stop_php() {
    echo -e "${RED}🛑 Stopping Apache (PHP Server)...${RESET}"
    sudo service apache2 stop
    echo -e "${RED}✅ Apache Server Stopped!${RESET}"
}

# Execute based on User Choice
case "$choice" in
    1) install_php ;;
    2) start_php ;;
    3) stop_php ;;
    4) echo -e "${RED}🚪 Exiting...${RESET}"; exit ;;
    *) echo -e "${RED}❌ Invalid Option! Please choose a valid option.${RESET}" ;;
esac
