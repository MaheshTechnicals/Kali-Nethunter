#!/bin/bash

# Node.js Installer Script
# Author: Mahesh Technicals
# Version: 1.0

# Colors for stylish UI
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)
BOLD=$(tput bold)

# Function to display header
header() {
    clear
    echo "${CYAN}${BOLD}======================================="
    echo "        Node.js Installer Script"
    echo "             by Mahesh Technicals"
    echo "=======================================${RESET}"
    echo
}

# Function to install Node.js
install_nodejs() {
    header
    echo "${YELLOW}Step 1:${RESET} Installing wget package..."
    sudo apt update && sudo apt install -y wget

    echo "${YELLOW}Step 2:${RESET} Installing NVM..."
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash

    PROFILE_FILE=""
    for file in ~/.bash_profile ~/.zshrc ~/.profile ~/.bashrc; do
        if [ -f "$file" ]; then
            PROFILE_FILE="$file"
            echo "${GREEN}Profile file found:${RESET} $PROFILE_FILE"
            break
        fi
    done

    if [ -n "$PROFILE_FILE" ]; then
        echo "Adding NVM configuration to $PROFILE_FILE..."
        {
            echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"'
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm'
        } >> "$PROFILE_FILE"
        echo "${GREEN}Configuration added!${RESET}"
        echo "Sourcing $PROFILE_FILE..."
        source "$PROFILE_FILE"
    else
        echo "${RED}No profile file found. Please add the NVM configuration manually.${RESET}"
    fi

    echo "${YELLOW}Step 3:${RESET} Installing Node.js LTS version..."
    nvm install --lts

    echo "${YELLOW}Step 4:${RESET} Showing installed versions..."
    echo "${GREEN}Node.js version:${RESET} $(node -v)"
    echo "${GREEN}npm version:${RESET} $(npm -v)"
    echo "${GREEN}Installation Complete!${RESET}"
    sleep 2
}

# Function to uninstall Node.js and NVM
uninstall_all() {
    header
    echo "${RED}Uninstalling NVM and Node.js...${RESET}"
    rm -rf "$HOME/.nvm"

    for file in ~/.bash_profile ~/.zshrc ~/.profile ~/.bashrc; do
        if [ -f "$file" ]; then
            sed -i '/export NVM_DIR/d' "$file"
            sed -i '/nvm.sh/d' "$file"
        fi
    done

    echo "${GREEN}NVM and Node.js have been uninstalled.${RESET}"
    sleep 2
}

# Main menu function
menu() {
    while true; do
        header
        echo "Use the ${BOLD}arrow keys${RESET} to navigate and ${BOLD}Enter${RESET} to select an option:"
        echo

        # Display options using select
        options=("Install Node.js" "Uninstall Node.js and NVM" "Exit Script")
        select opt in "${options[@]}"; do
            case $REPLY in
                1)
                    install_nodejs
                    break
                    ;;
                2)
                    uninstall_all
                    break
                    ;;
                3)
                    echo "${GREEN}Exiting script. Goodbye!${RESET}"
                    exit 0
                    ;;
                *)
                    echo "${RED}Invalid option. Please try again.${RESET}"
                    ;;
            esac
        done
    done
}

# Run the menu
menu
