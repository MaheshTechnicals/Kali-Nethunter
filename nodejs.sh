#!/bin/bash

# Colors for styling
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

SCRIPT_NAME="Node.js Installer"
AUTHOR="Mahesh Technicals"

# Function to display the menu
show_menu() {
    clear
    echo -e "${CYAN}======================================${RESET}"
    echo -e "${GREEN}$SCRIPT_NAME${RESET}"
    echo -e "Author: $AUTHOR"
    echo -e "${CYAN}======================================${RESET}"
    echo -e "${YELLOW}Select an option:${RESET}"
    echo -e "${CYAN}1.${RESET} Install Node.js (LTS) using NVM"
    echo -e "${CYAN}2.${RESET} Uninstall NVM and Node.js"
    echo -e "${CYAN}3.${RESET} Exit"
    echo -e "${CYAN}======================================${RESET}"
}

# Function to install Node.js
install_node() {
    clear

    # Check if wget is installed, if not install it
    if ! command -v wget &>/dev/null; then
        echo -e "${CYAN}Installing wget...${RESET}"
        sudo apt update && sudo apt install -y wget
    else
        echo -e "${GREEN}wget is already installed, skipping installation.${RESET}"
    fi
    clear

    # Check if NVM is installed, if not install it
    if ! command -v nvm &>/dev/null; then
        echo -e "${CYAN}Installing NVM...${RESET}"
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash
    else
        echo -e "${GREEN}NVM is already installed, skipping installation.${RESET}"
    fi
    clear

    echo -e "${CYAN}Configuring NVM...${RESET}"
    PROFILE_FILES=(~/.bash_profile ~/.zshrc ~/.profile ~/.bashrc)
    CONFIGURED_FILE=""
    for file in "${PROFILE_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${YELLOW}Found configuration file: $file${RESET}"
            CONFIGURED_FILE="$file"
            {
                echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"'
                echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm'
            } >>"$file"
            source "$file"
            break
        fi
    done

    if [ -z "$CONFIGURED_FILE" ]; then
        echo -e "${RED}No suitable profile file found!${RESET}"
        exit 1
    fi

    echo -e "${CYAN}Installing Node.js (LTS)...${RESET}"
    nvm install --lts
    clear

    echo -e "${GREEN}Installation complete!${RESET}"
    echo -e "Node.js version: ${GREEN}$(node -v)${RESET}"
    echo -e "npm version: ${GREEN}$(npm -v)${RESET}"
    echo -e "NVM was configured in: ${YELLOW}$CONFIGURED_FILE${RESET}"

    # Ensure the shell configuration files are sourced
    echo -e "${CYAN}Sourcing appropriate profile files...${RESET}"
    for file in "${PROFILE_FILES[@]}"; do
        if [ -f "$file" ]; then
            source "$file"
            echo -e "${GREEN}Sourced $file successfully!${RESET}"
        else
            echo -e "${RED}$file not found! Please manually source it.${RESET}"
        fi
    done
}

# Function to uninstall NVM and Node.js
uninstall_all() {
    clear
    echo -e "${CYAN}Uninstalling NVM and Node.js...${RESET}"

    # Remove the NVM directory
    rm -rf "$HOME/.nvm"

    # Remove NVM references from profile files
    PROFILE_FILES=(~/.bash_profile ~/.zshrc ~/.profile ~/.bashrc)
    for file in "${PROFILE_FILES[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${YELLOW}Cleaning NVM configuration from $file...${RESET}"
            sed -i '/NVM_DIR/d' "$file"
            sed -i '/nvm.sh/d' "$file"
        fi
    done

    # Reload the shell configuration
    echo -e "${CYAN}Reloading your shell configuration...${RESET}"
    for file in "${PROFILE_FILES[@]}"; do
        if [ -f "$file" ]; then
            source "$file"
            echo -e "${GREEN}Sourced $file successfully!${RESET}"
        fi
    done

    # Confirm uninstallation
    if command -v nvm &>/dev/null; then
        echo -e "${RED}NVM is still detected in your environment. Please restart your terminal to fully remove it.${RESET}"
    else
        echo -e "${GREEN}NVM and Node.js have been completely uninstalled.${RESET}"
    fi
}

# Main script loop
while true; do
    show_menu
    read -rp "Enter your choice: " choice
    case $choice in
    1)
        install_node
        break
        ;;
    2)
        uninstall_all
        break
        ;;
    3)
        echo -e "${CYAN}Exiting...${RESET}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice! Please try again.${RESET}"
        sleep 2
        ;;
    esac
done

