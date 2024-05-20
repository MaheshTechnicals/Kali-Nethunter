#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print messages in a box
print_box() {
    local color="$1"
    local message="$2"
    local length=${#message}
    local border=$(printf '%*s' "$length" | tr ' ' '-')

    echo -e "${color}"
    echo -e "┌─${border}─┐"
    echo -e "│ ${message} │"
    echo -e "└─${border}─┘"
    echo -e "${NC}"
}

# Start installation process
print_box "${CYAN}" "Starting Kali Nethunter Installation by Mahesh Technicals..."

# Update and upgrade packages
print_box "${BLUE}" "Updating package list and upgrading installed packages..."
apt update && apt upgrade -y
print_box "${GREEN}" "Update and upgrade complete."

# Install wget
print_box "${BLUE}" "Installing wget..."
pkg install wget -y
print_box "${GREEN}" "wget installation complete."

# Install pulseaudio
print_box "${BLUE}" "Installing pulseaudio..."
pkg install pulseaudio -y
print_box "${GREEN}" "pulseaudio installation complete."

# Setup storage and download installer script
print_box "${BLUE}" "Setting up storage and downloading the Nethunter installer script..."
termux-setup-storage && wget -O install-nethunter-termux https://offs.ec/2MceZWr && chmod 777 install-nethunter-termux
print_box "${GREEN}" "Storage setup and script download complete."

# Make the script executable and run it
print_box "${BLUE}" "Making the installer script executable and running it..."
chmod +x install-nethunter-termux && ./install-nethunter-termux
print_box "${GREEN}" "Installer script execution complete."

# Final message
print_box "${YELLOW}" "Kali Nethunter Installer has been successfully executed."
print_box "${CYAN}" "Installation script finished. Thank you for using Mahesh Technicals' installer."
