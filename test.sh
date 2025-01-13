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

# Function to install pv command (for progress visualization)
install_pv() {
    print_title "Installing pv command"
    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y pv
    elif command -v yum &>/dev/null; then
        sudo yum install -y pv
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y pv
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm pv
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y pv
    else
        echo -e "${RED}Unsupported package manager. Please install pv manually.${RESET}"
        exit 1
    fi
}

# Function to fetch the latest PyCharm version dynamically
fetch_latest_pycharm_version() {
    print_title "Fetching Latest PyCharm Version"
    
    # You can fetch the latest version dynamically from a repository or page (example using a placeholder for now)
    latest_version=$(curl -s https://www.jetbrains.com/pycharm/download/#section=linux | grep -oP 'pycharm-community-\K[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?' | head -n 1)

    if [[ -z "$latest_version" ]]; then
        echo -e "${RED}Failed to fetch the latest PyCharm version. Exiting...${RESET}"
        exit 1
    fi

    echo -e "${GREEN}Latest PyCharm Version: $latest_version${RESET}"
}

# Function to fetch the PyCharm download URL dynamically
fetch_pycharm_url() {
    # Ensure the latest version is fetched before proceeding
    fetch_latest_pycharm_version

    # Identify system architecture and set the download URL accordingly
    local arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        download_url="https://download-cf.jetbrains.com/python/pycharm-community-${latest_version}.tar.gz"
    elif [[ "$arch" == "aarch64" || "$arch" == "arm64" ]]; then
        download_url="https://download-cf.jetbrains.com/python/pycharm-community-${latest_version}-aarch64.tar.gz"
    else
        echo -e "${RED}Unsupported architecture: $arch. Exiting...${RESET}"
        exit 1
    fi

    echo -e "${CYAN}Download URL: $download_url${RESET}"
    echo "$download_url"
}

# Function to install PyCharm
install_pycharm() {
    local pycharm_url=$(fetch_pycharm_url)
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
    echo -e "${YELLOW}Please choose an option: ${RESET}"
    read -r choice

    case $choice in
        1) 
            check_and_install_java
            install_pv
            install_pycharm
            ;;
        2) 
            uninstall_pycharm
            ;;
        3) 
            echo -e "${GREEN}Exiting...${RESET}"
            break
            ;;
        *) 
            echo -e "${RED}Invalid choice. Please try again.${RESET}"
            ;;
    esac
done

