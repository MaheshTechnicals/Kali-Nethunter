
#!/bin/bash

# Function to print colored text
print_color() {
    COLOR='\033[1;36m' # Cyan color
    RED='\033[1;31m'   # Red color
    GREEN='\033[1;32m' # Green color
    NC='\033[0m' # No Color
    if [ "$2" == "error" ]; then
        echo -e "${RED}$1${NC}"
    elif [ "$2" == "success" ]; then
        echo -e "${GREEN}$1${NC}"
    else
        echo -e "${COLOR}$1${NC}"
    fi
}

# Function to print colored box
print_box() {
    echo -e "\033[1;34m+----------------------------------+"
    echo -e "|                                  |"
    echo -e "|        Sublime Text Setup        |"
    echo -e "|                                  |"
    echo -e "|       Author: Mahesh Technicals  |"
    echo -e "|                                  |"
    echo -e "+----------------------------------+\033[0m"
}

# Function to print colored options
print_options() {
    echo -e "\033[1;33m|----------------------------------|"
    echo -e "|           Select an option        |"
    echo -e "|----------------------------------|"
    echo -e "|        \033[1;32m1. INSTALL\033[1;33m             |"
    echo -e "|        \033[1;32m2. UNINSTALL\033[1;33m           |"
    echo -e "|        \033[1;32m3. EXIT\033[1;33m                |"
    echo -e "|----------------------------------|\033[0m"
}

# Print colored box UI
print_box

# Print colored options
print_options

# Function to install Sublime Text
install_sublime() {
    # Install dependencies
    print_color "Updating package list..." ""
    sudo apt update || { print_color "Failed to update package list." "error"; exit 1; }
    
    print_color "Installing wget..." ""
    sudo apt install wget -y || { print_color "Failed to install wget." "error"; exit 1; }

    # Add Sublime Text repository key
    print_color "Adding Sublime Text repository key..." ""
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null || { print_color "Failed to add repository key." "error"; exit 1; }

    # Install apt-transport-https
    print_color "Installing apt-transport-https..." ""
    sudo apt install apt-transport-https -y || { print_color "Failed to install apt-transport-https." "error"; exit 1; }

    # Update and install Sublime Text
    print_color "Updating package list..." ""
    sudo apt update || { print_color "Failed to update package list." "error"; exit 1; }

    print_color "Installing Sublime Text..." ""
    sudo apt install sublime-text -y || { print_color "Failed to install Sublime Text." "error"; exit 1; }

    # Print completion message
    print_color "Sublime Text has been successfully installed!" "success"

    # Print colored box UI
    print_box

    # Print colored options
    print_options
}

# Function to uninstall Sublime Text
uninstall_sublime() {
    # Uninstall Sublime Text
    print_color "Uninstalling Sublime Text..." ""
    sudo apt remove sublime-text -y || { print_color "Failed to uninstall Sublime Text." "error"; exit 1; }

    # Print completion message
    print_color "Sublime Text has been successfully uninstalled!" "success"

    # Print colored box UI
    print_box

    # Print colored options
    print_options
}

# Main function
main() {
    # Clear input buffer
    read -t 0.1 -n 10000 discard

    while true; do
        read -p "Enter your choice: " choice
        case $choice in
            1)
                install_sublime
                ;;
            2)
                uninstall_sublime
                ;;
            3)
                exit 0
                ;;
            *)
                print_color "Invalid option. Please choose again." "error"
                ;;
        esac
    done
}

# Start the script
main
