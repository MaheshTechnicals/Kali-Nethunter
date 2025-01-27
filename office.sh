#!/bin/bash

# Function to check the architecture
check_architecture() {
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        echo "Architecture: 64-bit (x86_64)"
        DOWNLOAD_ARCH="x86-64"
    elif [[ "$ARCH" == "i686" || "$ARCH" == "i386" ]]; then
        echo "Architecture: 32-bit (i386)"
        DOWNLOAD_ARCH="x86"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi
}

# Function to install required dependencies
install_dependencies() {
    echo "Updating package list and installing required dependencies..."
    sudo apt update
    sudo apt install -y libc6 libgcc1 libstdc++6 libgtk-3-0 libx11-xcb1 libglu1-mesa libsm6 libxrender1 libfontconfig1 libxinerama1 libxt6
    if [[ $? -ne 0 ]]; then
        echo "Failed to install dependencies. Please check your system and try again."
        exit 1
    fi
}

# Function to download and install LibreOffice
install_libreoffice() {
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

    echo "LibreOffice has been installed successfully."
    echo "Cleaning up..."
    cd ../..
    rm -rf "$PACKAGE_NAME" "$INSTALL_DIR"
}

# Main script
check_architecture
install_dependencies
install_libreoffice
