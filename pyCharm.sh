#!/bin/bash

# Function to print messages in color
print_color() {
    case $1 in
        "red") echo -e "\e[31m$2\e[0m" ;;
        "green") echo -e "\e[32m$2\e[0m" ;;
        "yellow") echo -e "\e[33m$2\e[0m" ;;
        "blue") echo -e "\e[34m$2\e[0m" ;;
        *) echo "$2" ;;
    esac
}

# Function to install pv utility
install_pv() {
    print_color "blue" "Installing pv utility..."
    if command -v pv &>/dev/null; then
        print_color "green" "pv is already installed."
        return
    fi
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y pv
    elif command -v yum &>/dev/null; then
        sudo yum install -y pv
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y pv
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm pv
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y pv
    else
        print_color "red" "Unsupported package manager. Please install pv manually."
        exit 1
    fi
}

# Function to install PyCharm
install_pycharm() {
    local pycharm_url="https://download.jetbrains.com/python/pycharm-community-2024.3.1.1.tar.gz"
    local pycharm_tar="pycharm.tar.gz"
    local install_dir="/opt/pycharm"

    print_color "blue" "Downloading PyCharm..."
    wget "$pycharm_url" -O "$pycharm_tar"
    if [[ $? -ne 0 ]]; then
        print_color "red" "Download failed! Exiting..."
        exit 1
    fi

    print_color "blue" "Extracting PyCharm..."
    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"
    pv "$pycharm_tar" | sudo tar -xz --strip-components=1 -C "$install_dir"
    rm -f "$pycharm_tar"

    print_color "blue" "Creating symbolic link..."
    sudo ln -sf "$install_dir/bin/pycharm.sh" /usr/local/bin/pycharm

    print_color "blue" "Creating desktop entry..."
    cat << EOF | sudo tee /usr/share/applications/pycharm.desktop > /dev/null
[Desktop Entry]
Name=PyCharm
Comment=Integrated Development Environment for Python
Exec=$install_dir/bin/pycharm.sh %f
Icon=$install_dir/bin/pycharm.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

    print_color "green" "PyCharm has been installed successfully!"
}

# Function to uninstall PyCharm
uninstall_pycharm() {
    local install_dir="/opt/pycharm"

    print_color "blue" "Removing PyCharm installation..."
    sudo rm -rf "$install_dir"

    print_color "blue" "Removing symbolic link..."
    sudo rm -f /usr/local/bin/pycharm

    print_color "blue" "Removing desktop entry..."
    sudo rm -f /usr/share/applications/pycharm.desktop

    print_color "green" "PyCharm has been uninstalled successfully!"
}

# Display menu
while true; do
    clear
    echo "==========================="
    echo "     PyCharm Installer     "
    echo "==========================="
    echo "1. Install PyCharm"
    echo "2. Uninstall PyCharm"
    echo "3. Exit"
    echo -n "Enter your choice: "
    read -r choice

    case $choice in
        1)
            install_pv
            install_pycharm
            read -r -p "Press any key to continue..."
            ;;
        2)
            uninstall_pycharm
            read -r -p "Press any key to continue..."
            ;;
        3)
            print_color "yellow" "Exiting. Goodbye!"
            exit 0
            ;;
        *)
            print_color "red" "Invalid option. Please try again."
            ;;
    esac
done

