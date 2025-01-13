#!/bin/bash

#===============================#
#        PyCharm Installer      #
#   Script by MaheshTechnicals  #
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
echo "#                    PyCharm Installer                     #"
echo "#               Author: MaheshTechnicals                  #"
echo "############################################################"
echo -e "${RESET}"

# Function to print a title
print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

# Function to check and install Java 23 or higher
check_and_install_java() {
    print_title "Checking Java Version"
    if command -v java &>/dev/null; then
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F. '{print $1}')
        if [[ "$java_version" -ge 23 ]]; then
            echo -e "${GREEN}Java $java_version is already installed.${RESET}"
            return
        else
            echo -e "${YELLOW}Java version is $java_version, which is lower than 23.${RESET}"
        fi
    else
        echo -e "${RED}Java is not installed.${RESET}"
    fi

    print_title "Installing Java"
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y openjdk-23-jdk
    elif command -v yum &>/dev/null; then
        sudo yum install -y java-23-openjdk
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y java-23-openjdk
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm jdk-openjdk
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y java-23-openjdk
    else
        echo -e "${RED}Unsupported package manager. Please install Java manually.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}Java 23 or higher has been installed successfully!${RESET}"
}

# Function to fetch the latest PyCharm version
fetch_latest_pycharm_url() {
    print_title "Fetching Latest PyCharm Version"
    local api_url="https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release"
    local json_data=$(wget -qO- "$api_url")

    # Extract the download URL and version
    local latest_url=$(echo "$json_data" | grep -oP 'https://download.jetbrains.com/.*?pycharm-community-.*?\.tar\.gz' | head -1)
    local latest_version=$(echo "$json_data" | grep -oP '"version":"\K[^"]+')

    if [[ -z "$latest_url" || -z "$latest_version" ]]; then
        echo -e "${RED}Failed to fetch the latest PyCharm version. Exiting...${RESET}"
        exit 1
    fi

    echo -e "${GREEN}Latest PyCharm Version: $latest_version${RESET}"
    echo "$latest_url"
}

# Function to install PyCharm
install_pycharm() {
    local pycharm_url=$(fetch_latest_pycharm_url)
    local pycharm_tar="pycharm.tar.gz"
    local install_dir="/opt/pycharm"

    print_title "Downloading PyCharm"
    wget "$pycharm_url" -O "$pycharm_tar"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Download failed! Exiting...${RESET}"
        exit 1
    fi

    print_title "Extracting PyCharm"
    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"
    pv "$pycharm_tar" | sudo tar -xz --strip-components=1 -C "$install_dir"
    rm -f "$pycharm_tar"

    print_title "Creating Symbolic Link"
    sudo ln -sf "$install_dir/bin/pycharm.sh" /usr/local/bin/pycharm

    print_title "Creating Desktop Entry"
    cat << EOF | sudo tee /usr/share/applications/pycharm.desktop > /dev/null
[Desktop Entry]
Name=PyCharm
Comment=Integrated Development Environment for Python
Exec=$install_dir/bin/pycharm.sh %f
Icon=$install_dir/bin/pycharm.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

    echo -e "${GREEN}PyCharm has been installed successfully!${RESET}"
}

# Function to uninstall PyCharm
uninstall_pycharm() {
    local install_dir="/opt/pycharm"

    print_title "Removing PyCharm Installation"
    sudo rm -rf "$install_dir"

    print_title "Removing Symbolic Link"
    sudo rm -f /usr/local/bin/pycharm

    print_title "Removing Desktop Entry"
    sudo rm -f /usr/share/applications/pycharm.desktop

    echo -e "${GREEN}PyCharm has been uninstalled successfully!${RESET}"
}

# Display menu
while true; do
    clear
    echo -e "${CYAN}############################################################${RESET}"
    echo -e "${CYAN}#                    PyCharm Installer                     #${RESET}"
    echo -e "${CYAN}#               Author: MaheshTechnicals                  #${RESET}"
    echo -e "${CYAN}############################################################${RESET}"
    echo -e "${YELLOW}1. Install PyCharm${RESET}"
    echo -e "${YELLOW}2. Uninstall PyCharm${RESET}"
    echo -e "${YELLOW}3. Exit${RESET}"
    echo -n -e "${CYAN}Enter your choice: ${RESET}"
    read -r choice

    case $choice in
        1)
            check_and_install_java
            install_pv
            install_pycharm
            read -r -p "Press any key to continue..."
            ;;
        2)
            uninstall_pycharm
            read -r -p "Press any key to continue..."
            ;;
        3)
            echo -e "${YELLOW}Exiting. Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${RESET}"
            ;;
    esac
done

