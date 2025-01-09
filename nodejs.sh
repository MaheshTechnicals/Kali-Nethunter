#!/bin/bash

# Stylish Node.js Installer Script by Mahesh Technicals

# Colors for UI
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Display script header
clear
echo -e "${CYAN}==========================================${RESET}"
echo -e "${GREEN}       Node.js Installer Script           ${RESET}"
echo -e "${YELLOW}              by Mahesh Technicals         ${RESET}"
echo -e "${CYAN}==========================================${RESET}"

# Function to display options in a table format
display_menu() {
    echo -e "${BLUE}Choose an option:${RESET}"
    echo -e "${GREEN}+------------------------------------+${RESET}"
    echo -e "${GREEN}| Option | Description               |${RESET}"
    echo -e "${GREEN}+------------------------------------+${RESET}"
    echo -e "${YELLOW}|   1    | Install Node.js           |${RESET}"
    echo -e "${YELLOW}|   2    | Uninstall Node.js and NVM |${RESET}"
    echo -e "${YELLOW}|   3    | Exit                      |${RESET}"
    echo -e "${GREEN}+------------------------------------+${RESET}"
}

# Function to install Node.js
install_nodejs() {
    clear
    echo -e "${CYAN}Step 1: Installing wget package...${RESET}"
    sudo apt update && sudo apt install -y wget
    clear

    echo -e "${CYAN}Step 2: Installing NVM...${RESET}"
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash
    clear

    echo -e "${CYAN}Step 3: Configuring NVM...${RESET}"
    PROFILE_FILE=""
    for file in ~/.bash_profile ~/.zshrc ~/.profile ~/.bashrc; do
        if [ -f "$file" ]; then
            PROFILE_FILE="$file"
            echo -e "${GREEN}Profile file found: $PROFILE_FILE${RESET}"
            break
        fi
    done

    if [ -n "$PROFILE_FILE" ]; then
        echo -e "${YELLOW}Adding NVM configuration to $PROFILE_FILE...${RESET}"
        {
            echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"'
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm'
        } >> "$PROFILE_FILE"
        echo -e "${CYAN}Sourcing $PROFILE_FILE...${RESET}"
        source "$PROFILE_FILE"
    else
        echo -e "${RED}No profile file found. Please add the NVM configuration manually.${RESET}"
    fi
    clear

    echo -e "${CYAN}Step 4: Installing Node.js LTS version...${RESET}"
    nvm install --lts
    clear

    echo -e "${CYAN}Installation complete!${RESET}"
    echo -e "${GREEN}Node.js version: $(node -v)${RESET}"
    echo -e "${GREEN}npm version: $(npm -v)${RESET}"
    if [ -n "$PROFILE_FILE" ]; then
        echo -e "${YELLOW}NVM was configured in: $PROFILE_FILE${RESET}"
    fi
}

# Function to uninstall NVM and Node.js
uninstall_all() {
    clear
    echo -e "${CYAN}Uninstalling NVM and Node.js...${RESET}"
    rm -rf "$HOME/.nvm"
    for file in ~/.bash_profile ~/.zshrc ~/.profile ~/.bashrc; do
        if [ -f "$file" ]; then
            sed -i '/export NVM_DIR/d' "$file"
            sed -i '/nvm.sh/d' "$file"
        fi
    done
    echo -e "${RED}NVM and Node.js have been uninstalled.${RESET}"
}

# Main script logic
while true; do
    display_menu
    read -p "$(echo -e "${CYAN}Enter your choice (1/2/3): ${RESET}")" choice
    case $choice in
        1)
            install_nodejs
            break
            ;;
        2)
            uninstall_all
            break
            ;;
        3)
            echo -e "${YELLOW}Exiting script. Goodbye!${RESET}"
            break
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${RESET}"
            ;;
    esac
done
