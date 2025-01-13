#!/bin/bash

# Function to print title with formatting
print_title() {
    echo -e "\n\033[1;36m$1\033[0m"
}

# Function to check and install Java (if needed)
install_java() {
    print_title "Checking for Java 23+ Installation..."

    # Check if Java 23 or higher is installed
    java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    java_major_version=$(echo "$java_version" | cut -d'.' -f1)

    if [[ "$java_major_version" -ge 23 ]]; then
        echo -e "\033[1;32mJava version $java_version is already installed. Skipping Java installation.\033[0m"
    else
        echo -e "\033[1;33mJava $java_version is installed, but not sufficient. Installing Java 23...\033[0m"
        sudo apt update
        sudo apt install -y openjdk-23-jdk
        echo -e "\033[1;32mJava 23 has been installed.\033[0m"
    fi
}

# Function to fetch the latest PyCharm version from the website
get_latest_pycharm_version() {
    print_title "Fetching Latest PyCharm Version..."
    latest_version=$(curl -s https://data.services.jetbrains.com/products/releases?code=PCC | grep -oP '(?<="version":")[^"]*' | head -n 1)
    if [[ -z "$latest_version" ]]; then
        echo -e "\033[1;31mError: Unable to fetch the latest PyCharm version.\033[0m"
        exit 1
    fi
    echo -e "\033[1;32mLatest PyCharm Version: $latest_version\033[0m"
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
            echo -e "\033[1;31mUnsupported architecture: $arch. Exiting...\033[0m"
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
        echo -e "\033[1;31mDownload failed! Exiting...\033[0m"
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

    echo -e "\033[1;32mPyCharm has been installed successfully!\033[0m"
}

# Start the PyCharm installation process
install_pycharm

