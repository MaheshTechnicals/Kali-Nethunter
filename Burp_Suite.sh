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
    # Check if Java is installed and its version
    if command -v java &> /dev/null; then
        # Get the current Java version
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        
        # Get major version number
        JAVA_MAJOR_VERSION=$(echo "$JAVA_VERSION" | awk -F. '{print $1}')
        
        # Check if the version is less than 23
        if [[ "$JAVA_MAJOR_VERSION" -lt 23 ]]; then
            echo "Java version $JAVA_VERSION is installed but is lower than Java 23. Uninstalling old Java version..."
            
            # Uninstall older Java versions
            if [ -f /etc/debian_version ]; then
                # For Debian/Ubuntu-based distributions
                apt remove -y openjdk-*
            elif [ -f /etc/redhat-release ]; then
                # For Red Hat/CentOS/Fedora-based distributions
                if command -v dnf &> /dev/null; then
                    # Fedora, RHEL 8+, CentOS 8+
                    dnf remove -y java-*
                elif command -v yum &> /dev/null; then
                    # Older CentOS/RHEL
                    yum remove -y java-*
                fi
            elif [ -f /etc/os-release ] && grep -q "openSUSE" /etc/os-release; then
                # For openSUSE
                zypper remove -y java-*
            else
                echo "Unsupported Linux distribution. Please uninstall Java manually."
                exit 1
            fi
        else
            echo "Java version $JAVA_VERSION is already installed and meets the minimum requirement."
        fi
    else
        echo "Java is not installed. Installing Java 23..."
    fi

    # Detect system architecture
    ARCH=$(uname -m)
    
    if [[ "$ARCH" == "x86_64" ]]; then
        # For 64-bit architecture (x86_64)
        JAVA_PACKAGE="openjdk-23.0.1_linux-x64_bin.tar.gz"
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/$JAVA_PACKAGE"
    elif [[ "$ARCH" == "aarch64" ]]; then
        # For ARM 64-bit architecture (aarch64)
        JAVA_PACKAGE="openjdk-23.0.1_linux-aarch64_bin.tar.gz"
        JAVA_URL="https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/$JAVA_PACKAGE"
    else
        echo "Unsupported architecture: $ARCH"
        exit 1
    fi

    # Download the appropriate Java 23 package based on architecture
    echo "Downloading Java 23 for $ARCH..."
    cd /tmp
    wget "$JAVA_URL"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download OpenJDK 23."
        exit 1
    fi

    # Extract the JDK package
    echo "Extracting Java 23..."
    tar -xvzf "$JAVA_PACKAGE"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to extract OpenJDK 23."
        exit 1
    fi

    # Move extracted directory (it may have a different name, ensure it's correct)
    JDK_DIR=$(ls -d /tmp/jdk-*/)
    mv "$JDK_DIR" /opt/

    # Remove old symbolic links if they exist
    echo "Removing existing symbolic links for java and javac..."
    rm -f /usr/bin/java
    rm -f /usr/bin/javac

    # Create symbolic links for java and javac
    ln -s /opt/jdk-23/bin/java /usr/bin/java
    ln -s /opt/jdk-23/bin/javac /usr/bin/javac

    # Verify Java installation
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo "Java version $JAVA_VERSION has been successfully installed."

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

