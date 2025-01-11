#!/bin/bash

#===============================#
#          PyCharm Installer    #
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
echo "#                   PyCharm Installer                      #"
echo "#                 Author: MaheshTechnicals                 #"
echo "############################################################"
echo -e "${RESET}"

# Function to print a title
print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

# Function to show progress bar for extraction
show_progress() {
    bar_length=50
    while [ $extracted -lt $total ]; do
        sleep 1
        extracted=$((extracted + 1))
        percentage=$((extracted * 100 / total))
        progress_bar=$(printf "%-${bar_length}s" "=")
        progress_bar="${progress_bar:0:$((percentage * bar_length / 100))}"
        echo -e "${CYAN}Extracting: [${progress_bar}${progress_bar:0:$((bar_length - ${#progress_bar}))}] ${percentage}%${RESET}"
    done
}

# Function to check if PyCharm is installed
check_pycharm_installed() {
    if command -v pycharm &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to uninstall PyCharm
uninstall_pycharm() {
    print_title "Uninstalling PyCharm"
    sudo apt-get purge pycharm* -y
    sudo apt-get autoremove -y
    echo -e "${GREEN}PyCharm has been uninstalled successfully!${RESET}"
}

# Function to install PyCharm based on architecture
install_pycharm() {
    print_title "Installing PyCharm"

    # Check system architecture
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)
            URL="https://download.jetbrains.com/python/pycharm-community-2024.3.1.1.tar.gz"
            ;;
        aarch64)
            URL="https://download.jetbrains.com/python/pycharm-community-2024.3.1.1-linux-arm64.tar.gz"
            ;;
        *)
            echo -e "${RED}Unsupported architecture: $ARCH. Exiting...${RESET}"
            exit 1
            ;;
    esac

    print_title "Downloading PyCharm"
    wget -q --show-progress "$URL" -O pycharm.tar.gz

    print_title "Extracting PyCharm"
    mkdir -p /opt/pycharm
    tar -xzf pycharm.tar.gz -C /opt/pycharm --strip-components=1 &

    total=100
    extracted=0
    show_progress
    wait

    print_title "Creating Symlink for PyCharm"
    sudo ln -s /opt/pycharm/bin/pycharm.sh /usr/local/bin/pycharm
    echo -e "${GREEN}PyCharm has been installed successfully!${RESET}"

    # Clean up
    rm pycharm.tar.gz
}

# Menu to choose install, uninstall, or exit
while true; do
    echo -e "${CYAN}Please choose an option:${RESET}"
    echo -e "${YELLOW}1) Install PyCharm${RESET}"
    echo -e "${YELLOW}2) Uninstall PyCharm${RESET}"
    echo -e "${YELLOW}3) Exit${RESET}"
    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1)
            if check_pycharm_installed; then
                print_title "PyCharm is already installed. Uninstalling it first..."
                uninstall_pycharm
            fi
            install_pycharm
            ;;
        2)
            if ! check_pycharm_installed; then
                echo -e "${RED}PyCharm is not installed on your system.${RESET}"
            else
                uninstall_pycharm
            fi
            ;;
        3)
            echo -e "${CYAN}Exiting the installer...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option! Please select 1, 2, or 3.${RESET}"
            ;;
    esac
done

