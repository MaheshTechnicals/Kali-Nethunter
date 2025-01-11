#!/bin/bash

R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"
arch=$(uname -m)

check_arch() {
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
}

downloader(){
    path="$1"
    [[ -e "$path" ]] && rm -rf "$path"
    echo "Downloading $(basename $1)..."
    curl --progress-bar --insecure --fail \
         --retry-connrefused --retry 3 --retry-delay 2 \
         --location --output ${path} "$2"
}

setup_rootfs(){
    check_arch
    echo -e "${G}Downloading the Kali Linux Root filesystem...${W}"
    downloader "$HOME/kali-rootfs.tar.xz" "$rootfs_url"
    echo -e "${G}Extracting the Root filesystem...${W}"
    tar -xvf "$HOME/kali-rootfs.tar.xz" -C "$HOME/kali-rootfs"
}

install_gui(){
    echo -e "${G}Installing XFCE4 Desktop Environment...${W}"
    pkg update -y
    pkg install -y xfce4 xfce4-terminal tigervnc
}

setup_vnc(){
    echo -e "${G}Setting up VNC Server...${W}"
    mkdir -p "$HOME/.vnc"
    vncserver :1
    echo "VNC server started on :1. You can connect using a VNC viewer."
}

start_kali(){
    echo -e "${G}Starting Kali Linux in Termux...${W}"
    cd "$HOME/kali-rootfs"
    proot -S . /bin/bash --login
}

finish_setup(){
    echo -e "${G}Kali Linux Installation Complete!${W}"
    echo -e "${G}You can start Kali Linux by running: ${C}start-kali${W}"
}

main(){
    setup_rootfs
    install_gui
    setup_vnc
    finish_setup
}

# Start Kali Linux setup
main

