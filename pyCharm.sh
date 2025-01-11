#!/bin/bash

#===============================#
#       PyCharm Installer       #
#  Script by MaheshTechnicals   #
#===============================#

# Define colors for the UI
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Stylish header
echo -e "${CYAN}"
echo "############################################################"
echo "#                   PyCharm Installer                      #"
echo "#                 Author: MaheshTechnicals                #"
echo "############################################################"
echo -e "${RESET}"

# Function to print a title
print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

# Function to check if PyCharm is already installed
check_pycharm_installed() {
    if [ -d "/opt/pycharm" ]; then
        return 0 # PyCharm is installed
    else
        return 1 # PyCharm is not installed
    fi
}

# Function to install PyCharm
install_pycharm() {
    local edition=$1
    local url
    local install_dir="/opt/pycharm"

    if [[ "$edition" == "community" ]]; then
        url="https://download.jetbrains.com/python/pycharm-community-2024.3.1.1.tar.gz"
    elif [[ "$edition" == "professional" ]]; then
        url="https://download.jetbrains.com/python/pycharm-professional-2024.3.1.1.tar.gz"
    else
        echo -e "${RED}Invalid edition specified.${RESET}"
        return 1
    fi

    # Download PyCharm
    print_title "Downloading PyCharm $edition Edition"
    wget -q --show-progress "$url" -O pycharm.tar.gz

    # Extract PyCharm
    print_title "Extracting PyCharm"
    tar -xzf pycharm.tar.gz
    rm pycharm.tar.gz

    # Move PyCharm to /opt directory
    print_title "Installing PyCharm to $install_dir"
    sudo mv pycharm-* "$install_dir"

    # Create a desktop entry for PyCharm
    print_title "Creating Desktop Entry"
    cat <<EOF | sudo tee /usr/share/applications/pycharm.desktop
[Desktop Entry]
Version=1.0
Name=PyCharm
Comment=Python IDE
Exec=$install_dir/bin/pycharm.sh
Icon=$install_dir/bin/pycharm.png
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

    # Add an alias to start PyCharm from the terminal
    print_title "Adding Terminal Alias for PyCharm"
    ALIAS_COMMAND="alias pycharm=\"$install_dir/bin/pycharm.sh\""

    # Add alias to ~/.bashrc
    if ! grep -Fxq "$ALIAS_COMMAND" "$HOME/.bashrc"; then
        echo "$ALIAS_COMMAND" >> "$HOME/.bashrc"
        echo -e "${GREEN}Alias 'pycharm' added to ~/.bashrc${RESET}"
    else
        echo -e "${YELLOW}Alias 'pycharm' already exists in ~/.bashrc${RESET}"
    fi

    # Reload ~/.bashrc
    source "$HOME/.bashrc"

    # Verify Installation
    print_title "Verifying PyCharm Installation"
    if command -v pycharm &> /dev/null; then
        echo -e "${GREEN}PyCharm $edition Edition is ready to use! Run 'pycharm' to launch.${RESET}"
    else
        echo -e "${RED}Something went wrong. Please try installing again.${RESET}"
    fi
}

# Function to uninstall PyCharm
uninstall_pycharm() {
    if check_pycharm_installed; then
        print_title "Uninstalling PyCharm"

        # Remove PyCharm installation directory
        sudo rm -rf /opt/pycharm

        # Remove desktop entry
        sudo rm -f /usr/share/applications/pycharm.desktop

        # Remove terminal alias from ~/.bashrc
        sed -i '/alias pycharm/d' "$HOME/.bashrc"

        # Reload ~/.bashrc
        source "$HOME/.bashrc"

        echo -e "${GREEN}PyCharm has been uninstalled successfully.${RESET}"
    else
        echo -e "${YELLOW}PyCharm is not installed. No need to uninstall.${RESET}"
    fi
}

# Main menu
while true; do
    echo -e "${CYAN}Please choose an option:${RESET}"
    echo -e "${YELLOW}1) Install PyCharm Community Edition${RESET}"
    echo -e "${YELLOW}2) Install PyCharm Professional Edition${RESET}"
    echo -e "${YELLOW}3) Uninstall PyCharm${RESET}"
    echo -e "${YELLOW}4) Exit${RESET}"

    read -p "Enter your choice (1-4): " choice

    case $choice in
        1)
            uninstall_pycharm
            install_pycharm "community"
            ;;
        2)
            uninstall_pycharm
            install_pycharm "professional"
            ;;
        3)
            uninstall_pycharm
            ;;
        4)
            echo -e "${GREEN}Exiting the script.${RESET}"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter a number between 1 and 4.${RESET}"
            ;;
    esac
done

