#!/bin/bash

# Function to handle errors
handle_error() {
    echo -e "\e[1m\e[91mError: $1\e[0m"
    exit 1
}

# Function to execute commands with error handling and UI comments
execute_command() {
    echo -e "\n\e[1m\e[32m[EXECUTING]\e[0m \e[96m$1\e[0m"
    eval "$1" || handle_error "Failed to execute command: $1"
}

# Function to display button UI
display_button_ui() {
    echo -e "\e[1m\e[97m###############################################################\e[0m"
    echo -e "\e[1m\e[97m#\e[0m                                                           \e[1m\e[97m#\e[0m"
    echo -e "\e[1m\e[97m#                       \e[94m$1\e[97m                               #\e[0m"
    echo -e "\e[1m\e[97m#\e[0m                                                           \e[1m\e[97m#\e[0m"
    echo -e "\e[1m\e[97m###############################################################\e[0m\n"
}

# Print large font size for the script name
echo -e "\e[1m\e[34m   _____       _       _            _           _       _   _             \e[0m"
echo -e "\e[1m\e[34m  |_   _|__ __| | __ _| |_ ___  ___| |_ ___  __| |_   _| |_(_) ___  _ __  \e[0m"
echo -e "\e[1m\e[34m    | |/ -_/ _\` |/ _\` |  _/ _ \/ _ \  _/ _ \/ _\` | | | | __| |/ _ \|  _ \ \e[0m"
echo -e "\e[1m\e[34m    |_|\___\__,_|\__,_|\__\___/\___/\__\___/\__,_| |_|  \__|_|\___/|_| |_|\e[0m"
echo -e "\e[1m\e[34m                                                                          \e[0m"

# Print stylish and colorful author name
echo -e "\n\e[1m\e[96mAuthor:\e[0m \e[1m\e[93mMahesh Technicals\e[0m\n"

# Set up storage access
display_button_ui "Setting up storage access"
execute_command "termux-setup-storage"

# Update package lists
display_button_ui "Updating package lists"
execute_command "apt update"

# Upgrade packages
display_button_ui "Upgrading packages"
execute_command "apt upgrade -y"

# Install necessary packages
display_button_ui "Installing necessary packages"
execute_command "pkg install pulseaudio -y"
execute_command "pkg install x11-repo -y"
execute_command "pkg install termux-x11-nightly -y"
execute_command "pkg install dbus -y"
execute_command "pkg install proot-distro -y"
execute_command "pkg install wget -y"

# Download startxfce4_debian.sh
display_button_ui "Downloading startxfce4_debian.sh"
execute_command "wget 'https://master.dl.sourceforge.net/project/win/startxfce4_debian.sh'"
execute_command "chmod +x startxfce4_debian.sh"

# Download necessary files
display_button_ui "Downloading necessary files"
if [ -f "/data/data/com.termux/files/home/DebianNeonDesktop_vscode_chromium.bckp" ]; then
    echo -e "\n\e[1m\e[93m[SKIPPED]\e[0m \e[1m\e[96mDebianNeonDesktop_vscode_chromium.bckp already exists in /data/data/com.termux/files/home\e[0m"
elif [ -f "/storage/emulated/0/Download/DebianNeonDesktop_vscode_chromium.bckp" ]; then
    echo -e "\n\e[1m\e[93m[SKIPPED]\e[0m \e[1m\e[96mDebianNeonDesktop_vscode_chromium.bckp already exists in /storage/emulated/0/Download\e[0m"
    execute_command "cp /storage/emulated/0/Download/DebianNeonDesktop_vscode_chromium.bckp ."
elif [ -f "/storage/emulated/0/Download/ADM/DebianNeonDesktop_vscode_chromium.bckp" ]; then
    echo -e "\n\e[1m\e[93m[SKIPPED]\e[0m \e[1m\e[96mDebianNeonDesktop_vscode_chromium.bckp already exists in /storage/emulated/0/Download/ADM\e[0m"
    execute_command "cp /storage/emulated/0/Download/ADM/DebianNeonDesktop_vscode_chromium.bckp ."
else
    execute_command "wget 'https://master.dl.sourceforge.net/project/win/DebianNeonDesktop_vscode_chromium.bckp'"
fi

# Restore Debian Neon Desktop
display_button_ui "Restoring Debian Neon Desktop"
execute_command "proot-distro restore DebianNeonDesktop_vscode_chromium.bckp"

# Ask for user input whether to remove the backup file
read -p "Do you want to remove the backup file? (y/n): " choice
if [ "$choice" = "y" ]; then
    execute_command "rm DebianNeonDesktop_vscode_chromium.bckp"
else
    echo "Backup file removal skipped."
fi

# Start Debian Neon
display_button_ui "Starting Debian Neon"
execute_command "./startxfce4_debian.sh"
