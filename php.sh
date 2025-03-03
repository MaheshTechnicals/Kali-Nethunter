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

# Function to display the main menu
display_menu() {
    clear
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${YELLOW}   🚀 Apache & PHP Manager - Mahesh Technicals${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
    # Display Menu Options
    echo -e "${GREEN} 1) Install & Configure Apache + PHP ${RESET}"
    echo -e "${BLUE} 2) Start PHP (Apache Server) ${RESET}"
    echo -e "${RED} 3) Stop PHP (Stop Apache Server) ${RESET}"
    echo -e "${YELLOW} 4) Check Status${RESET}"
    echo -e "${CYAN} 5) Exit ${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
}

# Function to Install & Configure Apache + PHP
install_php() {
    echo -e "${GREEN}🚀 Starting Apache & PHP Installation...${RESET}"
    
    # Step 1: Update System Packages
    echo -e "${BLUE}🔄 Updating system packages...${RESET}"
    apt update && apt upgrade -y || {
        echo -e "${RED}❌ Failed to update packages. Please check your internet connection.${RESET}"
        return 1
    }
    
    # Step 2: Install Apache
    echo -e "${BLUE}🌐 Installing Apache Web Server...${RESET}"
    apt install apache2 -y || {
        echo -e "${RED}❌ Failed to install Apache.${RESET}"
        return 1
    }
    
    # Step 3: Install PHP and Required Modules
    echo -e "${BLUE}🛠 Installing PHP and extensions...${RESET}"
    apt install php libapache2-mod-php php-cli php-curl php-mbstring php-xml php-zip php-gd php-mysql php-bcmath -y || {
        echo -e "${RED}❌ Failed to install PHP and extensions.${RESET}"
        return 1
    }
    
    # Step 4: Back up original config files before modifying
    echo -e "${BLUE}💾 Backing up configuration files...${RESET}"
    cp /etc/apache2/ports.conf /etc/apache2/ports.conf.backup
    cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.backup
    
    # Step 5: Configure Apache to Listen on Port 2080
    echo -e "${BLUE}⚙ Configuring Apache to use port 2080...${RESET}"
    # First check if port 2080 is already in use
    if lsof -i:2080 &>/dev/null; then
        echo -e "${YELLOW}⚠️ Port 2080 is already in use. Would you like to use a different port? (y/n)${RESET}"
        read -r use_different_port
        if [[ $use_different_port =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}Enter a different port number:${RESET}"
            read -r port_number
            # Validate port number
            if ! [[ "$port_number" =~ ^[0-9]+$ ]] || [ "$port_number" -lt 1024 ] || [ "$port_number" -gt 65535 ]; then
                echo -e "${RED}❌ Invalid port number. Using default 8080.${RESET}"
                port_number=8080
            fi
        else
            port_number=8080
            echo -e "${YELLOW}Using alternative port 8080${RESET}"
        fi
    else
        port_number=2080
    fi
    
    # Update configuration files
    sed -i "s/Listen 80/Listen $port_number/" /etc/apache2/ports.conf
    sed -i "s/:80>/:$port_number>/" /etc/apache2/sites-available/000-default.conf
    
    # Step 6: Restart Apache to Apply Changes
    echo -e "${BLUE}🔄 Restarting Apache...${RESET}"
    systemctl restart apache2 || {
        echo -e "${RED}❌ Failed to restart Apache. Rolling back configuration changes...${RESET}"
        cp /etc/apache2/ports.conf.backup /etc/apache2/ports.conf
        cp /etc/apache2/sites-available/000-default.conf.backup /etc/apache2/sites-available/000-default.conf
        systemctl restart apache2
        return 1
    }
    
    # Step 7: Create info.php File
    echo -e "${BLUE}📄 Creating PHP info file...${RESET}"
    echo "<?php phpinfo(); ?>" > /var/www/html/info.php
    
    # Step 8: Set Correct Permissions
    echo -e "${BLUE}🔑 Setting permissions for web directory...${RESET}"
    chmod -R 755 /var/www/html/
    chown -R www-data:www-data /var/www/html/
    
    # Enable required modules
    echo -e "${BLUE}🔌 Enabling required Apache modules...${RESET}"
    a2enmod rewrite
    systemctl restart apache2
    
    # Completion Message
    echo -e "${GREEN}✅ Installation Complete!${RESET}"
    echo -e "${YELLOW}📌 Open your browser and visit: ${CYAN}http://localhost:$port_number/info.php${RESET}"
    echo -e "${BLUE}Press any key to continue...${RESET}"
    read -n 1
}

# Function to Start Apache (PHP)
start_php() {
    echo -e "${GREEN}🚀 Starting Apache (PHP Server)...${RESET}"
    
    # Check if Apache is already running
    if systemctl is-active --quiet apache2; then
        echo -e "${YELLOW}⚠️ Apache is already running.${RESET}"
    else
        systemctl start apache2 || {
            echo -e "${RED}❌ Failed to start Apache.${RESET}"
            return 1
        }
        echo -e "${GREEN}✅ Apache Server Started!${RESET}"
    fi
    
    # Get the port Apache is listening on
    local port=$(grep -Po '(?<=Listen )(\d+)' /etc/apache2/ports.conf | head -1)
    port=${port:-80} # Default to 80 if not found
    
    echo -e "${CYAN}📌 Visit: http://localhost:$port/info.php${RESET}"
    echo -e "${BLUE}Press any key to continue...${RESET}"
    read -n 1
}

# Function to Stop Apache (PHP)
stop_php() {
    echo -e "${RED}🛑 Stopping Apache (PHP Server)...${RESET}"
    
    # Check if Apache is already stopped
    if ! systemctl is-active --quiet apache2; then
        echo -e "${YELLOW}⚠️ Apache is already stopped.${RESET}"
    else
        systemctl stop apache2 || {
            echo -e "${RED}❌ Failed to stop Apache.${RESET}"
            return 1
        }
        echo -e "${RED}✅ Apache Server Stopped!${RESET}"
    fi
    
    echo -e "${BLUE}Press any key to continue...${RESET}"
    read -n 1
}

# Function to check Apache status
check_status() {
    echo -e "${CYAN}🔍 Checking Apache Status...${RESET}"
    
    # Display service status
    systemctl status apache2 --no-pager
    
    # Get port information
    local port=$(grep -Po '(?<=Listen )(\d+)' /etc/apache2/ports.conf | head -1)
    port=${port:-80} # Default to 80 if not found
    
    echo -e "${CYAN}📌 Apache is configured to listen on port: $port${RESET}"
    
    # Check if PHP is installed
    if command -v php &> /dev/null; then
        php_version=$(php -v | head -n 1 | cut -d' ' -f2)
        echo -e "${GREEN}✅ PHP is installed (Version: $php_version)${RESET}"
    else
        echo -e "${RED}❌ PHP is not installed${RESET}"
    fi
    
    echo -e "${BLUE}Press any key to continue...${RESET}"
    read -n 1
}

# Main program loop
while true; do
    display_menu
    read -p "💡 Choose an option (1-5): " choice
    
    case "$choice" in
        1) install_php ;;
        2) start_php ;;
        3) stop_php ;;
        4) check_status ;;
        5) echo -e "${RED}🚪 Exiting...${RESET}"; exit 0 ;;
        *) 
            echo -e "${RED}❌ Invalid Option! Please choose a valid option.${RESET}"
            sleep 2
            ;;
    esac
done
