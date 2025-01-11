#!/bin/bash

# Function to print colorful output
print_color() {
    case $1 in
        "red")
            echo -e "\e[31m$2\e[0m"
            ;;
        "green")
            echo -e "\e[32m$2\e[0m"
            ;;
        "yellow")
            echo -e "\e[33m$2\e[0m"
            ;;
        "blue")
            echo -e "\e[34m$2\e[0m"
            ;;
        *)
            echo "$2"
            ;;
    esac
}

# Function to check if PyCharm is installed
is_pycharm_installed() {
    if [ -d "/opt/pycharm" ] || [ -d "/opt/pycharm-community-2024.2.4" ]; then
        return 0
    else
        return 1
    fi
}

# Install PyCharm
install_pycharm() {
    print_color "blue" "------------------------------------------------------------"
    print_color "blue" "Installing PyCharm"
    print_color "blue" "------------------------------------------------------------"
    
    # Check architecture
    ARCH=$(uname -m)
    
    if [[ "$ARCH" == "x86_64" ]]; then
        URL="https://download.jetbrains.com/python/pycharm-community-2024.2.4.tar.gz"
    elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
        URL="https://download.jetbrains.com/python/pycharm-community-2024.2.4.tar.gz"
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

    # Create PyCharm desktop entry
    print_color "yellow" "Creating PyCharm desktop entry..."
    cat << EOF | sudo tee /usr/share/applications/pycharm.desktop > /dev/null
[Desktop Entry]
Name=PyCharm
Comment=Integrated Development Environment for Python
Exec=/opt/pycharm-community-*/bin/pycharm.sh %f
Icon=/opt/pycharm-community-*/bin/pycharm.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

    print_color "green" "PyCharm has been installed successfully!"
}

# Uninstall PyCharm
uninstall_pycharm() {
    print_color "blue" "------------------------------------------------------------"
    print_color "blue" "Uninstalling PyCharm"
    print_color "blue" "------------------------------------------------------------"
    
    if is_pycharm_installed; then
        print_color "yellow" "Removing PyCharm directories..."
        sudo rm -rf /opt/pycharm*
        
        print_color "yellow" "Removing PyCharm symlink..."
        sudo rm -f /usr/local/bin/pycharm

        print_color "yellow" "Removing PyCharm desktop entry..."
        sudo rm -f /usr/share/applications/pycharm.desktop

        print_color "green" "PyCharm has been uninstalled successfully!"
    else
        print_color "red" "PyCharm is not installed on your system."
    fi
}

# Main menu
while true; do
    print_color "blue" "############################################################"
    print_color "blue" "#                   PyCharm Installer                    #"
    print_color "blue" "#                 Author: MaheshTechnicals               #"
    print_color "blue" "############################################################"

    print_color "yellow" "Please choose an option:"
    print_color "yellow" "1) Install PyCharm"
    print_color "yellow" "2) Uninstall PyCharm"
    print_color "yellow" "3) Exit"

    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1)
            # Check if PyCharm is installed, if yes, uninstall it first
            if is_pycharm_installed; then
                print_color "yellow" "PyCharm is already installed. Uninstalling first..."
                uninstall_pycharm
            fi
            install_pycharm
            ;;
        2)
            uninstall_pycharm
            ;;
        3)
            print_color "blue" "Exiting..."
            break
            ;;
        *)
            print_color "red" "Invalid choice! Please choose a valid option."
            ;;
    esac

    read -p "Press any key to continue..." -n1 -s
    echo ""
done

