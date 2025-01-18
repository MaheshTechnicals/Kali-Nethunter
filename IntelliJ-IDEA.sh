#!/bin/bash

#===============================#
#      IntelliJ IDEA Installer #
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
echo "#                 IntelliJ IDEA Installer                  #"
echo "#               Author: MaheshTechnicals                  #"
echo "############################################################"
echo -e "${RESET}"

# Function to print a title
print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

# Function to check and install dependencies
install_dependencies() {
    print_title "Checking Required Dependencies"

    dependencies=(curl jq wget pv)

    for package in "${dependencies[@]}"; do
        if ! dpkg -l | grep -qw "$package"; then
            echo -e "${YELLOW}$package is not installed. Installing...${RESET}"
            sudo apt update && sudo apt install -y "$package"
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}Failed to install $package. Exiting...${RESET}"
                exit 1
            fi
            echo -e "${GREEN}$package has been installed successfully!${RESET}"
        else
            echo -e "${GREEN}$package is already installed. Skipping...${RESET}"
        fi
    done
}

# Function to check Java version and install Java 23 if needed
check_and_install_java() {
    print_title "Checking Java Version"
    
    # Check if Java is installed and its version
    if command -v java &> /dev/null; then
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F. '{print $1}')
        if [[ "$java_version" -ge 23 ]]; then
            echo -e "${GREEN}Java $java_version is already installed. Skipping Java installation.${RESET}"
            return 0
        else
            echo -e "${YELLOW}Java version is less than 23. Installing Java 23...${RESET}"
        fi
    else
        echo -e "${YELLOW}Java is not installed. Installing Java 23...${RESET}"
    fi

    # Install Java 23 using the Pycharm installer method
    wget -qO- "https://github.com/adoptium/temurin23-binaries/releases/latest/download/OpenJDK23U-jdk_x64_linux_hotspot.tar.gz" | pv | sudo tar -xz -C /opt
    sudo ln -sf /opt/jdk-23/bin/java /usr/bin/java
    echo -e "${GREEN}Java 23 has been installed successfully!${RESET}"
}

# Function to install IntelliJ IDEA dynamically
install_intellij() {
    # Install dependencies and check Java version
    install_dependencies
    check_and_install_java

    # Fetch data using curl to get the latest version and download URL
    response=$(curl -s "https://data.services.jetbrains.com/products/releases?code=IC,IE&latest=true&type=release")

    # Check if the curl request was successful
    if [ $? -ne 0 ]; then
        echo -e "${RED}There was a problem with the fetch operation.${RESET}"
        exit 1
    fi

    # Parse the JSON response using jq
    version=$(echo "$response" | jq -r '.IIC[0].version' | xargs)
    download_url=$(echo "$response" | jq -r '.IIC[0].downloads.linuxARM64.link' | xargs)

    # Check if the parsed values are empty
    if [ -z "$version" ] || [ -z "$download_url" ]; then
        echo -e "${RED}Failed to parse version or download URL.${RESET}"
        exit 1
    fi

    # Output the fetched version with stylish title
    print_title "Latest IntelliJ IDEA Version: $version"
    echo "Download URL: $download_url"

    # Download the latest IntelliJ IDEA
    local idea_tar="intellij.tar.gz"
    local install_dir="/opt/intellij"

    print_title "Downloading IntelliJ IDEA"
    wget "$download_url" -O "$idea_tar"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Download failed! Exiting...${RESET}"
        exit 1
    fi

    print_title "Extracting IntelliJ IDEA"
    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"
    pv "$idea_tar" | sudo tar -xz --strip-components=1 -C "$install_dir"
    rm -f "$idea_tar"

    print_title "Creating Symbolic Link"
    sudo ln -sf "$install_dir/bin/idea.sh" /usr/local/bin/intellij

    print_title "Creating Desktop Entry"
    cat << EOF | sudo tee /usr/share/applications/intellij.desktop > /dev/null
[Desktop Entry]
Name=IntelliJ IDEA
Comment=Integrated Development Environment for Java and other languages
Exec=$install_dir/bin/idea.sh %f
Icon=$install_dir/bin/idea.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

    echo -e "${GREEN}IntelliJ IDEA has been installed successfully!${RESET}"
    exit 0  # Exit the script after successful installation
}

# Function to uninstall IntelliJ IDEA
uninstall_intellij() {
    local install_dir="/opt/intellij"

    print_title "Removing IntelliJ IDEA Installation"
    sudo rm -rf "$install_dir"

    print_title "Removing Symbolic Link"
    sudo rm -f /usr/local/bin/intellij

    print_title "Removing Desktop Entry"
    sudo rm -f /usr/share/applications/intellij.desktop

    echo -e "${GREEN}IntelliJ IDEA has been uninstalled successfully!${RESET}"
    exit 0  # Exit the script after successful uninstallation
}

# Display menu
while true; do
    clear
    echo -e "${CYAN}############################################################${RESET}"
    echo -e "${CYAN}#                 IntelliJ IDEA Installer                  #${RESET}"
    echo -e "${CYAN}#               Author: MaheshTechnicals                  #${RESET}"
    echo -e "${CYAN}############################################################${RESET}"

    echo -e "${YELLOW}1. Install IntelliJ IDEA${RESET}"
    echo -e "${YELLOW}2. Uninstall IntelliJ IDEA${RESET}"
    echo -e "${YELLOW}3. Exit${RESET}"

    read -p "Choose an option: " choice
    case $choice in
        1) 
            install_intellij
            ;;
        2)
            uninstall_intellij
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

