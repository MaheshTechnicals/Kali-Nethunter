#!/bin/bash

install_sublime() {
    clear
    echo -e "\e[1;32mInstalling Sublime Text Editor\e[0m"
    sudo apt install wget -y
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get install apt-transport-https
    sudo apt-get update
    sudo apt-get install sublime-text
    echo -e "\e[1;32mSublime Text Editor installed successfully!\e[0m"
    exit 0
}

uninstall_sublime() {
    clear
    echo -e "\e[1;31mUninstalling Sublime Text Editor\e[0m"
    sudo apt-get remove --purge sublime-text
    sudo rm -rf /etc/apt/trusted.gpg.d/sublimehq-archive.gpg
    sudo rm -rf /etc/apt/sources.list.d/sublime-text.list
    sudo apt-get autoremove
    echo -e "\e[1;31mSublime Text Editor uninstalled successfully!\e[0m"
    exit 0
}

show_menu() {
    clear
    printf "\n"
    printf "\e[1;35m%40s\e[0m\n" "Sublime Text Editor Installer By Mahesh Technicals"
    printf "\n"
    printf "\e[1;36m%-40s\e[0m\n" "|-----------------------------|"
    printf "\e[1;36m%-40s\e[0m\n" "|         Choose Option        |"
    printf "\e[1;36m%-40s\e[0m\n" "|-----------------------------|"
    printf "\e[1;36m%-40s\e[0m\n" "| 1. Install                  |"
    printf "\e[1;36m%-40s\e[0m\n" "| 2. Uninstall                |"
    printf "\e[1;36m%-40s\e[0m\n" "| 3. Exit                     |"
    printf "\e[1;36m%-40s\e[0m\n" "|-----------------------------|"
    printf "\n"
}

center_menu() {
    # Get terminal width
    TERM_WIDTH=$(tput cols)
    # Calculate padding
    PADDING=$(( ($TERM_WIDTH - 40) / 2 ))
    # Print padding
    for ((i=0; i<$PADDING; i++)); do
        printf " "
    done
}

while true; do
    clear
    center_menu
    show_menu
    read -p "Enter your choice: " choice
    case $choice in
        1)
            install_sublime
            ;;
        2)
            uninstall_sublime
            ;;
        3)
            clear
            echo -e "\e[1;33mExiting...\e[0m"
            exit 0
            ;;
        *)
            echo "Invalid option, please try again."
            ;;
    esac
done
