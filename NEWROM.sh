#!/bin/bash

# Script name: ROM Build Setup
# Author: Mahesh Technicals

echo "==================================================================="
echo "                  ROM Build Setup - Mahesh Technicals                "
echo "==================================================================="

echo "Installing required packages..."
echo "--------------------------------"
sudo apt update
sudo apt install -y git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev \
  libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig default-jdk

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

echo "Creating swapfile..."
echo "---------------------"
sudo fallocate -l 50G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "Setup completed successfully!"
