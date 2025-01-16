#!/bin/bash

# Colors for styling
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

SCRIPT_NAME="Global Node.js Installer"
AUTHOR="Mahesh Technicals"

# Function to display the menu
show_menu() {
    clear
    echo -e "${CYAN}======================================${RESET}"
    echo -e "${GREEN}$SCRIPT_NAME${RESET}"
    echo -e "Author: $AUTHOR"
    echo -e "${CYAN}======================================${RESET}"
    echo -e "${YELLOW}Select an option:${RESET}"
    echo -e "${CYAN}1.${RESET} Install Node.js (LTS) globally using NVM"
    echo -e "${CYAN}2.${RESET} Uninstall NVM and Node.js globally"
    echo -e "${CYAN}3.${RESET} Exit"
    echo -e "${CYAN}======================================${RESET}"
}

# Function to install Node.js globally
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
    if [ ! -d "/usr/local/nvm" ]; then
        echo -e "${CYAN}Installing NVM globally...${RESET}"
        wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash
        # Move NVM to /usr/local/nvm for global access
        sudo mkdir -p /usr/local/nvm
        sudo mv "$HOME/.nvm"/* /usr/local/nvm/
        sudo rm -rf "$HOME/.nvm"
    else
        echo -e "${GREEN}NVM is already installed globally, skipping installation.${RESET}"
    fi

    clear

    # Configure NVM globally
    echo -e "${CYAN}Configuring NVM globally...${RESET}"
    echo 'export NVM_DIR="/usr/local/nvm"' | sudo tee -a /etc/profile.d/nvm.sh >/dev/null
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' | sudo tee -a /etc/profile.d/nvm.sh >/dev/null
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' | sudo tee -a /etc/profile.d/nvm.sh >/dev/null
    source /etc/profile.d/nvm.sh

    # Install Node.js (LTS) globally
    echo -e "${CYAN}Installing Node.js (LTS) globally...${RESET}"
    nvm install --lts
    nvm alias default lts/*

    # Make Node.js binaries available system-wide
    sudo ln -sf /usr/local/nvm/versions/node/$(nvm version default)/bin/node /usr/local/bin/node
    sudo ln -sf /usr/local/nvm/versions/node/$(nvm version default)/bin/npm /usr/local/bin/npm
    sudo ln -sf /usr/local/nvm/versions/node/$(nvm version default)/bin/npx /usr/local/bin/npx

    clear
    echo -e "${GREEN}Installation complete!${RESET}"
    echo -e "Node.js version: ${GREEN}$(node -v)${RESET}"
    echo -e "npm version: ${GREEN}$(npm -v)${RESET}"
}

# Function to uninstall Node.js and NVM globally
uninstall_all() {
    clear
    echo -e "${CYAN}Uninstalling NVM and Node.js globally...${RESET}"

    # Remove the NVM directory
    sudo rm -rf /usr/local/nvm

    # Remove NVM configuration from global profile
    sudo rm -f /etc/profile.d/nvm.sh

    # Remove Node.js binaries from /usr/local/bin
    sudo rm -f /usr/local/bin/node
    sudo rm -f /usr/local/bin/npm
    sudo rm -f /usr/local/bin/npx

    echo -e "${GREEN}Uninstallation complete!${RESET}"
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

