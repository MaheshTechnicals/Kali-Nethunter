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
    echo -e "${G}     A modded GUI version for Kali Linux\n"
}

note() {
    banner
    echo -e " ${G} [-] Successfully Installed !\n"${W}
    sleep 1
    cat <<- EOF
         ${G}[-] Type ${C}vncstart${G} to run Vncserver.
         ${G}[-] Type ${C}vncstop${G} to stop Vncserver.

         ${C}Install VNC VIEWER Apk on your Device.

         ${C}Open VNC VIEWER & Click on + Button.

         ${C}Enter the Address localhost:1 & Name anything you like.

         ${C}Set the Picture Quality to High for better Quality.

         ${C}Click on Connect & Input the Password.

         ${C}Enjoy :D${W}
    EOF
}

package() {
    banner
    echo -e "${R} [${W}-${R}]${C} Checking required packages..."${W}
    apt-get update -y
    apt install udisks2 -y
    rm /var/lib/dpkg/info/udisks2.postinst
    echo "" > /var/lib/dpkg/info/udisks2.postinst
    dpkg --configure -a
    apt-mark hold udisks2
    
    packs=(sudo gnupg2 curl nano git xz-utils at-spi2-core xfce4 xfce4-goodies xfce4-terminal librsvg2-common menu inetutils-tools dialog exo-utils tigervnc-standalone-server tigervnc-common tigervnc-tools dbus-x11 fonts-beng fonts-beng-extra gtk2-engines-murrine gtk2-engines-pixbuf apt-transport-https kali-archive-keyring)
    for hulu in "${packs[@]}"; do
        type -p "$hulu" &>/dev/null || {
            echo -e "\n${R} [${W}-${R}]${G} Installing package : ${Y}$hulu${W}"
            apt-get install "$hulu" -y --no-install-recommends
        }
    done
    
    apt-get update -y
    apt-get upgrade -y
}

install_kali_linux() {
    banner
    echo -e "${G}Starting Kali Linux installation process..."

    # Updating the system and installing Kali Linux repositories
    apt update -y
    apt upgrade -y
    apt dist-upgrade -y

    # Set up Kali Linux repositories if not already done
    if ! grep -q "kali-rolling" /etc/apt/sources.list; then
        echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" >> /etc/apt/sources.list
    fi

    # Install Kali Linux tools
    echo -e "${G}Installing Kali Linux tools..."

    kali_tools=(
        kali-linux-top10 kali-tools-web kali-tools-pentesting kali-tools-wireless kali-tools-forensics
        kali-tools-exploitation kali-tools-vulnerability kali-tools-information-gathering
    )

    for tool in "${kali_tools[@]}"; do
        echo -e "${Y}Installing ${tool}..."
        apt install -y $tool
    done
}

install_apt() {
    for apt in "$@"; do
        [[ `command -v $apt` ]] && echo "${Y}${apt} is already Installed!${W}" || {
            echo -e "${G}Installing ${Y}${apt}${W}"
            apt install -y ${apt}
        }
    done
}

install_vscode() {
    [[ $(command -v code) ]] && echo "${Y}VSCode is already Installed!${W}" || {
        echo -e "${G}Installing ${Y}VSCode${W}"
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
        apt update -y
        apt install code -y
        echo "Patching.."
        curl -fsSL https://raw.githubusercontent.com/modded-ubuntu/modded-ubuntu/master/patches/code.desktop > /usr/share/applications/code.desktop
        echo -e "${C} Visual Studio Code Installed Successfully\n${W}"
    }
}

install_sublime() {
    [[ $(command -v subl) ]] && echo "${Y}Sublime is already Installed!${W}" || {
        apt install gnupg2 software-properties-common --no-install-recommends -y
        echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
        curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/sublime.gpg 2> /dev/null
        apt update -y
        apt install sublime-text -y 
        echo -e "${C} Sublime Text Editor Installed Successfully\n${W}"
    }
}

install_chromium() {
    [[ $(command -v chromium) ]] && echo "${Y}Chromium is already Installed!${W}\n" || {
        echo -e "${G}Installing ${Y}Chromium${W}"
        apt purge chromium* chromium-browser* snapd -y
        apt install gnupg2 software-properties-common --no-install-recommends -y
        echo -e "deb http://ftp.debian.org/debian buster main\ndeb http://ftp.debian.org/debian buster-updates main" >> /etc/apt/sources.list
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DCC9EFBF77E11517
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA8E81B4331F7F50
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 112695A0E562B32A
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32
        apt update -y
        apt install chromium -y
        sed -i 's/chromium %U/chromium --no-sandbox %U/g' /usr/share/applications/chromium.desktop
        echo -e "${G} Chromium Installed Successfully\n${W}"
    }
}

install_firefox() {
    [[ $(command -v firefox) ]] && echo "${Y}Firefox is already Installed!${W}\n" || {
        echo -e "${G}Installing ${Y}Firefox${W}"
        bash <(curl -fsSL "https://raw.githubusercontent.com/modded-ubuntu/modded-ubuntu/master/distro/firefox.sh")
        echo -e "${G} Firefox Installed Successfully\n${W}"
    }
}

install_softwares() {
    banner
    cat <<- EOF
        ${Y} ---${G} Select Browser ${Y}---

        ${C} [${W}1${C}] Firefox (Default)
        ${C} [${W}2${C}] Chromium
        ${C} [${W}3${C}] Both (Firefox + Chromium)

    EOF
    read -n1 -p "${R} [${G}~${R}]${Y} Select an Option: ${G}" BROWSER_OPTION
    banner

    [[ ("$arch" != 'armhf') || ("$arch" != *'armv7'*) ]] && {
        cat <<- EOF
            ${Y} ---${G} Select IDE ${Y}---

            ${C} [${W}1${C}] Sublime Text Editor (Recommended)
            ${C} [${W}2${C}] VSCode
            ${C} [${W}3${C}] Both (Sublime + VSCode)
            ${C} [${W}4${C}] Skip! (Default)

        EOF
        read -n1 -p "${R} [${G}~${R}]${Y} Select an Option: ${G}" IDE_OPTION
    }

    cat <<- EOF
        ${Y} ---${G} Select Media Player ${Y}---

        ${C} [${W}1${C}] MPV
        ${C} [${W}2${C}] VLC
        ${C} [${W}3${C}] Both (MPV + VLC)
        ${C} [${W}4${C}] Skip! (Default)

    EOF
    read -n1 -p "${R} [${G}~${R}]${Y} Select an Option: ${G}" MEDIA_PLAYER_OPTION
    banner

    case $BROWSER_OPTION in
        1) install_firefox ;;
        2) install_chromium ;;
        3) install_firefox; install_chromium ;;
    esac

    case $IDE_OPTION in
        1) install_sublime ;;
        2) install_vscode ;;
        3) install_sublime; install_vscode ;;
        4) echo -e "${R}Skipping IDE installation.${W}" ;;
    esac

    case $MEDIA_PLAYER_OPTION in
        1) install_apt mpv ;;
        2) install_apt vlc ;;
        3) install_apt mpv vlc ;;
        4) echo -e "${R}Skipping Media Player installation.${W}" ;;
    esac

    note
}

# Run functions
check_root
package
install_kali_linux
install_softwares

