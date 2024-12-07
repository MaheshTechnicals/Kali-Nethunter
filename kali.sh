#!/data/data/com.termux/files/usr/bin/bash -e

VERSION=2024091801
BASE_URL=https://kali.download/nethunter-images/current/rootfs
USERNAME=kali

function unsupported_arch() {
    echo "[*] Unsupported Architecture"
    exit 1
}

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

        read -p "$1 [$prompt] " REPLY
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

function get_arch() {
    echo "[*] Checking device architecture..."
    case $(getprop ro.product.cpu.abi) in
        arm64-v8a) SYS_ARCH=arm64 ;;
        armeabi|armeabi-v7a) SYS_ARCH=armhf ;;
        *) unsupported_arch ;;
    esac
}

function set_strings() {
    echo ""
    if [[ ${SYS_ARCH} == "arm64" ]]; then
        echo "[1] NetHunter ARM64 (full)"
        echo "[2] NetHunter ARM64 (minimal)"
        echo "[3] NetHunter ARM64 (nano)"
        read -p "Enter the image you want to install: " wimg
        case $wimg in
            1) wimg="full" ;;
            2) wimg="minimal" ;;
            3) wimg="nano" ;;
            *) wimg="full" ;;
        esac
    elif [[ ${SYS_ARCH} == "armhf" ]]; then
        echo "[1] NetHunter ARMhf (full)"
        echo "[2] NetHunter ARMhf (minimal)"
        echo "[3] NetHunter ARMhf (nano)"
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

function prepare_fs() {
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
            rm -f "${IMAGE_NAME}" "${SHA_NAME}"
        fi
    fi
}

function check_dependencies() {
    echo "[*] Checking package dependencies..."
    apt-get update -y > /dev/null || apt-get dist-upgrade -y > /dev/null

    for i in proot tar wget; do
        if ! command -v $i &> /dev/null; then
            echo "Installing $i..."
            apt install -y $i || { echo "Failed to install $i. Exiting."; exit 1; }
        fi
    done
    apt upgrade -y
}

function get_url() {
    ROOTFS_URL="${BASE_URL}/${IMAGE_NAME}"
    SHA_URL="${BASE_URL}/${SHA_NAME}"
}

function get_rootfs() {
    if [ ! -f "${IMAGE_NAME}" ]; then
        echo "[*] Downloading rootfs..."
        get_url
        wget --continue "${ROOTFS_URL}"
    fi
}

function get_sha() {
    if [ ! -f "${SHA_NAME}" ]; then
        echo "[*] Downloading SHA..."
        get_url
        wget --continue "${SHA_URL}"
    fi
}

function verify_sha() {
    echo "[*] Verifying integrity of rootfs..."
    sha512sum -c "${SHA_NAME}" || { echo "Rootfs verification failed. Exiting."; exit 1; }
}

function extract_rootfs() {
    if [ -z "${KEEP_CHROOT}" ]; then
        echo "[*] Extracting rootfs..."
        proot --link2symlink tar -xf "${IMAGE_NAME}" 2> /dev/null || :
    else
        echo "[!] Using existing rootfs directory"
    fi
}

function create_launcher() {
    NH_LAUNCHER=${PREFIX}/bin/nethunter
    NH_SHORTCUT=${PREFIX}/bin/nh

    cat > "${NH_LAUNCHER}" <<- EOF
#!/data/data/com.termux/files/usr/bin/bash -e
cd \${HOME}
unset LD_PRELOAD

user="${USERNAME}"
home="/home/\$user"
start="sudo -u kali /bin/bash"

if grep -q "kali" ${CHROOT}/etc/passwd; then
    KALIUSR="1";
else
    KALIUSR="0";
fi
if [[ \$KALIUSR == "0" || ("\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R")) ]]; then
    user="root"
    home="/\$user"
    start="/bin/bash --login"
    if [[ "\$#" != "0" && ("\$1" == "-r" || "\$1" == "-R") ]]; then
        shift
    fi
fi

cmdline="proot --link2symlink -0 -r $CHROOT -b /dev -b /proc -b /sdcard -b $CHROOT\$home:/dev/shm -w \$home /usr/bin/env -i HOME=\$home PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin TERM=\$TERM LANG=C.UTF-8 \$start"

if [ "\$#" == "0" ]; then
    exec \$cmdline
else
    \$cmdline -c "\$@"
fi
EOF

    chmod 700 "${NH_LAUNCHER}"
    ln -sf "${NH_LAUNCHER}" "${NH_SHORTCUT}"
}

get_arch
set_strings
prepare_fs
check_dependencies
get_rootfs
get_sha
verify_sha
extract_rootfs
create_launcher
cleanup

echo "NetHunter installation complete!"
