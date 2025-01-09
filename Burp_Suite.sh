#!/bin/bash

# Script header
echo -e "\n        ##############################################"
echo -e "        ##                                          ##"
echo -e "        ##      Burp Suite Installer by Mahesh      ##"
echo -e "        ##                                          ##"
echo -e "        ##############################################\n"

# Function to check if bc is installed
check_bc() {
    if ! command -v bc &> /dev/null; then
        echo "bc not found. Installing bc..."
        sudo apt-get update && sudo apt-get install -y bc
    fi
}

# Check Java version
check_java_version() {
    echo -e "\nChecking Java version..."

    # Check if Java is installed
    if ! command -v java &> /dev/null; then
        echo "Java is not installed."
        exit 1
    fi

    # Get the installed Java version
    java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    echo "Java Version Installed: $java_version"

    # Compare Java version
    required_version="17"
    if [ $(echo "$java_version" | awk -F. '{print $1}') -lt $required_version ]; then
        echo "Java version is lower than 17. Please install Java 17 or higher."
        exit 1
    fi
}

# Function to install Burp Suite
install_burp_suite() {
    echo -e "\nDownloading Burp Suite..."
    wget -q "https://portswigger-cdn.net/burp/releases/download?product=community&type=jar" -O Burp.jar
    mkdir -p /opt/Burp_Suite/
    mv Burp.jar /opt/Burp_Suite/
    chmod +x /opt/Burp_Suite/Burp.jar
    echo -e "\nBurp Suite installed successfully."
    echo "Run the following command to open Burp Suite: "
    echo -e "\nburp\n"
}

# Function to uninstall Burp Suite
uninstall_burp_suite() {
    echo -e "\nUninstalling Burp Suite..."
    rm -rf /opt/Burp_Suite
    rm -f /usr/bin/burp
    echo -e "\nBurp Suite has been uninstalled."
}

# Function to uninstall Java
uninstall_java() {
    echo -e "\nUninstalling Java..."
    sudo apt-get remove --purge -y openjdk-*
    echo -e "\nJava has been uninstalled."
}

# Main Menu
echo -e "\nPlease select an option:"
echo -e "1. Install Burp Suite"
echo -e "2. Uninstall Burp Suite"
echo -e "3. Uninstall Java"
echo -e "4. Exit"
read -p "Enter your choice: " choice

case $choice in
    1)
        # Install bc if not installed
        check_bc

        # Check Java version
        check_java_version

        # Install Burp Suite
        install_burp_suite
        ;;

    2)
        # Uninstall Burp Suite
        uninstall_burp_suite
        ;;

    3)
        # Uninstall Java
        uninstall_java
        ;;

    4)
        echo "Exiting..."
        exit 0
        ;;

    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

