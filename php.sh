#!/bin/bash

# Define Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m' # Reset color

# Detect environment and set service manager accordingly
if command -v systemctl &> /dev/null && pidof systemd &> /dev/null; then
    # systemd is available and running
    SERVICE_MGR="systemd"
elif command -v service &> /dev/null; then
    # service command is available (SysVinit or compatible)
    SERVICE_MGR="sysvinit"
else
    # Fallback to direct process management
    SERVICE_MGR="process"
fi

# Function to start Apache based on available service manager
start_apache() {
    case $SERVICE_MGR in
        systemd)
            systemctl start apache2
            return $?
            ;;
        sysvinit)
            service apache2 start
            return $?
            ;;
        process)
            if [ -x /usr/sbin/apachectl ]; then
                /usr/sbin/apachectl start
            elif [ -x /usr/sbin/apache2ctl ]; then
                /usr/sbin/apache2ctl start
            else
                echo "Apache control command not found"
                return 1
            fi
            return $?
            ;;
    esac
}

# Function to stop Apache based on available service manager
stop_apache() {
    case $SERVICE_MGR in
        systemd)
            systemctl stop apache2
            return $?
            ;;
        sysvinit)
            service apache2 stop
            return $?
            ;;
        process)
            if [ -x /usr/sbin/apachectl ]; then
                /usr/sbin/apachectl stop
            elif [ -x /usr/sbin/apache2ctl ]; then
                /usr/sbin/apache2ctl stop
            else
                echo "Apache control command not found"
                return 1
            fi
            return $?
            ;;
    esac
}

# Function to check if Apache is running
is_apache_running() {
    case $SERVICE_MGR in
        systemd)
            systemctl is-active --quiet apache2
            return $?
            ;;
        sysvinit)
            service apache2 status &> /dev/null
            return $?
            ;;
        process)
            # Try to find apache processes
            pgrep -f "apache2|httpd" &> /dev/null
            return $?
            ;;
    esac
}

# Function to Install & Configure Apache + PHP
install_php() {
    echo -e "${GREEN}🚀 Starting Apache & PHP Installation...${RESET}"
    
    # Detect package manager
    if command -v apt &> /dev/null; then
        PKG_MGR="apt"
    elif command -v pkg &> /dev/null; then
        PKG_MGR="pkg"  # For Termux
    elif command -v yum &> /dev/null; then
        PKG_MGR="yum"
    else
        echo -e "${RED}❌ No supported package manager found.${RESET}"
        return 1
    fi
    
    # Step 1: Update System Packages
    echo -e "${BLUE}🔄 Updating system packages...${RESET}"
    case $PKG_MGR in
        apt)
            apt update && apt upgrade -y
            ;;
        pkg)
            pkg update && pkg upgrade -y
            ;;
        yum)
            yum update -y
            ;;
    esac
    
    # Step 2: Install Apache
    echo -e "${BLUE}🌐 Installing Apache Web Server...${RESET}"
    case $PKG_MGR in
        apt)
            apt install apache2 -y
            ;;
        pkg)
            pkg install apache2 -y
            ;;
        yum)
            yum install httpd -y
            ;;
    esac
    
    # Step 3: Install PHP and Required Modules
    echo -e "${BLUE}🛠 Installing PHP and extensions...${RESET}"
    case $PKG_MGR in
        apt)
            apt install php libapache2-mod-php php-cli php-curl php-mbstring php-xml php-zip php-gd php-mysql php-bcmath -y
            ;;
        pkg)
            pkg install php php-apache -y
            ;;
        yum)
            yum install php php-cli php-curl php-mbstring php-xml php-zip php-gd php-mysql php-bcmath -y
            ;;
    esac
    
    # Step 4: Find the Apache config directory
    if [ -d "/etc/apache2" ]; then
        APACHE_DIR="/etc/apache2"
        CONF_FILE="$APACHE_DIR/ports.conf"
        VHOST_FILE="$APACHE_DIR/sites-available/000-default.conf"
    elif [ -d "/data/data/com.termux/files/usr/etc/apache2" ]; then
        # Termux path
        APACHE_DIR="/data/data/com.termux/files/usr/etc/apache2"
        CONF_FILE="$APACHE_DIR/httpd.conf"
        VHOST_FILE="$CONF_FILE"  # Use same file in Termux
    elif [ -d "/etc/httpd" ]; then
        APACHE_DIR="/etc/httpd"
        CONF_FILE="$APACHE_DIR/conf/httpd.conf"
        VHOST_FILE="$APACHE_DIR/conf.d/vhost.conf"
    else
        echo -e "${RED}❌ Apache configuration directory not found.${RESET}"
        return 1
    fi
    
    # Step 5: Configure Apache to Listen on Port 2080
    echo -e "${BLUE}⚙ Configuring Apache to use port 2080...${RESET}"
    
    # Backup original configs
    if [ -f "$CONF_FILE" ]; then
        cp "$CONF_FILE" "$CONF_FILE.bak"
    fi
    
    if [ -f "$VHOST_FILE" ]; then
        cp "$VHOST_FILE" "$VHOST_FILE.bak"
    fi
    
    # Use port 2080 - adapt to different config file formats
    if [ -f "$CONF_FILE" ]; then
        if grep -q "Listen 80" "$CONF_FILE"; then
            sed -i "s/Listen 80/Listen 2080/" "$CONF_FILE"
        else
            echo "Listen 2080" >> "$CONF_FILE"
        fi
    fi
    
    if [ -f "$VHOST_FILE" ]; then
        if grep -q "<VirtualHost \*:80>" "$VHOST_FILE"; then
            sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:2080>/" "$VHOST_FILE"
        fi
    fi
    
    # Step 6: Find web root directory
    if [ -d "/var/www/html" ]; then
        WEB_ROOT="/var/www/html"
    elif [ -d "/data/data/com.termux/files/usr/share/apache2/default-site/htdocs" ]; then
        WEB_ROOT="/data/data/com.termux/files/usr/share/apache2/default-site/htdocs"
    elif [ -d "/var/www" ]; then
        WEB_ROOT="/var/www"
    else
        echo -e "${YELLOW}⚠️ Web root directory not found, using current directory.${RESET}"
        WEB_ROOT="$(pwd)"
    fi
    
    # Step 7: Create info.php File
    echo -e "${BLUE}📄 Creating PHP info file...${RESET}"
    echo "<?php phpinfo(); ?>" > "$WEB_ROOT/info.php"
    
    # Step 8: Set Correct Permissions if not in Termux
    echo -e "${BLUE}🔑 Setting permissions for web directory...${RESET}"
    if [ "$PKG_MGR" != "pkg" ]; then
        chmod -R 755 "$WEB_ROOT"
        if getent group www-data &>/dev/null; then
            chown -R www-data:www-data "$WEB_ROOT"
        elif getent group apache &>/dev/null; then
            chown -R apache:apache "$WEB_ROOT"
        fi
    fi
    
    # Step 9: Restart Apache to Apply Changes
    echo -e "${BLUE}🔄 Restarting Apache...${RESET}"
    stop_apache
    start_apache
    
    # Completion Message
    echo -e "${GREEN}✅ Installation Complete!${RESET}"
    echo -e "${YELLOW}📌 Open your browser and visit: ${CYAN}http://localhost:2080/info.php${RESET}"
    sleep 3
}

# Function to Start Apache (PHP)
start_php() {
    echo -e "${GREEN}🚀 Starting Apache (PHP Server)...${RESET}"
    
    if start_apache; then
        echo -e "${GREEN}✅ Apache Server Started!${RESET}"
        echo -e "${CYAN}📌 Visit: http://localhost:2080/info.php${RESET}"
    else
        echo -e "${RED}❌ Failed to start Apache.${RESET}"
    fi
    
    sleep 2
}

# Function to Stop Apache (PHP)
stop_php() {
    echo -e "${RED}🛑 Stopping Apache (PHP Server)...${RESET}"
    
    if stop_apache; then
        echo -e "${RED}✅ Apache Server Stopped!${RESET}"
    else
        echo -e "${RED}❌ Failed to stop Apache.${RESET}"
    fi
    
    sleep 2
}

# Function to Check Status
check_status() {
    echo -e "${CYAN}🔍 Checking Apache Status...${RESET}"
    
    # Check if Apache is running
    if is_apache_running; then
        echo -e "${GREEN}✅ Apache is running (likely on port 2080)${RESET}"
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
    
    sleep 3
}

# Main program - Handle menu
while true; do
    # Display Menu
    clear
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${YELLOW}🚀 Apache & PHP Manager - Mahesh Technicals${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
    echo -e "${GREEN}1) Install & Configure Apache + PHP ${RESET}"
    echo -e "${BLUE}2) Start PHP (Apache Server) ${RESET}"
    echo -e "${RED}3) Stop PHP (Stop Apache Server) ${RESET}"
    echo -e "${YELLOW}4) Check Status${RESET}"
    echo -e "${CYAN}5) Exit ${RESET}"
    echo -e "${CYAN}==========================================${RESET}"
    
    # Use a more compatible approach for input
    echo -e "${YELLOW}Choose an option (1-5): ${RESET}\c"
    read choice
    
    case "$choice" in
        1) install_php ;;
        2) start_php ;;
        3) stop_php ;;
        4) check_status ;;
        5) echo -e "${RED}🚪 Exiting...${RESET}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid option. Please try again.${RESET}"; sleep 2 ;;
    esac
done
