#!/bin/bash

# Function to check the architecture
check_architecture() {
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        echo "Architecture: 64-bit (x86_64)"
        INSTALL_METHOD="download"
    elif [[ "$ARCH" == "i686" || "$ARCH" == "i386" ]]; then
        echo "Architecture: 32-bit (x86)"
        INSTALL_METHOD="download"
    elif [[ "$ARCH" == "aarch64" ]]; then
        echo "Architecture: 64-bit (ARM - aarch64)"
        INSTALL_METHOD="package_manager"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
}

# Function to install LibreOffice via package manager
install_via_package_manager() {
    echo "Updating package list..."
    sudo apt update

    echo "Installing LibreOffice with dependencies..."
    sudo apt install -y libreoffice libreoffice-gtk3 libreoffice-style-breeze
    if [[ $? -ne 0 ]]; then
        echo "Failed to install LibreOffice. Please check your system."
        exit 1
    fi

    echo "LibreOffice has been installed successfully with desktop entries via the package manager."
}

# Function to download and install LibreOffice for x86/x64
install_libreoffice_x86() {
    echo "Fetching the latest LibreOffice version..."
    LATEST_URL=$(curl -s https://www.libreoffice.org/download/download/ | grep -oP 'https://download.documentfoundation.org/libreoffice/stable/\d+\.\d+(\.\d+)?/deb/\K.*?(?=")')
    if [[ -z "$LATEST_URL" ]]; then
        echo "Failed to fetch the latest LibreOffice version."
        exit 1
    fi

    FULL_URL="https://download.documentfoundation.org/libreoffice/stable/$LATEST_URL"
    PACKAGE_NAME=$(basename "$FULL_URL")

    echo "Downloading LibreOffice: $PACKAGE_NAME"
    wget "$FULL_URL" -O "$PACKAGE_NAME"
    if [[ $? -ne 0 ]]; then
        echo "Download failed."
        exit 1
    fi

    echo "Extracting package..."
    tar -xvf "$PACKAGE_NAME" >/dev/null
    INSTALL_DIR=$(basename "$PACKAGE_NAME" .tar.gz)

    echo "Installing LibreOffice..."
    cd "$INSTALL_DIR"/DEBS || exit 1
    sudo dpkg -i *.deb
    if [[ $? -ne 0 ]]; then
        echo "Installation failed. Attempting to fix broken dependencies..."
        sudo apt install -f -y
        sudo dpkg -i *.deb
        if [[ $? -ne 0 ]]; then
            echo "Failed to install LibreOffice. Please check your system."
            exit 1
        fi
    fi

    echo "LibreOffice has been installed successfully with desktop entries."
    echo "Cleaning up..."
    cd ../..
    rm -rf "$PACKAGE_NAME" "$INSTALL_DIR"
}

# Function to verify desktop entries
verify_desktop_entries() {
    echo "Verifying desktop entries for LibreOffice..."
    DESKTOP_ENTRY_DIR="/usr/share/applications"

    if [[ -d "$DESKTOP_ENTRY_DIR" ]]; then
        ls "$DESKTOP_ENTRY_DIR" | grep libreoffice
        if [[ $? -eq 0 ]]; then
            echo "Desktop entries are installed successfully."
        else
            echo "Desktop entries are missing. Please check the installation."
        fi
    else
        echo "Desktop entry directory not found. Please check your system."
    fi
}

# Main script
check_architecture

if [[ "$INSTALL_METHOD" == "package_manager" ]]; then
    install_via_package_manager
else
    install_libreoffice_x86
fi

verify_desktop_entries
