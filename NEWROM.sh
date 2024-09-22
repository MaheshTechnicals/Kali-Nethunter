#!/bin/bash

# Script name: ROM Build Setup
# Author: Mahesh Technicals
## For UBUNTU 22.04 LTS ONLY
echo "==================================================================="
echo "                  ROM Build Setup (ubuntu 22.04)- Mahesh Technicals                "
echo "==================================================================="

echo "Installing required packages..."
echo "--------------------------------"
sudo apt update
sudo apt upgrade -y
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop openjdk-11-jdk python3 python3-pip rsync unzip xsltproc zip zlib1g-dev git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig default-jdk

echo "Setting up repo tool..."
echo "-------------------------"
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

echo "Cloning necessary scripts..."
echo "----------------------------"
cd ~/bin
git clone https://github.com/akhilnarang/scripts

echo "Setting up Android build environment..."
echo "----------------------------------------"
cd scripts
./setup/android_build_env.sh

echo "Configuring Git..."
echo "-------------------"
git config --global user.name "MaheshTechnicals"
git config --global user.email "msvarma10001@gmail.com"

echo "Setup completed successfully!"
