#!/data/data/com.termux/files/usr/bin/bash -e

# Stylish Colorful Header for Kali Linux Installer
function print_header() {
    echo -e "\033[1;34m" # Blue text
    echo "##############################################################"
    echo "#                                                            #"
    echo "#        🐉 Kali Linux Installer Script by Mahesh Technicals       #"
    echo "#                                                            #"
    echo "##############################################################"
    echo -e "\033[0m" # Reset text
}

print_header

# Ensure system is updated and wget is installed
echo -e "\033[1;32m[*] Initializing setup...\033[0m" # Green text
apt update -y && yes | apt upgrade && \
pkg install -y wget && pkg install x11-repo -y && \
pkg update && pkg install termux-x11-nightly -y && \
pkg install tigervnc

# Install Required Commands
function install_dependencies() {
    echo -e "\033[1;32m[*] Checking and installing dependencies...\033[0m"
    packages=("wget" "proot" "tar" "sha512sum")

    for pkg in "${packages[@]}"; do
        if ! command -v $pkg &> /dev/null; then
            echo -e "\033[1;31m[!] $pkg not found. Installing...\033[0m" # Red text
            apt update -y && apt install -y $pkg || {
                echo -e "\033[1;31mFailed to install $pkg. Exiting.\033[0m"
                exit 1
            }
        else
            echo -e "\033[1;32m[*] $pkg is already installed.\033[0m"
        fi
    done
}

# Update and Upgrade System
function update_system() {
    echo -e "\033[1;32m[*] Updating and upgrading packages...\033[0m"
    apt update -y && apt upgrade -y
}

# Unsupported Architecture Message
function unsupported_arch() {
    echo -e "\033[1;31m[*] Unsupported Architecture\033[0m\n"
    exit
}

# Function to Ask User Confirmation
function ask() {
    while true; do
        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        echo -en "\033[1;36m[?] $1 [$prompt] \033[0m" # Cyan text
        read -p "" REPLY

        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

# Check Device Architecture
function get_arch() {
    echo -e "\033[1;34m[*] Checking device architecture...\033[0m" # Blue text
    case $(getprop ro.product.cpu.abi) in
        arm64-v8a)
            SYS_ARCH=arm64
            ;;
        armeabi|armeabi-v7a)
            SYS_ARCH=armhf
            ;;
        *)
            unsupported_arch
            ;;
    esac
}

# Define Strings Based on Architecture
function set_strings() {
    echo -e "\033[1;33m" # Yellow text
    echo "Choose NetHunter Image:"
    if [[ ${SYS_ARCH} == "arm64" ]]; then
        echo "[1] NetHunter ARM64 (full)"
        echo "[2] NetHunter ARM64 (minimal)"
        echo "[3] NetHunter ARM64 (nano)"
    elif [[ ${SYS_ARCH} == "armhf" ]]; then
        echo "[1] NetHunter ARMhf (full)"
        echo "[2] NetHunter ARMhf (minimal)"
        echo "[3] NetHunter ARMhf (nano)"
    fi
    echo -e "\033[0m" # Reset text

    read -p "Enter the image you want to install: " wimg
    case $wimg in
        1) wimg="full" ;;
        2) wimg="minimal" ;;
        3) wimg="nano" ;;
        *) wimg="full" ;;
    esac

    CHROOT=chroot/kali-${SYS_ARCH}
    IMAGE_NAME=kali-nethunter-rootfs-${wimg}-${SYS_ARCH}.tar.xz
    SHA_NAME=${IMAGE_NAME}.sha512sum
}

# Cleanup Function
function cleanup() {
    if [ -f "${IMAGE_NAME}" ]; then
        if ask "Delete downloaded rootfs file?" "N"; then
            rm -f "${IMAGE_NAME}" "${SHA_NAME}"
        fi
    fi
}

# Main Installation Workflow
install_dependencies
update_system
get_arch
set_strings
prepare_fs
cleanup
