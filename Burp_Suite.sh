echo "
              #######  ######  ###########
              ###  ##  ## ###  ###########
              ###  ###### ###       ##
              ###         ###       ##
              ###         ###       ##
              ###         ###       ##

        ################################################
         Burp suite Installer By Mahesh Technicals
        ################################################
"
if [[ $EUID -eq 0 ]]; then
    # Download Burp Suite Community Latet Version
    echo 'Downloading Burp Suite Community....'
    Link="https://portswigger-cdn.net/burp/releases/download?product=community&type=jar"
    wget "$Link" -O Burp.jar --progress=bar
    sleep 2

# Launch Burp Suite.
echo "Opening Burp suite......"
mkdir /root/Burp_Suite/
mv Burp.jar /root/Burp_Suite/
echo java -jar /root/Burp_Suite/Burp.jar > burp
chmod +x burp
mv burp /usr/bin/
burp


else
    echo "Execute Command as Root User"
    exit
fi
