
#!/bin/bash

#===============================#
#        PyCharm Installer      #
#   Script by MaheshTechnicals  #
#===============================#

# Define colors for the UI
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

# Stylish header
echo -e "${CYAN}"
echo "############################################################"
echo "#                    PyCharm Installer                     #"
echo "#               Author: MaheshTechnicals                  #"
echo "############################################################"
echo -e "${RESET}"

# Function to print a title
print_title() {
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
    echo -e "${CYAN}$1${RESET}"
    echo -e "${YELLOW}------------------------------------------------------------${RESET}"
}

# Function to check if Java 23 or higher is installed
check_java_version() {
    print_title "Checking Java Installation..."
    if command -v java >/dev/null 2>&1; then
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        major_version=$(echo "$java_version" | cut -d'.' -f1)
        if [[ "$major_version" -ge 23 ]]; then
            echo -e "${GREEN}Java version $java_version detected. Skipping Java installation.${RESET}"
            return 0
        fi
    fi
    echo -e "${YELLOW}Java 23 or higher not found. Proceeding with installation...${RESET}"
    return 1
}

# Function to install Java 23
install_java() {
    if check_java_version; then
        return  # Skip installation if Java 23+ is already installed
    fi

    print_title "Installing Java 23..."

    # Check system architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-x64_bin.tar.gz"
    elif [[ "$ARCH" == "aarch64" ]]; then
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-aarch64_bin.tar.gz"
    else
        echo -e "${RED}Unsupported architecture: $ARCH. Exiting...${RESET}"
        exit 1
    fi

    # Download and install Java
    echo -e "${YELLOW}Downloading Java from $JAVA_URL...${RESET}"
    wget "$JAVA_URL" -O openjdk-23.tar.gz --progress=bar
    sudo mkdir -p /usr/lib/jvm
    sudo tar -xzf openjdk-23.tar.gz -C /usr/lib/jvm
    JAVA_DIR=$(tar -tf openjdk-23.tar.gz | head -n 1 | cut -f1 -d"/")
    JAVA_PATH="/usr/lib/jvm/$JAVA_DIR"
    sudo update-alternatives --install /usr/bin/java java "$JAVA_PATH/bin/java" 1
    sudo update-alternatives --set java "$JAVA_PATH/bin/java"
    rm -f openjdk-23.tar.gz
    echo -e "${GREEN}Java 23 installed successfully!${RESET}"
}

# Function to fetch the latest PyCharm version from the website
get_latest_pycharm_version() {
    print_title "Fetching Latest PyCharm Version..."
    latest_version=$(curl -s https://data.services.jetbrains.com/products/releases?code=PCC | grep -oP '(?<="version":")[^"]*' | head -n 1)
    if [[ -z "$latest_version" ]]; then
        echo -e "${RED}Error: Unable to fetch the latest PyCharm version.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}Latest PyCharm Version: $latest_version${RESET}"
    echo "$latest_version"
}

# Function to detect architecture and build PyCharm download URL
get_pycharm_url() {
    local base_url="https://download.jetbrains.com/python"
    local version=$1
    local arch=$(uname -m)

    case "$arch" in
        x86_64)
            echo "$base_url/pycharm-community-${version}.tar.gz"
            ;;
        aarch64)
            echo "$base_url/pycharm-community-${version}-aarch64.tar.gz"
            ;;
        *)
            echo -e "${RED}Unsupported architecture: $arch. Exiting...${RESET}"
            exit 1
            ;;
    esac
}

# Function to install PyCharm
install_pycharm() {
    install_java  # Call Java installation function

    # Fetch the latest version of PyCharm
    local latest_version
    latest_version=$(get_latest_pycharm_version)

    # Build the download URL based on architecture
    local pycharm_url
    pycharm_url=$(get_pycharm_url "$latest_version")

    local pycharm_tar="pycharm.tar.gz"
    local install_dir="/opt/pycharm"

    print_title "Downloading PyCharm"
    wget "$pycharm_url" -O "$pycharm_tar"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Download failed! Exiting...${RESET}"
        exit 1
    fi

    print_title "Extracting PyCharm"
    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"
    sudo tar -xzf "$pycharm_tar" -C "$install_dir" --strip-components=1
    rm -f "$pycharm_tar"

    print_title "Creating Symbolic Link"
    sudo ln -sf "$install_dir/bin/pycharm.sh" /usr/local/bin/pycharm

    print_title "Creating Desktop Entry"
    cat << EOF | sudo tee /usr/share/applications/pycharm.desktop > /dev/null
[Desktop Entry]
Name=PyCharm
Comment=Integrated Development Environment for Python
Exec=$install_dir/bin/pycharm.sh %f
Icon=$install_dir/bin/pycharm.png
Terminal=false
Type=Application
Categories=Development;IDE;
StartupNotify=true
EOF

    echo -e "${GREEN}PyCharm has been installed successfully!${RESET}"
}

# Function to uninstall PyCharm
uninstall_pycharm() {
    local install_dir="/opt/pycharm"

    print_title "Removing PyCharm Installation"
    sudo rm -rf "$install_dir"

    print_title "Removing Symbolic Link"
    sudo rm -f /usr/local/bin/pycharm

    print_title "Removing Desktop Entry"
    sudo rm -f /usr/share/applications/pycharm.desktop

    echo -e "${GREEN}PyCharm has been uninstalled successfully!${RESET}"
}

# Display menu
while true; do
    clear
    echo -e "${CYAN}############################################################${RESET}"
    echo -e "${CYAN}#                    PyCharm Installer                     #${RESET}"
    echo -e "${CYAN}#               Author: MaheshTechnicals                  #${RESET}"
    echo -e "${CYAN}############################################################${RESET}"
    echo -e "${YELLOW}1. Install PyCharm${RESET}"
    echo -e "${YELLOW}2. Uninstall PyCharm${RESET}"
    echo -e "${YELLOW}3. Exit${RESET}"
    echo -n -e "${CYAN}Enter your choice: ${RESET}"
    read -r choice

    case $choice in
        1)
            install_pycharm
            read -r -p "Press any key to continue..."
            ;;
        2)
            uninstall_pycharm
            read -r -p "Press any key to continue..."
            ;;
        3)
            echo -e "${YELLOW}Exiting. Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${RESET}"
            ;;
    esac
done
