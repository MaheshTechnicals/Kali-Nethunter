#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print larger text
larger_text() {
    echo -e "${1}\n"
}

# Function to setup build environment
setup_build_environment() {
  echo -e "${CYAN}Installing required packages...${NC}"
  echo -e "${CYAN}--------------------------------${NC}"
  sudo apt update
  sudo apt install -y git-core gnupg flex bison gperf build-essential \
    zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
    lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev \
    libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig default-jdk

  echo -e "${CYAN}Setting up repo tool...${NC}"
  echo -e "${CYAN}-------------------------${NC}"
  mkdir -p ~/bin
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
  chmod a+x ~/bin/repo

  echo -e "${CYAN}Cloning necessary scripts...${NC}"
  echo -e "${CYAN}----------------------------${NC}"
  cd ~/bin
  git clone https://github.com/akhilnarang/scripts

  echo -e "${CYAN}Setting up Android build environment...${NC}"
  echo -e "${CYAN}----------------------------------------${NC}"
  cd scripts
  ./setup/android_build_env.sh

  echo -e "${CYAN}Configuring Git...${NC}"
  echo -e "${CYAN}-------------------${NC}"
  read -p "Enter your Git username: " username
  read -p "Enter your Git email: " email
  git config --global user.name "$username"
  git config --global user.email "$email"
}

# Function to create swapfile
create_swapfile() {
  echo -e "${CYAN}Creating swapfile...${NC}"
  echo -e "${CYAN}---------------------${NC}"
  sudo dd if=/dev/zero of=/swapfile bs=1G count=50
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
}

# Function to print a centered box with text inside
print_box() {
    local text=$1
    local text_length=${#text}
    local term_width=$(tput cols)
    local padding=$((($term_width - $text_length) / 2))
    local padding_left=$(($padding - 1))
    local padding_right=$(($padding - 1))

    echo -e "${CYAN}╔$(printf '═%.0s' $(seq 1 $term_width))╗${NC}"
    echo -e "${CYAN}║${WHITE}${text}${CYAN}║${NC}"
    echo -e "${CYAN}╚$(printf '═%.0s' $(seq 1 $term_width))╝${NC}"
}

# Function to print colored button with number
print_button() {
    local num=$1
    local text=$2
    local color=$3
    local text_length=${#text}
    local padding_left=$(( ($term_width - $text_length) / 4 ))
    local padding_right=$(( ($term_width - $text_length) / 4 ))

    echo -e "${color}╭─$(printf '─%.0s' $(seq 1 $term_width))─╮${NC}"
    echo -e "${color}│$(printf ' %.0s' $(seq 1 $padding_left)) ${WHITE}${num}. ${text} $(printf ' %.0s' $(seq 1 $padding_right))${color}│${NC}"
    echo -e "${color}╰─$(printf '─%.0s' $(seq 1 $term_width))─╯${NC}"
}

# Print header
clear
echo -e "${YELLOW}==============================================================================${NC}"
print_box "$(larger_text "${WHITE}ROM Build Setup - ${YELLOW}Mahesh Technicals${WHITE}")"
echo -e "${YELLOW}==============================================================================${NC}"

# Present options in a table-like format
echo -e "${GREEN}Choose an option:${NC}"
echo ""

term_width=$(tput cols)
print_button "1" "Setup Build Environment" "$CYAN"
print_button "2" "Create Swapfile" "$CYAN"
print_button "3" "Exit" "$RED"
echo ""

# Ask for user choice
read -p "${GREEN}Enter Your Option: ${NC}" choice

# Execute corresponding function based on user choice
case $choice in
  1)
    setup_build_environment
    echo -e "${GREEN}Setup completed successfully!${NC}"
    ;;
  2)
    create_swapfile
    echo -e "${GREEN}Swapfile created successfully!${NC}"
    ;;
  3)
    echo -e "${GREEN}Exiting...${NC}"
    exit 0
    ;;
  *)
    echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${NC}"
    ;;
esac
