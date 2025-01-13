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

# Function to check Java version
check_java_version() {
    if command -v java >/dev/null 2>&1; then
        # Get Java version
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
        
        # Check if version is 23 or higher
        if [ -n "$java_version" ] && [ "$java_version" -ge 23 ]; then
            return 0  # Java 23 or higher is installed
        fi
    fi
    return 1  # Java not installed or version < 23
}

# Function to install Java 23
install_java() {
    print_title "Checking Java Installation..."

    if check_java_version; then
        echo -e "${GREEN}Java 23 or higher is already installed.${RESET}"
        java -version
        return 0
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

    # Download Java
    echo -e "${YELLOW}Downloading Java from $JAVA_URL...${RESET}"
    wget "$JAVA_URL" -O openjdk-23.tar.gz --progress=bar
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to download Java.${RESET}"
        exit 1
    fi

    # Create /usr/lib/jvm directory if it doesn't exist
    echo -e "${CYAN}Creating /usr/lib/jvm directory...${RESET}"
    sudo mkdir -p /usr/lib/jvm

    # Extract Java
    echo -e "${CYAN}Extracting Java...${RESET}"
    sudo tar -xzf openjdk-23.tar.gz -C /usr/lib/jvm
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error: Failed to extract Java.${RESET}"
        exit 1
    fi

    # Find the extracted Java directory
    JAVA_DIR=$(tar -tf openjdk-23.tar.gz | head -n 1 | cut -f1 -d"/")
    JAVA_PATH="/usr/lib/jvm/$JAVA_DIR"

    # Set up Java alternatives
    echo -e "${CYAN}Setting up Java alternatives...${RESET}"
    sudo update-alternatives --install /usr/bin/java java "$JAVA_PATH/bin/java" 1
    sudo update-alternatives --set java "$JAVA_PATH/bin/java"

    # Clean up
    rm -f openjdk-23.tar.gz
    echo -e "${GREEN}Java 23 has been installed successfully!${RESET}"

    # Display installed Java version
    java -version
}

# Function to fetch the latest PyCharm version and construct the download URL
get_latest_pycharm_url() {
    local BASE_URL="https://download.jetbrains.com/python/pycharm-community-"
    print_title "Fetching Latest PyCharm Version"

    # Check if curl is installed
    if ! command -v curl &>/dev/null; then
        echo -e "${RED}Curl not installed! Please install curl and try again.${RESET}"
        exit 1
    fi

    # Fetch the latest version information
    echo -e "${CYAN}Fetching version info from JetBrains...${RESET}"
    local response=$(curl -s "https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release")
    local version=$(echo "$response" | grep -o '"version":"[^"]*"' | head -n 1 | cut -d'"' -f4)

    if [ -z "$version" ]; then
        echo -e "${RED}Failed to fetch the latest version. Exiting.${RESET}"
        exit 1
    fi

    echo -e "${GREEN}Latest PyCharm version: $version${RESET}"
    echo "${BASE_URL}${version}.tar.gz"
}

