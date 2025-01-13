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

# Function to check Java version
check_java_version() {
    if command -v java >/dev/null 2>&1; then
        # Get Java version
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
        
        # Check if version is 23 or higher
        if [ -n "$java_version" ] && [ "$java_version" -ge 23 ]; then
            return 0  # Java 23 or higher is installed
        fi
    fi
    return 1  # Java not installed or version < 23
}

# Function to install Java 23
install_java() {
    print_title "Checking Java Installation..."

    if check_java_version; then
        echo -e "${GREEN}Java 23 or higher is already installed.${RESET}"
        java -version
        return 0
    fi

    print_title "Installing Java 23..."

    # Check system architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-x64_bin.tar.gz"
    elif [[ "$ARCH" == "aarch64" ]]; then
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-aarch64_bin.tar.gz"
    else
        echo -e "${RED}Unsupported architecture: $ARCH. Exiting...${RESET}"
        exit 1
    fi

    # Download Java
    echo -e "${YELLOW}Downloading Java from $JAVA_URL...${RESET}"
    wget "$JAVA_URL" -O openjdk-23.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download Java.${RESET}"
        exit 1
    fi

    # Create /usr/lib/jvm directory if it doesn't exist
    echo -e "${CYAN}Creating /usr/lib/jvm directory...${RESET}"
    sudo mkdir -p /usr/lib/jvm

    # Extract Java
    echo -e "${CYAN}Extracting Java...${RESET}"
    sudo tar -xzf openjdk-23.tar.gz -C /usr/lib/jvm
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to extract Java.${RESET}"
        exit 1
    fi

    # Find the extracted Java directory
    JAVA_DIR=$(tar -tf openjdk-23.tar.gz | head -n 1 | cut -f1 -d"/")
    JAVA_PATH="/usr/lib/jvm/$JAVA_DIR"

    # Set up Java alternatives
    echo -e "${CYAN}Setting up Java alternatives...${RESET}"
    sudo update-alternatives --install /usr/bin/java java "$JAVA_PATH/bin/java" 1
    sudo update-alternatives --set java "$JAVA_PATH/bin/java"

    # Clean up
    rm -f openjdk-23.tar.gz
    echo -e "${GREEN}Java 23 has been installed successfully!${RESET}"

    # Display installed Java version
    java -version
}

# Function to get latest PyCharm version and URL
get_latest_pycharm_url() {
    local DEFAULT_VERSION="2024.3.1.1"
    local BASE_URL="https://download.jetbrains.com/python/pycharm-community-"
    
    print_title "Fetching Latest PyCharm Version"
    
    # Check if curl is installed
    if ! command -v curl &>/dev/null; then
        echo -e "${YELLOW}Installing curl...${RESET}"
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y curl
        elif command -v yum &>/dev/null; then
            sudo yum install -y curl
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y curl
        else
            echo -e "${RED}Please install curl manually to continue.${RESET}"
            local version="$DEFAULT_VERSION"
            echo -e "${YELLOW}Using default version: $version${RESET}"
            echo "${BASE_URL}${version}.tar.gz"
            return
        fi
    fi

    # Fetch latest version information
    echo -e "${CYAN}Fetching latest version information...${RESET}"
    local response=$(curl -s "https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release")
    local version=$(echo "$response" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$version" ]; then
        version="$DEFAULT_VERSION"
        echo -e "${RED}Failed to fetch latest version information.${RESET}"
        echo -e "${YELLOW}Using default version: $version${RESET}"
    else
        echo -e "${GREEN}Latest PyCharm Community Edition version: $version${RESET}"
    fi

    echo "${BASE_URL}${version}.tar.gz"
}

# Function to install pv utility
install_pv() {
    print_title "Installing pv Utility"
    if command -v pv &>/dev/null; then
        echo -e "${GREEN}pv is already installed.${RESET}"
        return
    fi
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
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

# Function to install PyCharm
install_pycharm() {
    install_java  # Call Java installation function

    print_title "Fetching Latest PyCharm Version"

    # Get latest PyCharm download URL
    local pycharm_url="$(get_latest_pycharm_url | tail -n 1)"
    
    # Fetch and display the latest PyCharm version
    local pycharm_version=$(echo "$pycharm_url" | sed -E 's/.*pycharm-community-(.*).tar.gz/\1/')
    echo -e "${CYAN}Latest PyCharm version: $pycharm_version${RESET}"
    echo -e "${CYAN}Download URL: $pycharm_url${RESET}"
    
    local pycharm_tar="pycharm.tar.gz"
    local install_dir="/opt/pycharm"

    wget "$pycharm_url" -O "$pycharm_tar" --progress=bar
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

# Main Menu
show_menu() {
    PS3='Please enter your choice: '
    options=("Install PyCharm" "Uninstall PyCharm" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Install PyCharm")
                install_pycharm
                break
                ;;
            "Uninstall PyCharm")
                uninstall_pycharm
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

# Display Menu
show_menu

