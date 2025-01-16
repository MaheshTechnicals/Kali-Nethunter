#!/data/data/com.termux/files/usr/bin/bash -e

VERSION=2024091801
BASE_URL=https://kali.download/nethunter-images/kali-2024.2/rootfs
USERNAME=kali


function unsupported_arch() {
    printf "${red}"
    echo "[*] Unsupported Architecture\n\n"
    printf "${reset}"
    exit
}

function ask() {
    # http://djm.me/ask
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
        printf "${light_cyan}\n[?] "
        read -p "$1 [$prompt] " REPLY

        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        printf "${reset}"

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

function get_arch() {
    printf "${blue}[*] Checking device architecture ..."
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

function set_strings() {
    echo \
    && echo "" 
    ####
    if [[ ${SYS_ARCH} == "arm64" ]];
    then
        echo "[1] NetHunter ARM64 (full)"
        echo "[2] NetHunter ARM64 (minimal)"
        echo "[3] NetHunter ARM64 (nano)"
        read -p "Enter the image you want to install: " wimg
        if (( $wimg == "1" ));
        then
            wimg="full"
        elif (( $wimg == "2" ));
        then
            wimg="minimal"
        elif (( $wimg == "3" ));
        then
            wimg="nano"
        else
            wimg="full"
        fi
    elif [[ ${SYS_ARCH} == "armhf" ]];
    then
        echo "[1] NetHunter ARMhf (full)"
        echo "[2] NetHunter ARMhf (minimal)"
        echo "[3] NetHunter ARMhf (nano)"
        read -p "Enter the image you want to install: " wimg
        if [[ "$wimg" == "1" ]]; then
            wimg="full"
        elif [[ "$wimg" == "2" ]]; then
            wimg="minimal"
        elif [[ "$wimg" == "3" ]]; then
            wimg="nano"
        else
            wimg="full"
        fi
    fi
    ####


    CHROOT=chroot/kali-${SYS_ARCH}
    IMAGE_NAME=kali-nethunter-rootfs-${wimg}-${SYS_ARCH}.tar.xz
    SHA_NAME=${IMAGE_NAME}.sha512sum
}    

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

function cleanup() {
    if [ -f "${IMAGE_NAME}" ]; then
        if ask "Delete downloaded rootfs file?" "N"; then
        if [ -f "${IMAGE_NAME}" ]; then
                rm -f "${IMAGE_NAME}"
        fi
        if [ -f "${SHA_NAME}" ]; then
                rm -f "${SHA_NAME}"
        fi
        fi
    fi
} 

function check_dependencies() {
    printf "${blue}\n[*] Checking package dependencies...${reset}\n"
    ## Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
    ##apt update -y &> /dev/null
    apt-get update -y &> /dev/null || apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade -y &> /dev/null

    for i in proot tar axel; do
        if [ -e "$PREFIX"/bin/$i ]; then
            echo "  $i is OK"
        else
            printf "Installing ${i}...\n"
            apt install -y $i || {
                printf "${red}ERROR: Failed to install packages.\n Exiting.\n${reset}"
            exit
            }
        fi
    done
    apt upgrade -y
}


function get_url() {
    ROOTFS_URL="${BASE_URL}/${IMAGE_NAME}"
    SHA_URL="${BASE_URL}/${SHA_NAME}"
}

function get_rootfs() {
    unset KEEP_IMAGE
    if [ -f "${IMAGE_NAME}" ]; then
        if ask "Existing image file found. Delete and download a new one?" "N"; then
            rm -f "${IMAGE_NAME}"
        else
            printf "${yellow}[!] Using existing rootfs archive${reset}\n"
            KEEP_IMAGE=1
            return
        fi
    fi
    printf "${blue}[*] Downloading rootfs...${reset}\n\n"
    get_url
    wget "${EXTRA_ARGS}" --continue "${ROOTFS_URL}"
}

function get_sha() {
    if [ -z $KEEP_IMAGE ]; then
        printf "\n${blue}[*] Getting SHA ... ${reset}\n\n"
        get_url
        if [ -f "${SHA_NAME}" ]; then
            rm -f "${SHA_NAME}"
        fi
        wget "${EXTRA_ARGS}" --continue "${SHA_URL}"
    fi
}

function verify_sha() {
    if [ -z $KEEP_IMAGE ]; then
        printf "\n${blue}[*] Verifying integrity of rootfs...${reset}\n\n"
        sha512sum -c "$SHA_NAME" || {
            printf "${red} Rootfs corrupted. Please run this installer again or download the file manually\n${reset}"
            exit 1
        }
    fi
}

function extract_rootfs() {
    if [ -z $KEEP_CHROOT ]; then
        printf "\n${blue}[*] Extracting rootfs... ${reset}\n\n"
        proot --link2symlink tar -xf "$IMAGE_NAME" 2> /dev/null || :
    else        
        printf "${yellow}[!] Using existing rootfs directory${reset}\n"
    fi
}


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
if [[ \$KALIUSR == "0" || ("\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R")) ]];then
    user="root"
    home="/\$user"
    start="/bin/bash --login"
    if [[ "\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R") ]];then
        shift
    fi
fi

cmdline="proot \\
        --link2symlink \\
        -0 \\
        -r $CHROOT \\
        -b /dev \\
        -b /proc \\
        -b /sdcard \\
        -b $CHROOT\$home:/dev/shm \\
        -w \$home \\
           /usr/bin/env -i \\
           HOME=\$home \\
           PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin \\
           TERM=\$TERM \\
           LANG=C.UTF-8 \\
           \$start"

cmd="\$@"
if [ "\$#" == "0" ];then
    exec \$cmdline
else
    \$cmdline -c "\$cmd"
fi
EOF

    chmod 700 "$NH_LAUNCHER"
    if [ -L "${NH_SHORTCUT}" ]; then
        rm -f "${NH_SHORTCUT}"
    fi
    if [ ! -f "${NH_SHORTCUT}" ]; then
        ln -s "${NH_LAUNCHER}" "${NH_SHORTCUT}"
    fi
}

function create_kex_launcher() {
    KEX_LAUNCHER=${CHROOT}/usr/bin/kex
    cat > "$KEX_LAUNCHER" <<- EOF
#!/data/data/com.termux/files/usr/bin/bash
## Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
[ ! -f /dev/kvm ] && mknod /dev/kvm c 10 232

# Make the file executable
chmod +x $KEX_LAUNCHER
EOF
    chmod +x $KEX_LAUNCHER
}

function create_vnc_launcher() {
    VNC_LAUNCHER=${CHROOT}/usr/bin/vnc
    cat > "$VNC_LAUNCHER" <<- EOF
#!/data/data/com.termux/files/usr/bin/bash
## Workaround for termux-app issue #1283 (https://github.com/termux/termux-app/issues/1283)
[ ! -f /dev/kvm ] && mknod /dev/kvm c 10 232

# Make the file executable
chmod +x $VNC_LAUNCHER
EOF
    chmod +x $VNC_LAUNCHER
}

function create_developer_launcher() {
    DEV_LAUNCHER=${PREFIX}/bin/developer
    cat > "$DEV_LAUNCHER" <<- EOF
#!/data/data/com.termux/files/usr/bin/bash
## Developer Tools Launcher
start () {
    proot --link2symlink -0 -r $CHROOT -b /dev -b /proc -b /sdcard -b $CHROOT/home:/dev/shm -w /root /bin/bash
}
start
EOF
    chmod +x "$DEV_LAUNCHER"
}


#  MAIN

get_arch
set_strings
check_dependencies
get_rootfs
get_sha
verify_sha
extract_rootfs
create_launcher
create_kex_launcher
create_vnc_launcher
create_developer_launcher

