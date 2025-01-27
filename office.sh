#!/bin/bash

# Function to create fancy headers
create_header() {
    local text="$1"
    local color="$2"
    local width=70
    echo -e "\n$color"
    printf '%*s\n' "${COLUMNS:-$width}" '' | tr ' ' '='
    printf "%*s\n" $(((${#text}+width)/2)) "$text"
    printf '%*s\n' "${COLUMNS:-$width}" '' | tr ' ' '='
    echo -e "\033[0m"
}

# Function to create step headers
step_header() {
    local text="$1"
    local color="$2"
    echo -e "\n$color╔════════════════════════════════════════╗"
    printf "║%-40s║\n" "  $text"
    echo -e "╚════════════════════════════════════════╝\033[0m"
}

# Clear the screen
clear

# Define color codes
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Main banner
create_header "🚀 LibreOffice Installer Script v2.0 🚀" "$PURPLE"
echo -e "${CYAN}               By Mahesh Technicals${RESET}\n"

# Animated loading bar
printf "${YELLOW}Loading script components: "
for i in {1..20}; do
    printf "▓"
    sleep 0.1
done
printf " Done!${RESET}\n\n"

# Main Menu with fancy box
echo -e "$BLUE╔══════════════════════════════════╗"
echo -e "║         MAIN MENU OPTIONS         ║"
echo -e "╠══════════════════════════════════╣"
echo -e "║  ${GREEN}1. Install LibreOffice${BLUE}          ║"
echo -e "║  ${RED}2. Uninstall LibreOffice${BLUE}        ║"
echo -e "╚══════════════════════════════════╝${RESET}"

# Get user input with styled prompt
echo -e "\n${CYAN}👉 Please select an option:${RESET}"
read -p "   Enter your choice (1 or 2): " choice

# Function to check architecture
check_architecture() {
    step_header "System Architecture Detection" "$BLUE"
    echo -e "${YELLOW}🔍 Analyzing your system...${RESET}"
    ARCH=$(uname -m)
    
    case "$ARCH" in
        "x86_64")
            echo -e "${GREEN}✅ 64-bit architecture detected${RESET}"
            ARCH="x86_64"
            ;;
        "i386"|"i686")
            echo -e "${GREEN}✅ 32-bit architecture detected${RESET}"
            ARCH="x86"
            ;;
        "aarch64")
            echo -e "${GREEN}✅ ARM 64-bit architecture detected${RESET}"
            ARCH="aarch64"
            ;;
        *)
            echo -e "${RED}❌ Unsupported architecture: $ARCH${RESET}"
            exit 1
            ;;
    esac
}

# Function to install dependencies
install_dependencies() {
    step_header "Installing Dependencies" "$CYAN"
    echo -e "${YELLOW}📦 Updating package lists...${RESET}"
    sudo apt update
    echo -e "${YELLOW}📥 Installing required packages...${RESET}"
    sudo apt install -y wget tar gdebi libxinerama1 libglu1-mesa libxrender1
    echo -e "${GREEN}✅ Dependencies installed successfully${RESET}"
}

# Function to install LibreOffice
install_libreoffice() {
    create_header "LibreOffice Installation Process" "$GREEN"
    
    check_architecture
    install_dependencies
    
    step_header "Downloading LibreOffice" "$BLUE"
    echo -e "${YELLOW}🌐 Fetching latest version...${RESET}"
    LIBRE_URL=$(wget -qO- https://www.libreoffice.org/download/download/ | grep -oP "https://.*LibreOffice_.*Linux_$ARCH\.deb\.tar\.gz" | head -n 1)
    
    if [[ -z "$LIBRE_URL" ]]; then
        echo -e "${RED}❌ Download link not found${RESET}"
        exit 1
    fi
    
    wget -c "$LIBRE_URL" -O LibreOffice.tar.gz
    
    step_header "Extracting Files" "$PURPLE"
    tar -xzf LibreOffice.tar.gz
    LIBRE_FOLDER=$(tar -tf LibreOffice.tar.gz | head -n 1 | cut -d'/' -f1)
    cd "$LIBRE_FOLDER"/DEBS || exit
    
    step_header "Installing Packages" "$CYAN"
    echo -e "${YELLOW}⚙️  Installing LibreOffice components...${RESET}"
    sudo gdebi --non-interactive *.deb
    
    step_header "Finalizing Installation" "$GREEN"
    sudo cp /usr/share/applications/libreoffice*.desktop ~/.local/share/applications/
    
    cd ../..
    rm -rf LibreOffice.tar.gz "$LIBRE_FOLDER"
    
    create_header "🎉 Installation Complete! 🎉" "$GREEN"
    echo -e "${CYAN}Thank you for using LibreOffice Installer!${RESET}\n"
}

# Function to uninstall LibreOffice
uninstall_libreoffice() {
    create_header "LibreOffice Uninstallation Process" "$RED"
    
    step_header "Removing LibreOffice" "$RED"
    echo -e "${YELLOW}🗑️  Uninstalling all components...${RESET}"
    sudo apt remove --purge -y libreoffice* && sudo apt autoremove -y
    
    create_header "Uninstallation Complete" "$GREEN"
    echo -e "${CYAN}LibreOffice has been successfully removed${RESET}\n"
}

# Handle user choice
case $choice in
    1)
        install_libreoffice
        ;;
    2)
        uninstall_libreoffice
        ;;
    *)
        echo -e "\n${RED}❌ Invalid choice. Please run the script again.${RESET}"
        exit 1
        ;;
esac
