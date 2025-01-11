#!/bin/bash

R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

# Get the architecture
arch=$(uname -m)
username=$(getent group sudo | awk -F ':' '{print $4}' | cut -d ',' -f1)

# Check if the script is run as root
check_root(){
    if [ "$(id -u)" -ne 0 ]; then
        echo -ne " ${R}Run this program as root!\n\n"${W}
        exit 1
    fi
}

# Download the root filesystem based on the architecture
download_rootfs(){
    case "$arch" in
        "x86_64")
            url="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-amd64.tar.xz"
            ;;
        "aarch64")
            url="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz"
            ;;
        "armv7l")
            url="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-armhf.tar.xz"
            ;;
        "i686")
            url="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-i386.tar.xz"
            ;;
        *)
            echo -ne "${R}Unsupported architecture: $arch\n${W}"
            exit 1
            ;;
    esac
    echo -e "${G}Downloading root filesystem for $arch...\n${W}"
    wget -O kali-rootfs.tar.xz "$url"
}

# Install necessary packages
install_packages(){
    apt-get update -y
    apt-get install -y \
        sudo curl nano git xfce4 xfce4-goodies xfce4-terminal tigervnc-standalone-server \
        tigervnc-common tigervnc-tools dbus-x11 fonts-beng fonts-beng-extra gtk2-engines-murrine \
        gtk2-engines-pixbuf apt-transport-https
}

# Set up VNC server and XFCE GUI
setup_vnc_gui(){
    # Set up XFCE desktop
    echo -e "${G}Setting up XFCE desktop environment...\n${W}"
    echo "xfce4-session" > ~/.vnc/xstartup
    chmod +x ~/.vnc/xstartup
    
    # Set up the VNC server to run on display :1
    vncserver :1
    
    echo -e "${G}VNC server set up. Use VNC client to connect to localhost:1\n${W}"
}

# Configure user and password for sudo
setup_user(){
    echo -e "${G}Setting up sudo user and password...\n${W}"
    read -p "Enter your sudo password: " sudo_pass
    echo "$username:$sudo_pass" | chpasswd
    usermod -aG sudo $username
}

# Show the final message
show_message(){
    echo -e "${G}Kali Linux installation completed!\n"
    echo -e "${Y}Use the following to start your VNC server:\n${W}vncserver :1"
    echo -e "${G}Enjoy your Kali Linux setup with VNC!\n${W}"
}

# Main script execution
check_root
download_rootfs
install_packages
setup_vnc_gui
setup_user
show_message

