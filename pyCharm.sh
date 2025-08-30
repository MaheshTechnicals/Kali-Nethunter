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

#===============================#
#   Helper Functions            #
#===============================#

print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    else
        echo ""
    fi
}

install_package() {
    local pkg=$1
    if ! command -v "$pkg" &>/dev/null; then
        print_title "Installing $pkg"
        case $PKG_MANAGER in
            apt) sudo apt-get update && sudo apt-get install -y "$pkg" ;;
            yum) sudo yum install -y "$pkg" ;;
            dnf) sudo dnf install -y "$pkg" ;;
            pacman) sudo pacman -S --noconfirm "$pkg" ;;
            zypper) sudo zypper install -y "$pkg" ;;
            *) echo -e "${RED}No supported package manager found. Please install $pkg manually.${RESET}" && exit 1 ;;
        esac
    else
        echo -e "${GREEN}$pkg is already installed.${RESET}"
    fi
}

#===============================#
#   Java Installation           #
#===============================#

check_java_version() {
    java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    if [[ "$java_version" =~ ^(23|[2-9][0-9]) ]]; then
        echo -e "${GREEN}Java version $java_version is already installed.${RESET}"
        return 1
    else
        return 0
    fi
}

install_java() {
    print_title "Installing Java 23"
    check_java_version && true
    if [[ $? -eq 1 ]]; then return; fi

    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-x64_bin.tar.gz"
    elif [[ "$ARCH" == "aarch64" ]]; then
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-aarch64_bin.tar.gz"
    else
        echo -e "${RED}Unsupported architecture: $ARCH${RESET}" && exit 1
    fi

    wget "$JAVA_URL" -O openjdk-23.tar.gz --progress=bar || { echo -e "${RED}Download failed${RESET}"; exit 1; }
    sudo mkdir -p /usr/lib/jvm
    sudo tar -xzf openjdk-23.tar.gz -C /usr/lib/jvm
    JAVA_DIR=$(tar -tf openjdk-23.tar.gz | head -n 1 | cut -f1 -d"/")
    JAVA_PATH="/usr/lib/jvm/$JAVA_DIR"

    sudo update-alternatives --install /usr/bin/java java "$JAVA_PATH/bin/java" 1
    sudo update-alternatives --set java "$JAVA_PATH/bin/java"
    rm -f openjdk-23.tar.gz

    echo -e "${GREEN}Java installed successfully${RESET}"
    java -version
}

#===============================#
#   PyCharm Installation        #
#===============================#

install_pycharm() {
    install_java
    install_package jq
    install_package pv
    install_package wget
    install_package curl
    install_package tar

    response=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release') || { echo "Network error"; exit 1; }

    version=$(echo "$response" | jq -r '.PCC[0].version')
    arch=$(uname -m)
    if [[ "$arch" == "aarch64" ]]; then
        download_url=$(echo "$response" | jq -r '.PCC[0].downloads.linuxARM64.link')
    else
        download_url=$(echo "$response" | jq -r '.PCC[0].downloads.linux.link')
    fi

    print_title "Downloading PyCharm $version"
    wget "$download_url" -O pycharm.tar.gz || { echo -e "${RED}Download failed${RESET}"; exit 1; }

    local install_dir="/opt/pycharm"
    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"

    print_title "Extracting PyCharm"
    sudo tar -xzf pycharm.tar.gz --strip-components=1 -C "$install_dir"
    rm -f pycharm.tar.gz

    sudo ln -sf "$install_dir/bin/pycharm.sh" /usr/local/bin/pycharm

    cat << EOF | sudo tee /usr/share/applications/pycharm.desktop >/dev/null
[Desktop Entry]
Name=PyCharm
Comment=Python IDE
Exec=$install_dir/bin/pycharm.sh %f
Icon=$install_dir/bin/pycharm.svg
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

    echo -e "${GREEN}PyCharm $version installed successfully!${RESET}"
}

uninstall_pycharm() {
    local install_dir="/opt/pycharm"
    sudo rm -rf "$install_dir"
    sudo rm -f /usr/local/bin/pycharm
    sudo rm -f /usr/share/applications/pycharm.desktop
    echo -e "${GREEN}PyCharm uninstalled successfully!${RESET}"
}

#===============================#
#   Menu                        #
#===============================#

PKG_MANAGER=$(detect_pkg_manager)
if [[ -z "$PKG_MANAGER" ]]; then
    echo -e "${RED}No supported package manager found. Exiting.${RESET}"
    exit 1
fi

while true; do
    echo -e "${CYAN}############################################################${RESET}"
    echo -e "${CYAN}#                    PyCharm Installer                     #${RESET}"
    echo -e "${CYAN}#               Author: MaheshTechnicals                  #${RESET}"
    echo -e "${CYAN}############################################################${RESET}"

    echo -e "${YELLOW}1. Install PyCharm${RESET}"
    echo -e "${YELLOW}2. Uninstall PyCharm${RESET}"
    echo -e "${YELLOW}3. Exit${RESET}"

    read -p "Choose an option: " choice
    case $choice in
        1) install_pycharm ;;
        2) uninstall_pycharm ;;
        3) exit 0 ;;
        *) echo -e "${RED}Invalid choice!${RESET}" ;;
    esac
    echo
    read -p "Press Enter to return to menu..."
done

