#!/bin/bash

R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"
arch=$(uname -m)
username=$(getent group sudo | awk -F ':' '{print $4}' | cut -d ',' -f1)

check_root(){
    if [ "$(id -u)" -ne 0 ]; then
        echo -ne " ${R}Run this program as root!\n\n"${W}
        exit 1
    fi
}

banner() {
    clear
    cat <<- EOF
        ${Y}    _  _ ___  _  _ _  _ ___ _  _    _  _ ____ ___  
        ${C}    |  | |__] |  | |\ |  |  |  |    |\/| |  | |  \ 
        ${G}    |__| |__] |__| | \|  |  |__|    |  | |__| |__/ 

    EOF
    echo -e "${G}    Kali Linux Nethunter Installer for Termux\n"
}

note() {
    banner
    echo -e " ${G} [-] Successfully Installed!\n"${W}
    sleep 1
    cat <<- EOF
         ${G}[-] Type ${C}vncstart${G} to start the VNC server.
         ${G}[-] Type ${C}vncstop${G} to stop the VNC server.
    EOF
}

downloader(){
    path="$1"
    [[ -e "$path" ]] && rm -rf "$path"
    echo "Downloading $(basename $1)..."
    curl --progress-bar --insecure --fail \
         --retry-connrefused --retry 3 --retry-delay 2 \
         --location --output ${path} "$2"
}

setup_vnc(){
    echo -e "${G}Setting up VNC Server...${W}"
    apt install -y tigervnc-standalone-server tigervnc-common tigervnc-tools
    mkdir -p ~/.vnc
    vncserver :1
    echo "VNC server started. You can access it with VNC Viewer."
}

install_gui(){
    echo -e "${G}Installing XFCE4 Desktop Environment...${W}"
    apt-get install -y xfce4 xfce4-goodies xfce4-terminal dbus-x11
}

setup_rootfs(){
    case "$arch" in
        x86_64)
            rootfs_url="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-amd64.tar.xz"
            ;;
        aarch64)
            rootfs_url="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz"
            ;;
        armv7l)
            rootfs_url="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-armhf.tar.xz"
            ;;
        i386)
            rootfs_url="https://kali.download/nethunter-images/current/rootfs/kali-nethunter-rootfs-minimal-i386.tar.xz"
            ;;
        *)
            echo -e "${R}Unsupported architecture: $arch${W}"
            exit 1
            ;;
    esac

    echo -e "${G}Downloading the Kali Linux Root filesystem...${W}"
    downloader "/data/data/com.termux/files/home/kali-rootfs.tar.xz" "$rootfs_url"
    echo -e "${G}Extracting the Root filesystem...${W}"
    tar -xvf /data/data/com.termux/files/home/kali-rootfs.tar.xz -C /data/data/com.termux/files/home
}

install_packages(){
    echo -e "${G}Installing required packages...${W}"
    apt-get update -y
    apt-get install -y sudo gnupg2 curl nano git xz-utils at-spi2-core dialog exo-utils
}

set_up_user(){
    echo -e "${G}Setting up user and password...${W}"
    useradd -m -s /bin/bash "$username"
    echo "$username:$password" | chpasswd
    adduser "$username" sudo
    echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
}

main(){
    check_root
    banner
    setup_rootfs
    install_gui
    install_packages
    setup_vnc
    set_up_user
    note
}

main

