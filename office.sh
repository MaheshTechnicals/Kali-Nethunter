#!/bin/bash

# Clear the screen
clear

# Stylish Banner
echo -e "\033[1;35m" # Purple text
echo "=========================================================="
echo -e "\033[1;36m" # Cyan text
printf "%*s\n" $(((${#'LibreOffice Installer Script by Mahesh Technicals'}+55)/2)) "✨ LibreOffice Installer Script by Mahesh Technicals ✨"
echo -e "\033[1;35m" # Purple text
echo "=========================================================="
echo -e "\033[0m" # Reset formatting

# Main Menu
echo -e "\033[1;33m💻 Select an option:\033[0m" # Yellow
echo -e "\033[1;32m1. Install LibreOffice\033[0m" # Green
echo -e "\033[1;31m2. Uninstall LibreOffice\033[0m" # Red
echo -e "\033[1;36m" # Cyan text
read -p "👉 Enter your choice (1 or 2): " choice
echo -e "\033[0m" # Reset text formatting

# Function to check architecture
check_architecture() {
  echo -e "\033[1;34m🔍 Checking system architecture...\033[0m"
  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" ]]; then
    echo -e "\033[1;32m✅ Architecture detected: 64-bit.\033[0m"
    ARCH="x86_64"
  elif [[ "$ARCH" == "i386" || "$ARCH" == "i686" ]]; then
    echo -e "\033[1;32m✅ Architecture detected: 32-bit.\033[0m"
    ARCH="x86"
  elif [[ "$ARCH" == "aarch64" ]]; then
    echo -e "\033[1;32m✅ Architecture detected: ARM 64-bit (aarch64).\033[0m"
    ARCH="aarch64"
  else
    echo -e "\033[1;31m❌ Unsupported architecture: $ARCH\033[0m"
    exit 1
  fi
}

# Function to install dependencies
install_dependencies() {
  echo -e "\033[1;36m🔧 Installing dependencies...\033[0m"
  sudo apt update
  sudo apt install -y wget tar gdebi libxinerama1 libglu1-mesa libxrender1
  echo -e "\033[1;32m✅ Dependencies installed successfully.\033[0m"
}

# Function to download and install LibreOffice
install_libreoffice() {
  echo -e "\033[1;33m📥 Starting LibreOffice Installation...\033[0m"
  check_architecture
  install_dependencies

  echo -e "\033[1;34m🌐 Fetching the latest LibreOffice version...\033[0m"
  LIBRE_URL=$(wget -qO- https://www.libreoffice.org/download/download/ | grep -oP "https://.*LibreOffice_.*Linux_$ARCH\.deb\.tar\.gz" | head -n 1)
  if [[ -z "$LIBRE_URL" ]]; then
    echo -e "\033[1;31m❌ Unable to fetch the LibreOffice download link.\033[0m"
    exit 1
  fi
  wget -c "$LIBRE_URL" -O LibreOffice.tar.gz
  echo -e "\033[1;32m✅ LibreOffice archive downloaded.\033[0m"

  echo -e "\033[1;36m📂 Extracting files...\033[0m"
  tar -xzf LibreOffice.tar.gz
  LIBRE_FOLDER=$(tar -tf LibreOffice.tar.gz | head -n 1 | cut -d'/' -f1)
  cd "$LIBRE_FOLDER"/DEBS || exit
  echo -e "\033[1;34m🚀 Installing LibreOffice packages...\033[0m"
  sudo gdebi --non-interactive *.deb
  echo -e "\033[1;32m✅ LibreOffice installed successfully.\033[0m"

  # Add desktop entries
  echo -e "\033[1;36m📋 Adding desktop entries...\033[0m"
  sudo cp /usr/share/applications/libreoffice*.desktop ~/.local/share/applications/
  echo -e "\033[1;32m✅ Desktop entries added successfully.\033[0m"

  # Cleanup
  cd ../..
  rm -rf LibreOffice.tar.gz "$LIBRE_FOLDER"
  echo -e "\033[1;32m🎉 Installation completed! Enjoy LibreOffice!\033[0m"
}

# Function to uninstall LibreOffice
uninstall_libreoffice() {
  echo -e "\033[1;31m🗑️ Uninstalling LibreOffice...\033[0m"
  sudo apt remove --purge -y libreoffice* && sudo apt autoremove -y
  echo -e "\033[1;32m✅ LibreOffice uninstalled successfully.\033[0m"
}

# Handle user choice
case $choice in
  1)
    install_libreoffice
    ;;
  2)
    uninstall_libreoffice
    ;;
  *)
    echo -e "\033[1;31m❌ Invalid choice. Exiting.\033[0m"
    ;;
esac

