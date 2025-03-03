#!/bin/bash

echo "🚀 Starting Apache & PHP Installation on Ubuntu..."

# Step 1: Update System Packages
echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Step 2: Install Apache
echo "🌐 Installing Apache Web Server..."
sudo apt install apache2 -y

# Step 3: Install PHP and Required Modules
echo "🛠 Installing PHP and extensions..."
sudo apt install php libapache2-mod-php php-cli php-curl php-mbstring php-xml php-zip php-gd php-mysql php-bcmath -y

# Step 4: Ensure Apache Listens on Port 2080
echo "⚙ Configuring Apache to use port 2080..."
sudo sed -i 's/Listen 80/Listen 2080/' /etc/apache2/ports.conf
sudo sed -i 's/:80>/:2080>/' /etc/apache2/sites-available/000-default.conf

# Step 5: Restart Apache to Apply Changes
echo "🔄 Restarting Apache..."
sudo service apache2 restart

# Step 6: Create info.php File
echo "📄 Creating PHP info file..."
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php > /dev/null

# Step 7: Set Correct Permissions
echo "🔑 Setting permissions for web directory..."
sudo chmod -R 755 /var/www/html/
sudo chown -R www-data:www-data /var/www/html/

# Step 8: Display Completion Message
echo "✅ Installation Complete!"
echo "📌 Open your browser and visit: http://localhost:2080/info.php"

