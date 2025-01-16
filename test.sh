#!/data/data/com.termux/files/usr/bin/bash -e

# Define Color Variables
RESET=$(tput sgr0)
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
MAGENTA=$(tput setaf 5)

# Colorful Header for Kali Linux Installer
function print_header() {
    echo "${CYAN}"
    echo "${BOLD}#############################################################"
    echo "${MAGENTA}### ${GREEN}Welcome to${CYAN} Kali Linux Installer ${MAGENTA}###"
    echo "${MAGENTA}###         ${YELLOW}By Mahesh Technicals ${MAGENTA}       ###"
    echo "${CYAN}"
    echo "${BOLD}#############################################################"
    echo "${RESET}"
}

# Ensure system is updated and wget is installed
function initial_setup() {
    echo "${BLUE}[*] Initializing setup...${RESET}"
    apt update -y && yes | apt upgrade && pkg install -y wget && pkg install x11-repo -y && pkg update && pkg install termux-x11-nightly -y && pkg install tigervnc
}

# Install Required Commands
function install_dependencies() {
    echo "${GREEN}[*] Checking and installing dependencies...${RESET}"
    packages=("wget" "proot" "tar" "sha512sum")

    for pkg in "${packages[@]}"; do
        if ! command -v $pkg &> /dev/null; then
            echo "${RED}[!] $pkg not found. Installing...${RESET}"
            apt update -y && apt install -y $pkg || { echo "${RED}Failed to install $pkg. Exiting.${RESET}"; exit 1; }
        else
            echo "${GREEN}[*] $pkg is already installed.${RESET}"
        fi
    done
}

# Update and Upgrade System
function update_system() {
    echo "${BLUE}[*] Updating and upgrading packages...${RESET}"
    apt update -y && apt upgrade -y
}

# Architecture detection function
function get_arch() {
    echo "${BLUE}[*] Checking device architecture...${RESET}"
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

# Display unsupported architecture message
function unsupported_arch() {
    echo "${RED}[*] Unsupported Architecture${RESET}"
    exit
}

# Ask function to prompt user for yes/no responses
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

        # Ask the question
        echo "${CYAN}[?] $1 [$prompt]${RESET}"
        read -p "Enter your choice: " REPLY

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

# Set image names and paths based on architecture
function set_strings() {
    if [[ ${SYS_ARCH} == "arm64" ]]; then
        echo "${YELLOW}[1] NetHunter ARM64 (full)${RESET}"
        echo "${YELLOW}[2] NetHunter ARM64 (minimal)${RESET}"
        echo "${YELLOW}[3] NetHunter ARM64 (nano)${RESET}"
        read -p "Enter the image you want to install: " wimg
        case $wimg in
            1) wimg="full" ;;
            2) wimg="minimal" ;;
            3) wimg="nano" ;;
            *) wimg="full" ;;
        esac
    elif [[ ${SYS_ARCH} == "armhf" ]]; then
        echo "${YELLOW}[1] NetHunter ARMhf (full)${RESET}"
        echo "${YELLOW}[2] NetHunter ARMhf (minimal)${RESET}"
        echo "${YELLOW}[3] NetHunter ARMhf (nano)${RESET}"
        read -p "Enter the image you want to install: " wimg
        case $wimg in
            1) wimg="full" ;;
            2) wimg="minimal" ;;
            3) wimg="nano" ;;
            *) wimg="full" ;;
        esac
    fi

    CHROOT=chroot/kali-${SYS_ARCH}
    IMAGE_NAME=kali-nethunter-rootfs-${wimg}-${SYS_ARCH}.tar.xz
    SHA_NAME=${IMAGE_NAME}.sha512sum
}

# Prepare file system
function prepare_fs() {
    unset KEEP_CHROOT
    if [ -d ${CHROOT} ]; then
        if ask "Existing rootfs directory found. Delete and create a new one?" "N"; then
            rm -rf ${CHROOT}
        else
            KEEP_CHROOT=1
        fi
    fi
}

# Cleanup downloaded files
function cleanup() {
    if [ -f "${IMAGE_NAME}" ]; then
        if ask "Delete downloaded rootfs file?" "N"; then
            rm -f "${IMAGE_NAME}"
            rm -f "${SHA_NAME}"
        fi
    fi
}

# Check for necessary dependencies
function check_dependencies() {
    echo "${BLUE}[*] Checking package dependencies...${RESET}"
    apt-get update -y &> /dev/null || apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y &> /dev/null

    for i in proot tar axel; do
        if [ -e "$PREFIX"/bin/$i ]; then
            echo "  $i is OK"
        else
            echo "${RED}Installing ${i}...${RESET}"
            apt install -y $i || {
                echo "${RED}ERROR: Failed to install packages. Exiting.${RESET}"
                exit
            }
        fi
    done
    apt upgrade -y
}

# Define download URL
function get_url() {
    BASE_URL="https://kali.download/nethunter-images/current/rootfs"
    ROOTFS_URL="${BASE_URL}/${IMAGE_NAME}"
    SHA_URL="${BASE_URL}/${SHA_NAME}"
}

# Download rootfs image
function get_rootfs() {
    unset KEEP_IMAGE
    if [ -f "${IMAGE_NAME}" ]; then
        if ask "Existing image file found. Delete and download a new one?" "N"; then
            rm -f "${IMAGE_NAME}"
        else
            echo "${GREEN}[!] Using existing rootfs archive${RESET}"
            KEEP_IMAGE=1
            return
        fi
    fi
    echo "${BLUE}[*] Downloading rootfs...${RESET}"
    get_url
    wget --continue "${ROOTFS_URL}"
}

# Download SHA file
function get_sha() {
    if [ -z $KEEP_IMAGE ]; then
        echo "${BLUE}[*] Getting SHA ... ${RESET}"
        get_url
        if [ -f "${SHA_NAME}" ]; then
            rm -f "${SHA_NAME}"
        fi
        wget --continue "${SHA_URL}"
    fi
}

# Verify SHA checksum
function verify_sha() {
    if [ -z $KEEP_IMAGE ]; then
        echo "${BLUE}[*] Verifying integrity of rootfs...${RESET}"
        sha512sum -c "$SHA_NAME" || {
            echo "${RED}Rootfs corrupted. Please run this installer again or download the file manually.${RESET}"
            exit 1
        }
    fi
}

# Extract the rootfs image
function extract_rootfs() {
    if [ -z $KEEP_CHROOT ]; then
        echo "${BLUE}[*] Extracting rootfs...${RESET}"
        proot --link2symlink tar -xf "$IMAGE_NAME" 2> /dev/null || :
    else        
        echo "${GREEN}[!] Using existing rootfs directory${RESET}"
    fi
}

# Create launcher for Kali
function create_launcher() {
    NH_LAUNCHER=${PREFIX}/bin/nethunter
    NH_SHORTCUT=${PREFIX}/bin/nh
    cat > "$NH_LAUNCHER" <<- EOF
#!/data/data/com.termux/files/usr/bin/bash -e
cd \${HOME}
## termux-exec sets LD_PRELOAD so let's unset it before continuing
unset LD_PRELOAD
## Workaround for Libreoffice, also needs to bind a fake /proc/version
if [ ! -f $CHROOT/root/.version ]; then
    touch $CHROOT/root/.version
fi

## Default user is "kali"
user="$USERNAME"
home="/home/\$user"
start="sudo -u kali /bin/bash"

## NH can be launched as root with the "-r" cmd attribute
## Also check if user kali exists, if not start as root
if grep -q "kali" ${CHROOT}/etc/passwd; then
    KALIUSR="1";
else
    KALIUSR="0";
fi
if [[ \$KALIUSR == "0" || \$1 == "-r" ]]; then
    start="sudo -u root /bin/bash"
fi

# start Kali chroot in proot
termux-chroot -R /opt -L /dev -R /root -g "kali\_user" --bind \${home}/rootfs \$start
EOF
    chmod +x "$NH_LAUNCHER"
    ln -s "$NH_LAUNCHER" "$NH_SHORTCUT"
}

# Main function to install NetHunter
function install_nethunter() {
    print_header
    get_arch
    initial_setup
    install_dependencies
    update_system
    set_strings
    prepare_fs
    check_dependencies
    get_rootfs
    get_sha
    verify_sha
    extract_rootfs
    create_launcher
    cleanup
}

# Start installation
install_nethunter

