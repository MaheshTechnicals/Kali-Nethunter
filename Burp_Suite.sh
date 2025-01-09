#!/bin/bash

echo "
              #######  ######  ###########
              ###  ##  ## ###  ###########
              ###  ###### ###       ##
              ###         ###       ##
              ###         ###       ##
              ###         ###       ##

        ################################################
         Burp Suite Installer By Mahesh Technicals
        ################################################
"

# Check if script is run as root
if [[ $EUID -eq 0 ]]; then
    # Check if java is installed
    if ! command -v java &> /dev/null; then
        echo "Java is not installed. Installing Java 17..."

        # Detect Linux distribution and install Java accordingly
        if [ -f /etc/debian_version ]; then
            # For Debian/Ubuntu-based distributions
            apt update && apt install -y openjdk-17-jre
        elif [ -f /etc/redhat-release ]; then
            # For Red Hat/CentOS/Fedora-based distributions
            if command -v dnf &> /dev/null; then
                # Fedora, RHEL 8+, CentOS 8+
                dnf install -y java-17-openjdk
            elif command -v yum &> /dev/null; then
                # Older CentOS/RHEL
                yum install -y java-17-openjdk
            fi
        elif [ -f /etc/os-release ] && grep -q "openSUSE" /etc/os-release; then
            # For openSUSE
            zypper install -y java-17-openjdk
        else
            echo "Unsupported Linux distribution. Please install Java manually."
            exit 1
        fi

        # Verify Java installation
        if ! command -v java &> /dev/null; then
            echo "Error: Java installation failed."
            exit 1
        else
            echo "Java 17 has been successfully installed."
        fi
    else
        echo "Java is already installed."
    fi

    # Check if wget is installed
    if ! command -v wget &> /dev/null; then
        echo "Error: wget is not installed. Please install wget first."
        exit 1
    fi

    # Download Burp Suite Community Latest Version
    echo 'Downloading Burp Suite Community...'
    Link="https://portswigger-cdn.net/burp/releases/download?product=community&type=jar"
    wget "$Link" -O Burp.jar --progress=bar
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download Burp Suite."
        exit 1
    fi
    sleep 2

    # Create directory for Burp Suite if it does not exist
    BURP_DIR="/root/Burp_Suite"
    if [ ! -d "$BURP_DIR" ]; then
        echo "Creating directory for Burp Suite..."
        mkdir "$BURP_DIR"
    fi

    # Move the downloaded file to the directory
    echo "Moving Burp Suite to $BURP_DIR..."
    mv Burp.jar "$BURP_DIR/"
    
    # Create a launcher script
    echo "Creating Burp Suite launcher..."
    echo "java -jar $BURP_DIR/Burp.jar" > /usr/bin/burp
    chmod +x /usr/bin/burp

    # Launch Burp Suite
    echo "Opening Burp Suite..."
    burp

else
    echo "Error: Please execute the command as a root user."
    exit 1
fi

