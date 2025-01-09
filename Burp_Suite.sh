#!/bin/bash

# Header
echo "
        ##############################################
        ##                                          ##
        ##      Burp Suite Installer by Mahesh      ##
        ##                                          ##
        ##############################################
"

# Check Java version
echo "Checking Java version..."

# Check Java version
java_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
echo -e "Java Version Installed: \033[1;32m$java_version\033[0m"

# Check if Java version is 17 or higher
required_version="17"
if [[ $(echo "$java_version >= $required_version" | bc) -eq 1 ]]; then
    echo -e "Java version is valid: \033[1;32m$java_version\033[0m"
else
    echo "Java version is lower than 17. Please install Java 17 or higher."
    exit 1
fi

# Show menu for installation options
echo -e "\n\033[1;34mSelect an option:\033[0m"
echo -e "\033[1;33m1. Install Burp Suite\033[0m"
echo -e "\033[1;31m2. Uninstall Burp Suite\033[0m"
echo -e "\033[1;32m3. Exit\033[0m"

read -p "Enter your choice: " choice

case $choice in
    1)
        echo -e "\n\033[1;34mInstalling Burp Suite...\033[0m"
        
        # Download Burp Suite
        echo "Downloading Burp Suite Community Edition..."
        Link="https://portswigger-cdn.net/burp/releases/download?product=community&type=jar"
        wget "$Link" -O Burp.jar --progress=bar
        sleep 2
        
        # Create directory and move the jar file
        echo "Setting up Burp Suite..."
        mkdir -p /root/Burp_Suite/
        mv Burp.jar /root/Burp_Suite/
        
        # Create a script to launch Burp Suite
        echo "Creating launcher for Burp Suite..."
        echo "java -jar /root/Burp_Suite/Burp.jar" > /root/Burp_Suite/burp
        chmod +x /root/Burp_Suite/burp
        mv /root/Burp_Suite/burp /usr/bin/burp
        
        # Create a desktop entry for Burp Suite
        echo "Creating Burp Suite application launcher..."
        sudo tee /usr/share/applications/burp-suite.desktop > /dev/null <<EOL
[Desktop Entry]
Version=1.0
Name=Burp Suite
Comment=Burp Suite Web Security Testing Tool
Exec=/usr/bin/burp
Icon=/root/Burp_Suite/burp-icon.png
Terminal=false
Type=Application
Categories=Utility;Security;
EOL
        
        # Optional: Add an icon (you can specify a path or download a Burp icon here)
        # Example: /root/Burp_Suite/burp-icon.png (Make sure to place the icon in this directory)
        
        # Update the desktop database and make the entry executable
        sudo update-desktop-database
        sudo chmod +x /usr/share/applications/burp-suite.desktop
        
        echo -e "\n\033[1;32mBurp Suite has been successfully installed!\033[0m"
        echo "You can now launch Burp Suite from your application menu."
        echo "Alternatively, you can run the following command to start Burp Suite:"
        echo -e "\033[1;34mburp\033[0m"
        ;;

    2)
        echo -e "\n\033[1;31mUninstalling Burp Suite...\033[0m"
        
        # Remove Burp Suite files
        rm -f /usr/bin/burp
        rm -rf /root/Burp_Suite/
        sudo rm -f /usr/share/applications/burp-suite.desktop
        
        # Remove JDK 23 manually installed directory
        if [ -d "/root/jdk-23" ]; then
            echo -e "\n\033[1;31mRemoving manually installed JDK 23...\033[0m"
            rm -rf /root/jdk-23
        fi
        
        # Remove symbolic links for java and javac if they exist
        if [ -L "/usr/bin/java" ]; then
            echo -e "\n\033[1;31mRemoving symbolic link for Java...\033[0m"
            rm -f /usr/bin/java
        fi
        if [ -L "/usr/bin/javac" ]; then
            echo -e "\n\033[1;31mRemoving symbolic link for Javac...\033[0m"
            rm -f /usr/bin/javac
        fi
        
        # Optionally, remove Java package if installed via a package manager (uncommon for manually installed JDK)
        if dpkg -l | grep -q "openjdk"; then
            echo -e "\n\033[1;31mRemoving OpenJDK package...\033[0m"
            sudo apt-get remove --purge openjdk-* -y
        fi

        echo -e "\n\033[1;32mBurp Suite and JDK have been successfully uninstalled.\033[0m"
        ;;

    3)
        echo "Exiting..."
        exit 0
        ;;
    
    *)
        echo -e "\n\033[1;31mInvalid option. Exiting...\033[0m"
        exit 1
        ;;
esac

