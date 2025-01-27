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

# Loading animation function
show_loading_animation() {
    local duration=$1
    local chars="⣾⣽⣻⢿⡿⣟⣯⣷"
    local delay=0.1
    local end=$((SECONDS + duration))
    
    printf "${YELLOW}Loading script components "
    while [ $SECONDS -lt $end ]; do
        for (( i=0; i<${#chars}; i++ )); do
            printf "${YELLOW}%s${RESET}" "${chars:$i:1}"
            sleep $delay
            printf "\b"
        done
    done
    printf "${GREEN}Done!${RESET}\n"
}

# Fancy startup animation
startup_animation() {
    clear
    echo -e "${CYAN}"
    echo "   _     _ _                ___   __  __ _          "
    echo "  | |   (_) |__  _ __ ___ / _ \ / _|/ _(_) ___ ___ "
    echo "  | |   | | '_ \| '__/ _ \ | | | |_| |_| |/ __/ _ \\"
    echo "  | |___| | |_) | | |  __/ |_| |  _|  _| | (_|  __/"
    echo "  |_____|_|_.__/|_|  \___|\___/|_| |_| |_|\___\___|"
    echo -e "${RESET}"
    sleep 1
    
    # Loading effect
    show_loading_animation 3
    
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BLUE}║${RESET}     🚀 Welcome to LibreOffice Installer Script v3.0          ${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}     📝 Created by: Mahesh Technicals                        ${BLUE}║${RESET}"
    echo -e "${BLUE}║${RESET}     🔧 Status: Initializing...                              ${BLUE}║${RESET}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${RESET}"
    sleep 1
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

# Show startup animation
startup_animation

# Main Menu with fancy box
echo -e "\n$BLUE╔══════════════════════════════════╗"
echo -e "║         MAIN MENU OPTIONS         ║"
echo -e "╠══════════════════════════════════╣"
echo -e "║  ${GREEN}1. Install LibreOffice${BLUE}          ║"
echo -e "║  ${RED}2. Uninstall LibreOffice${BLUE}        ║"
echo -e "╚══════════════════════════════════╝${RESET}"

# Get user input with styled prompt
echo -e "\n${CYAN}👉 Please select an option:${RESET}"
read -p "   Enter your choice (1 or 2): " choice

# Function to install dependencies
install_dependencies() {
    step_header "Installing Dependencies" "$CYAN"
    echo -e "${YELLOW}📦 Installing required dependencies...${RESET}"
    sudo apt install -y \
        libxinerama1 \
        libglu1-mesa \
        libxrender1 \
        libxrandr2 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libsm6
    echo -e "${GREEN}✅ Dependencies installed successfully${RESET}"
}

# Function to setup desktop entries
setup_desktop_entries() {
    step_header "Setting up Desktop Entries" "$PURPLE"
    echo -e "${YELLOW}📋 Creating desktop entries...${RESET}"
    
    mkdir -p ~/.local/share/applications
    
    local apps=("writer" "calc" "impress" "draw" "base" "math")
    local names=("Writer" "Calc" "Impress" "Draw" "Base" "Math")
    local icons=("text" "spreadsheet" "presentation" "drawing" "database" "formula")
    
    for i in "${!apps[@]}"; do
        cat > ~/.local/share/applications/libreoffice-${apps[$i]}.desktop << EOF
[Desktop Entry]
Version=1.0
Terminal=false
Icon=libreoffice-${icons[$i]}
Type=Application
Categories=Office;
Exec=libreoffice --${apps[$i]} %U
MimeType=application/vnd.oasis.opendocument.*
Name=LibreOffice ${names[$i]}
GenericName=Office Application
Comment=Create and edit ${names[$i]} documents
Keywords=Office;Work;${names[$i]};
EOF
    done
    
    update-desktop-database ~/.local/share/applications
    echo -e "${GREEN}✅ Desktop entries created successfully${RESET}"
}

# Function to install LibreOffice
install_libreoffice() {
    create_header "LibreOffice Installation Process" "$GREEN"
    
    step_header "System Update" "$CYAN"
    echo -e "${YELLOW}📦 Updating package lists...${RESET}"
    sudo apt update
    
    install_dependencies
    
    step_header "Installing LibreOffice" "$BLUE"
    echo -e "${YELLOW}📦 Installing packages...${RESET}"
    sudo apt install -y libreoffice libreoffice-gtk3 libreoffice-style-breeze
    
    setup_desktop_entries
    
    create_header "🎉 Installation Complete! 🎉" "$GREEN"
    echo -e "${CYAN}LibreOffice has been successfully installed!${RESET}"
    echo -e "${YELLOW}You can find LibreOffice applications in your system menu.${RESET}\n"
}

# Function to uninstall LibreOffice
uninstall_libreoffice() {
    create_header "LibreOffice Uninstallation Process" "$RED"
    
    step_header "Removing LibreOffice" "$RED"
    echo -e "${YELLOW}🗑️  Uninstalling LibreOffice...${RESET}"
    sudo apt remove --purge -y libreoffice libreoffice-gtk3 libreoffice-style-breeze
    sudo apt autoremove -y
    
    step_header "Cleaning Up" "$BLUE"
    echo -e "${YELLOW}🧹 Removing desktop entries...${RESET}"
    rm -f ~/.local/share/applications/libreoffice*.desktop
    update-desktop-database ~/.local/share/applications
    
    create_header "Uninstallation Complete" "$GREEN"
    echo -e "${CYAN}LibreOffice has been successfully removed${RESET}"
    echo -e "${YELLOW}All desktop entries have been cleaned up${RESET}\n"
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
