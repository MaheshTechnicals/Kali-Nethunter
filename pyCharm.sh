#!/bin/bash

# Function to print colorful text
print_color() {
    case $1 in
        "green") echo -e "\e[32m$2\e[0m" ;;
        "yellow") echo -e "\e[33m$2\e[0m" ;;
        "red") echo -e "\e[31m$2\e[0m" ;;
        "blue") echo -e "\e[34m$2\e[0m" ;;
        "bold") echo -e "\e[1m$2\e[0m" ;;
        "underline") echo -e "\e[4m$2\e[0m" ;;
        *) echo "$2" ;;
    esac
}

# Function to install PyCharm
install_pycharm() {
    print_color "blue" "------------------------------------------------------------"
    print_color "blue" "Installing PyCharm"
    print_color "blue" "------------------------------------------------------------"
    
    # Check architecture
    ARCH=$(uname -m)
    
    if [[ "$ARCH" == "x86_64" ]]; then
        URL="https://download.jetbrains.com/python/pycharm-community-2023.1.4.tar.gz"
    elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
        URL="https://download.jetbrains.com/python/pycharm-community-2023.1.4.tar.gz"
    else
        print_color "red" "Unsupported architecture for installation! Exiting..."
        exit 1
    fi

    # Download PyCharm
    print_color "yellow" "Downloading PyCharm..."
    wget $URL -O pycharm.tar.gz

    if [[ $? -ne 0 ]]; then
        print_color "red" "Download failed! Exiting..."
        exit 1
    fi

    # Extracting the tar.gz file with a progress bar
    print_color "yellow" "Extracting PyCharm..."
    tar -xzf pycharm.tar.gz -C /opt/ &> /dev/null

    # Check if the symlink already exists, remove if it does
    if [[ -f "/usr/local/bin/pycharm" ]]; then
        print_color "yellow" "Symlink already exists. Removing the old one..."
        sudo rm /usr/local/bin/pycharm
    fi

    # Create symlink for easy access
    print_color "yellow" "Creating Symlink for PyCharm"
    sudo ln -s /opt/pycharm-community-*/bin/pycharm.sh /usr/local/bin/pycharm

    # Clean up
    rm -f pycharm.tar.gz

    print_color "green" "PyCharm has been installed successfully!"
}

# Function to uninstall PyCharm
uninstall_pycharm() {
    print_color "blue" "------------------------------------------------------------"
    print_color "blue" "Uninstalling PyCharm"
    print_color "blue" "------------------------------------------------------------"

    # Check if PyCharm is installed
    if [[ ! -f "/usr/local/bin/pycharm" ]]; then
        print_color "yellow" "PyCharm is not installed on your system."
        return
    fi

    # Remove the symlink
    print_color "yellow" "Removing symlink..."
    sudo rm /usr/local/bin/pycharm

    # Remove PyCharm installation directory
    print_color "yellow" "Removing PyCharm installation directory..."
    sudo rm -rf /opt/pycharm-community-*

    # Remove PyCharm directory if it exists
    if [[ -d "/opt/pycharm" ]]; then
        print_color "yellow" "Removing /opt/pycharm directory..."
        sudo rm -rf /opt/pycharm
    fi

    # Check for any remaining PyCharm directories in /opt/
    print_color "yellow" "Checking for any remaining PyCharm directories in /opt/..."
    for dir in /opt/pycharm*; do
        if [[ -d "$dir" ]]; then
            print_color "yellow" "Removing remaining directory: $dir"
            sudo rm -rf "$dir"
        fi
    done

    # Remove configuration files
    print_color "yellow" "Removing PyCharm configuration files..."
    rm -rf ~/.config/JetBrains/PyCharm*
    rm -rf ~/.local/share/JetBrains/PyCharm*
    rm -rf ~/.cache/JetBrains/PyCharm*

    # Remove desktop entries
    rm -f ~/.local/share/applications/pycharm.desktop

    # Remove any other residual files
    find ~ -name "*pycharm*" -exec rm -rf {} \;

    print_color "green" "PyCharm has been uninstalled successfully!"
}

# Main script loop
while true; do
    clear
    print_color "blue" "############################################################"
    print_color "blue" "#                   PyCharm Installer                      #"
    print_color "blue" "#                 Author: MaheshTechnicals                 #"
    print_color "blue" "############################################################"
    echo
    print_color "yellow" "Please choose an option:"
    print_color "yellow" "1) Install PyCharm"
    print_color "yellow" "2) Uninstall PyCharm"
    print_color "yellow" "3) Exit"
    read -p "Enter your choice (1/2/3): " choice
    
    case $choice in
        1)
            install_pycharm
            ;;
        2)
            uninstall_pycharm
            ;;
        3)
            print_color "green" "Exiting..."
            exit 0
            ;;
        *)
            print_color "red" "Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
    read -p "Press any key to continue..."
done

