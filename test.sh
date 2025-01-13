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

# Function to fetch the latest PyCharm version and construct the URL
get_latest_pycharm_url() {
    local BASE_URL="https://download.jetbrains.com/python/pycharm-community-"
    local FALLBACK_VERSION="2024.3.1.1"

    # Fetch version information from JetBrains API
    echo -e "${CYAN}Fetching the latest PyCharm version...${RESET}"
    local response=$(curl -s "https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release")
    local version=$(echo "$response" | grep -oP '"version":"\K[^"]+')

    if [[ -z "$version" ]]; then
        echo -e "${RED}Failed to fetch the latest version. Using fallback version: ${FALLBACK_VERSION}${RESET}"
        version="$FALLBACK_VERSION"
    else
        echo -e "${GREEN}Latest PyCharm version: $version${RESET}"
    fi

    # Construct the download URL
    local download_url="${BASE_URL}${version}.tar.gz"
    echo "$download_url"
}

# Function to install PyCharm
install_pycharm() {
    local download_url=$(get_latest_pycharm_url)
    local pycharm_tar="pycharm.tar.gz"
    local install_dir="/opt/pycharm"

    echo -e "${CYAN}Download URL: $download_url${RESET}"

    # Download PyCharm
    echo -e "${YELLOW}Downloading PyCharm...${RESET}"
    wget "$download_url" -O "$pycharm_tar" --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Download failed! Exiting...${RESET}"
        exit 1
    fi

    # Extract PyCharm
    echo -e "${CYAN}Extracting PyCharm...${RESET}"
    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"
    sudo tar -xzf "$pycharm_tar" --strip-components=1 -C "$install_dir"
    rm -f "$pycharm_tar"

    # Create symbolic link
    echo -e "${CYAN}Creating symbolic link...${RESET}"
    sudo ln -sf "$install_dir/bin/pycharm.sh" /usr/local/bin/pycharm

    # Create desktop entry
    echo -e "${CYAN}Creating desktop entry...${RESET}"
    cat << EOF | sudo tee /usr/share/applications/pycharm.desktop > /dev/null
[Desktop Entry]
Name=PyCharm Community Edition
Comment=Python IDE for Professional Developers
Exec=$install_dir/bin/pycharm.sh %f
Icon=$install_dir/bin/pycharm.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

    echo -e "${GREEN}PyCharm has been installed successfully!${RESET}"
}

# Main Menu
show_menu() {
    PS3='Please enter your choice: '
    options=("Install PyCharm" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Install PyCharm")
                install_pycharm
                break
                ;;
            "Quit")
                break
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${RESET}"
                ;;
        esac
    done
}

# Display menu
show_menu

