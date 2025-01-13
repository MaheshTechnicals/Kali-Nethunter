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

# Function to check if Java 23 or higher is installed
check_java_version() {
    # Get the installed Java version
    java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    
    # Check if the version is 23 or higher
    if [[ "$java_version" =~ ^(23|[2-9][0-9]) ]]; then
        echo -e "${GREEN}Java version $java_version is already installed. Skipping installation.${RESET}"
        return 1  # Java is already installed, no need to install
    else
        return 0  # Java is not installed or version is lower than 23
    fi
}

# Function to install Java 23
install_java() {
    print_title "Installing Java 23..."

    # Check if Java 23 or higher is already installed
    check_java_version
    if [[ $? -eq 1 ]]; then
        return  # Skip Java installation if it's already installed
    fi

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

# Function to install jq
install_jq() {
    # Check if jq is installed, install if not
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}jq not found, installing jq...${RESET}"
        sudo apt update && sudo apt install -y jq
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}jq has been installed successfully!${RESET}"
        else
            echo -e "${RED}Error: jq installation failed.${RESET}"
            exit 1
        fi
    else
        echo -e "${GREEN}jq is already installed.${RESET}"
    fi
}

# Function to install PyCharm dynamically
install_pycharm() {
    # Install Java if needed
    install_java

    # Install jq if not installed
    install_jq

    # Fetch data from the JetBrains API
    response=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release')
    
    # Check if the request was successful
    if [[ $? -ne 0 ]]; then
        echo "Network request failed"
        exit 1
    fi

    # Parse the JSON response using jq
    version=$(echo "$response" | jq -r '.PCC[0].version' | xargs)  # Trim the version string
    download_url=$(echo "$response" | jq -r '.PCC[0].downloads.linuxARM64.link' | xargs)  # Trim the URL

    # Output the fetched version with stylish title
    print_title "Latest PyCharm Version: $version"
    echo "Download URL: $download_url"

    # Download the latest PyCharm
    local pycharm_tar="pycharm.tar.gz"
    local install_dir="/opt/pycharm"

    print_title "Downloading PyCharm"
    wget "$download_url" -O "$pycharm_tar"
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
    exit 0  # Exit the script after successful installation
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
    exit 0  # Exit the script after successful uninstallation
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

    read -p "Choose an option: " choice
    case $choice in
        1) 
            install_pycharm
            ;;
        2)
            uninstall_pycharm
            ;;
        3)
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${RESET}"
            read -r -p "Press any key to continue..."
            ;;
    esac
done

