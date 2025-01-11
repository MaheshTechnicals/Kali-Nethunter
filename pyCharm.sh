#!/bin/bash

# Define functions for installation and uninstallation
install_pycharm() {
    echo "------------------------------------------------------------"
    echo "Installing PyCharm"
    echo "------------------------------------------------------------"
    
    # Check architecture
    ARCH=$(uname -m)
    
    if [[ "$ARCH" == "x86_64" ]]; then
        URL="https://download.jetbrains.com/python/pycharm-community-2023.1.4.tar.gz"
    elif [[ "$ARCH" == "arm64" ]]; then
        URL="https://download.jetbrains.com/python/pycharm-community-2023.1.4.tar.gz"
    elif [[ "$ARCH" == "aarch64" ]]; then
        URL="https://download.jetbrains.com/python/pycharm-community-2023.1.4.tar.gz"
    else
        echo "Unsupported architecture for installation! Exiting..."
        exit 1
    fi

    # Download PyCharm
    echo "Downloading PyCharm..."
    wget $URL -O pycharm.tar.gz

    if [[ $? -ne 0 ]]; then
        echo "Download failed! Exiting..."
        exit 1
    fi

    # Extracting the tar.gz file with a progress bar
    echo "Extracting PyCharm..."
    tar -xzf pycharm.tar.gz -C /opt/
    
    # Create symlink for easy access
    echo "Creating Symlink for PyCharm"
    sudo ln -s /opt/pycharm-community-*/bin/pycharm.sh /usr/local/bin/pycharm
    
    # Clean up
    rm -f pycharm.tar.gz

    echo "PyCharm has been installed successfully!"
}

uninstall_pycharm() {
    echo "------------------------------------------------------------"
    echo "Uninstalling PyCharm"
    echo "------------------------------------------------------------"

    # Check if PyCharm is installed
    if [[ ! -f "/usr/local/bin/pycharm" ]]; then
        echo "PyCharm is not installed on your system."
        return
    fi

    # Remove symlink
    echo "Removing symlink..."
    sudo rm /usr/local/bin/pycharm

    # Remove PyCharm installation directory
    echo "Removing PyCharm installation directory..."
    sudo rm -rf /opt/pycharm-community-*

    # Remove configuration files
    echo "Removing PyCharm configuration files..."
    rm -rf ~/.config/JetBrains/PyCharm*
    rm -rf ~/.local/share/JetBrains/PyCharm*
    rm -rf ~/.cache/JetBrains/PyCharm*

    # Remove desktop entries
    rm -f ~/.local/share/applications/pycharm.desktop

    # Remove any other residual files
    find ~ -name "*pycharm*" -exec rm -rf {} \;

    echo "PyCharm has been uninstalled successfully!"
}

# Main script loop
while true; do
    clear
    echo "############################################################"
    echo "#                   PyCharm Installer                      #"
    echo "#                 Author: MaheshTechnicals                 #"
    echo "############################################################"
    echo
    echo "Please choose an option:"
    echo "1) Install PyCharm"
    echo "2) Uninstall PyCharm"
    echo "3) Exit"
    read -p "Enter your choice (1/2/3): " choice
    
    case $choice in
        1)
            install_pycharm
            ;;
        2)
            uninstall_pycharm
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select 1, 2, or 3."
            ;;
    esac
    read -p "Press any key to continue..."
done

