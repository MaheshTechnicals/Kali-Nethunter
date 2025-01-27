#!/bin/bash

# Function to display the header
display_header() {
    echo -e "\e[1;44;97m==============================================================\e[0m"
    echo -e "\e[1;44;97m            LibreOffice Installer Script by Mahesh Technicals          \e[0m"
    echo -e "\e[1;44;97m==============================================================\e[0m"
}

# Function to display section headings
display_section() {
    echo -e "\e[1;42;97m>>> $1 <<<\e[0m"
}

# Function to check the architecture
check_architecture() {
    display_section "Checking System Architecture"
    ARCH=$(uname -m)
    echo -e "\e[1;34mDetected Architecture: \e[1;32m$ARCH\e[0m"
    if [[ "$ARCH" == "x86_64" ]]; then
        INSTALL_METHOD="download"
    elif [[ "$ARCH" == "i686" || "$ARCH" == "i386" ]]; then
        INSTALL_METHOD="download"
    elif [[ "$ARCH" == "aarch64" ]]; then
        INSTALL_METHOD="package_manager"
    else
        echo -e "\e[1;31mUnsupported architecture: $ARCH\e[0m"
        exit 1
    fi
}

# Function to install LibreOffice via package manager
install_via_package_manager() {
    display_section "Installing LibreOffice via Package Manager"
    echo -e "\e[1;34mUpdating package list...\e[0m"
    sudo apt update

    echo -e "\e[1;34mInstalling LibreOffice and dependencies...\e[0m"
    sudo apt install -y libreoffice libreoffice-gtk3 libreoffice-style-breeze
    if [[ $? -ne 0 ]]; then
        echo -e "\e[1;31mFailed to install LibreOffice. Please check your system.\e[0m"
        exit 1
    fi

    echo -e "\e[1;32mLibreOffice has been installed successfully with desktop entries.\e[0m"
}

# Function to download and install LibreOffice for x86/x64
install_libreoffice_x86() {
    display_section "Downloading and Installing LibreOffice for x86/x64"
    echo -e "\e[1;34mFetching the latest LibreOffice version...\e[0m"
    LATEST_URL=$(curl -s https://www.libreoffice.org/download/download/ | grep -oP 'https://download.documentfoundation.org/libreoffice/stable/\d+\.\d+(\.\d+)?/deb/\K.*?(?=")')
    if [[ -z "$LATEST_URL" ]]; then
        echo -e "\e[1;31mFailed to fetch the latest LibreOffice version.\e[0m"
        exit 1
    fi

    FULL_URL="https://download.documentfoundation.org/libreoffice/stable/$LATEST_URL"
    PACKAGE_NAME=$(basename "$FULL_URL")

    echo -e "\e[1;34mDownloading LibreOffice: \e[1;32m$PACKAGE_NAME\e[0m"
    wget "$FULL_URL" -O "$PACKAGE_NAME"
    if [[ $? -ne 0 ]]; then
        echo -e "\e[1;31mDownload failed.\e[0m"
        exit 1
    fi

    echo -e "\e[1;34mExtracting package...\e[0m"
    tar -xvf "$PACKAGE_NAME" >/dev/null
    INSTALL_DIR=$(basename "$PACKAGE_NAME" .tar.gz)

    echo -e "\e[1;34mInstalling LibreOffice...\e[0m"
    cd "$INSTALL_DIR"/DEBS || exit 1
    sudo dpkg -i *.deb
    if [[ $? -ne 0 ]]; then
        echo -e "\e[1;31mInstallation failed. Attempting to fix broken dependencies...\e[0m"
        sudo apt install -f -y
        sudo dpkg -i *.deb
        if [[ $? -ne 0 ]]; then
            echo -e "\e[1;31mFailed to install LibreOffice. Please check your system.\e[0m"
            exit 1
        fi
    fi

    echo -e "\e[1;32mLibreOffice has been installed successfully with desktop entries.\e[0m"
    echo -e "\e[1;34mCleaning up temporary files...\e[0m"
    cd ../..
    rm -rf "$PACKAGE_NAME" "$INSTALL_DIR"
}

# Function to uninstall LibreOffice
uninstall_libreoffice() {
    display_section "Uninstalling LibreOffice"
    echo -e "\e[1;34mRemoving LibreOffice...\e[0m"
    if [[ "$INSTALL_METHOD" == "package_manager" ]]; then
        sudo apt purge -y libreoffice*
        sudo apt autoremove -y
    else
        sudo dpkg --remove libreoffice* || echo -e "\e[1;33mNo manually installed LibreOffice components found.\e[0m"
    fi

    echo -e "\e[1;34mCleaning leftover files...\e[0m"
    sudo rm -rf /usr/lib/libreoffice
    sudo rm -rf /usr/share/applications/libreoffice*
    sudo rm -rf ~/.config/libreoffice

    echo -e "\e[1;32mLibreOffice has been uninstalled successfully.\e[0m"
}

# Function to verify desktop entries
verify_desktop_entries() {
    display_section "Verifying Desktop Entries"
    DESKTOP_ENTRY_DIR="/usr/share/applications"
    if [[ -d "$DESKTOP_ENTRY_DIR" ]]; then
        ls "$DESKTOP_ENTRY_DIR" | grep libreoffice
        if [[ $? -eq 0 ]]; then
            echo -e "\e[1;32mDesktop entries are installed successfully.\e[0m"
        else
            echo -e "\e[1;31mDesktop entries are missing. Please check the installation.\e[0m"
        fi
    else
        echo -e "\e[1;31mDesktop entry directory not found. Please check your system.\e[0m"
    fi
}

# Main script
clear
display_header

echo -e "\e[1;34mSelect an option:\e[0m"
echo -e "\e[1;33m1. Install LibreOffice\e[0m"
echo -e "\e[1;33m2. Uninstall LibreOffice\e[0m"
read -rp "Enter your choice (1 or 2): " CHOICE

check_architecture

if [[ "$CHOICE" -eq 1 ]]; then
    if [[ "$INSTALL_METHOD" == "package_manager" ]]; then
        install_via_package_manager
    else
        install_libreoffice_x86
    fi
    verify_desktop_entries
elif [[ "$CHOICE" -eq 2 ]]; then
    uninstall_libreoffice
else
    echo -e "\e[1;31mInvalid option. Exiting.\e[0m"
    exit 1
fi

