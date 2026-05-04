#!/bin/bash

LOG_FILE="/tmp/pyjs_install.log"
> "$LOG_FILE" # Clear old log

# ==========================================
# 1. Gradient Text & Header
# ==========================================
animate_text() {
    local text="$1"
    for (( i=0; i<${#text}; i++ )); do
        r=$((50 + (i * 10) % 205))
        g=$((100 + (i * 5) % 155))
        b=255
        printf "\e[38;2;%d;%d;%dm%s\e[0m" "$r" "$g" "$b" "${text:$i:1}"
        if (( i % 3 == 0 )); then sleep 0.01; fi
    done
    echo ""
}

show_header() {
    clear
    echo ""
    animate_text "      ██████╗  ██╗   ██╗      ██╗ ███████╗"
    animate_text "      ██╔══██╗ ╚██╗ ██╔╝      ██║ ██╔════╝"
    animate_text "      ██████╔╝  ╚████╔╝       ██║ ███████╗"
    animate_text "      ██╔═══╝    ╚██╔╝   ██   ██║ ╚════██║"
    animate_text "      ██║         ██║    ╚█████╔╝ ███████║"
    animate_text "      ╚═╝         ╚═╝     ╚════╝  ╚══════╝"
    echo ""
    animate_text "              Script: PYJS (Ultimate Edition)"
    animate_text "            👨‍💻 Author: Mahesh Technicals 👨‍💻"
    echo -e "\e[1;30m=======================================================================\e[0m"
    sleep 0.2
}

pause_to_continue() {
    echo -e "\e[1;30m=======================================================================\e[0m"
    read -p $'\e[1;37mPress [ENTER] to return to the menu...\e[0m'
}

# ==========================================
# 2. Pre-Checks, Setup & Auto-Heal
# ==========================================
check_internet() {
    if ! ping -c 1 -W 2 google.com &> /dev/null; then
        clear
        echo -e "❌ \e[31mNo Internet Connection Detected!\e[0m"
        exit 1
    fi
}

detect_pm() {
    if command -v apt-get &> /dev/null; then
        PM="sudo apt-get install -y"
        UPDATE="sudo apt-get update -y -qq"
        FIX_DEPS="sudo apt-get --fix-broken install -y -qq" 
        UPGRADE="sudo apt-get upgrade -y python3 python3-pip python3-venv"
        CLEAN="sudo apt-get autoremove -y -qq && sudo apt-get clean"
        REMOVE="sudo apt-get remove --purge -y python3 python3-pip python3-venv && sudo apt-get autoremove -y -qq"
    elif command -v pacman &> /dev/null; then
        PM="sudo pacman -S --noconfirm"
        UPDATE="sudo pacman -Sy --quiet"
        FIX_DEPS=""
        UPGRADE="sudo pacman -Syu --noconfirm python python-pip"
        CLEAN="sudo pacman -Sc --noconfirm"
        REMOVE="sudo pacman -Rns --noconfirm python python-pip"
    elif command -v dnf &> /dev/null; then
        PM="sudo dnf install -y"
        UPDATE="sudo dnf check-update -q"
        FIX_DEPS=""
        UPGRADE="sudo dnf upgrade -y python3 python3-pip"
        CLEAN="sudo dnf clean all"
        REMOVE="sudo dnf remove -y python3 python3-pip"
    elif command -v apk &> /dev/null; then
        PM="sudo apk add"
        UPDATE="sudo apk update --quiet"
        FIX_DEPS=""
        UPGRADE="sudo apk upgrade python3 py3-pip"
        CLEAN="rm -rf /var/cache/apk/*"
        REMOVE="sudo apk del python3 py3-pip"
    else
        echo -e "❌ \e[31mUnsupported OS!\e[0m"
        exit 1
    fi
}

check_internet
detect_pm

if ! command -v curl &> /dev/null; then
    $UPDATE >> "$LOG_FILE" 2>&1
    if [ -n "$FIX_DEPS" ]; then eval "$FIX_DEPS" >> "$LOG_FILE" 2>&1; fi
    $PM curl >> "$LOG_FILE" 2>&1
fi

load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

# ==========================================
# 3. Dynamic Version Table Module
# ==========================================
show_summary_table() {
    local mode=$1
    load_nvm
    
    local v_nvm="Not Installed"
    local v_node="Not Installed"
    local v_npm="Not Installed"
    local v_py="Not Installed"
    local v_pip="Not Installed"

    echo -e "\e[1;36m+-----------------+-----------------------+\e[0m"
    echo -e "\e[1;36m|\e[0m \e[1;37mSoftware Tool   \e[0m\e[1;36m|\e[0m \e[1;37mInstalled Version     \e[0m\e[1;36m|\e[0m"
    echo -e "\e[1;36m+-----------------+-----------------------+\e[0m"

    if [[ "$mode" == "node" || "$mode" == "both" ]]; then
        if command -v nvm &> /dev/null; then v_nvm=$(nvm --version); fi
        if command -v node &> /dev/null; then v_node=$(node -v); fi
        if command -v npm &> /dev/null; then v_npm="v$(npm -v)"; fi
        printf "\e[1;36m|\e[0m \e[32m%-15s\e[0m \e[1;36m|\e[0m \e[33m%-21s\e[0m \e[1;36m|\e[0m\n" "NVM Manager" "v$v_nvm"
        printf "\e[1;36m|\e[0m \e[32m%-15s\e[0m \e[1;36m|\e[0m \e[33m%-21s\e[0m \e[1;36m|\e[0m\n" "Node.js" "$v_node"
        printf "\e[1;36m|\e[0m \e[32m%-15s\e[0m \e[1;36m|\e[0m \e[33m%-21s\e[0m \e[1;36m|\e[0m\n" "NPM Package" "$v_npm"
    fi

    if [[ "$mode" == "python" || "$mode" == "both" ]]; then
        if command -v python3 &> /dev/null; then v_py="v$(python3 --version | awk '{print $2}')"; fi
        if command -v pip3 &> /dev/null; then v_pip="v$(pip3 --version | awk '{print $2}')"; fi
        printf "\e[1;36m|\e[0m \e[32m%-15s\e[0m \e[1;36m|\e[0m \e[33m%-21s\e[0m \e[1;36m|\e[0m\n" "Python 3" "$v_py"
        printf "\e[1;36m|\e[0m \e[32m%-15s\e[0m \e[1;36m|\e[0m \e[33m%-21s\e[0m \e[1;36m|\e[0m\n" "Pip 3" "$v_pip"
    fi

    echo -e "\e[1;36m+-----------------+-----------------------+\e[0m\n"
}

# ==========================================
# 4. Core Modules
# ==========================================
install_node() {
    clear
    show_header
    if [ -d "$HOME/.nvm" ] && command -v node &> /dev/null; then
        load_nvm
        CURR_VER=$(node -v)
        echo -e "⏳ \e[36mChecking NVM for updates...\e[0m"
        OUT=$(nvm install node 2>&1)
        if echo "$OUT" | grep -q "is already installed"; then
            echo -e "\n🟢 \e[1;32mUp to Date!\e[0m"
            echo -e "Node.js ($CURR_VER) is already the latest version.\n"
        else
            echo -e "\n🎉 \e[1;32mUpdated!\e[0m"
            echo -e "Node.js updated to $(node -v)!\n"
        fi
        if [ "$SKIP_TABLE" != "1" ]; then show_summary_table "node"; fi
        return
    fi
    
    echo -e "⏳ \e[36mDownloading NVM & Latest Node.js...\e[0m"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    echo -e "\n⚙️  \e[33mConfiguring Node.js environment...\e[0m"
    nvm install node
    nvm alias default node
    
    if command -v node &> /dev/null; then
        echo -e "\n🎉 \e[1;32mSuccess!\e[0m"
        echo -e "Node.js $(node -v) installed successfully!\n"
        if [ "$SKIP_TABLE" != "1" ]; then show_summary_table "node"; fi
    else
        echo -e "\n❌ \e[1;31mInstallation Failed!\e[0m"
        echo -e "NVM could not set up Node.js. Check network or logs.\n"
    fi
}

install_python() {
    clear
    show_header
    echo -e "⏳ \e[36mChecking Python 3 Status...\e[0m"
    $UPDATE >> "$LOG_FILE" 2>&1
    
    if [ -n "$FIX_DEPS" ]; then
        echo -e "🔧 \e[33mRunning Auto-Heal for system packages...\e[0m"
        eval "$FIX_DEPS" >> "$LOG_FILE" 2>&1
    fi

    if command -v python3 &> /dev/null; then
        OLD_VER=$(python3 --version 2>&1)
    else
        OLD_VER="None"
    fi

    echo -e "📦 \e[33mDownloading and configuring Python packages...\e[0m"
    $PM python3 python3-pip python3-venv >> "$LOG_FILE" 2>&1

    if command -v python3 &> /dev/null; then
        NEW_VER=$(python3 --version 2>&1)
        if [ "$OLD_VER" == "$NEW_VER" ]; then
            echo -e "\n🐍 \e[1;32mUp to Date!\e[0m"
            echo -e "$NEW_VER is already installed and up to date.\n"
        elif [ "$OLD_VER" == "None" ]; then
            echo -e "\n🎉 \e[1;32mSuccess!\e[0m"
            echo -e "$NEW_VER installed successfully!\n"
        else
            echo -e "\n🎉 \e[1;32mUpdated!\e[0m"
            echo -e "Python updated: $OLD_VER ➔ $NEW_VER\n"
        fi
        if [ "$SKIP_TABLE" != "1" ]; then show_summary_table "python"; fi
    else
        echo -e "\n❌ \e[1;31mInstallation Failed!\e[0m"
        echo -e "Could not find python3 command. Please check \e[4m$LOG_FILE\e[0m.\n"
    fi
}

install_both() {
    SKIP_TABLE=1
    install_node
    sleep 1
    install_python
    SKIP_TABLE=0
    
    clear
    show_header
    echo -e "🎉 \e[1;32mBoth Environments Processed Successfully!\e[0m\n"
    show_summary_table "both"
}

install_dev_tools() {
    clear
    show_header
    echo -e "📦 \e[36mInstalling Global Dev Tools...\e[0m\n"
    if command -v npm &> /dev/null; then 
        echo -e "🟢 Installing Yarn & PM2..."
        npm install -g yarn pnpm pm2 >> "$LOG_FILE" 2>&1
    fi
    if command -v pip &> /dev/null; then 
        echo -e "🐍 Installing Virtualenv & Black..."
        pip install --user virtualenv black >> "$LOG_FILE" 2>&1
    fi
    echo -e "\n🎉 \e[1;32mDev Tools Installed Successfully!\e[0m\n"
}

create_venv() {
    clear
    show_header
    echo -e "📁 \e[36mCreating Python Virtual Environment...\e[0m\n"
    if [ -d "venv" ]; then
        echo -e "⚠️  \e[1;33mVenv Found!\e[0m"
        echo -e "A 'venv' directory already exists in this folder.\n"
    else
        python3 -m venv venv >> "$LOG_FILE" 2>&1
        echo -e "🎉 \e[1;32mVenv Created!\e[0m"
        echo -e "To activate it, run: \e[1;36msource venv/bin/activate\e[0m\n"
    fi
}

update_env() {
    clear
    show_header
    echo -e "🔄 \e[1;36mSmart Checking for Updates...\e[0m\n"
    
    if [ -n "$FIX_DEPS" ]; then
        eval "$FIX_DEPS" >> "$LOG_FILE" 2>&1
    fi
    
    echo -e "📦 \e[33mUpdating Python & System Packages...\e[0m"
    $UPDATE > /dev/null 2>&1
    $UPGRADE >> "$LOG_FILE" 2>&1
    echo -e "✅ \e[1;32mSystem packages processing complete!\e[0m"
    
    echo -e "\n🟢 \e[33mChecking Node.js...\e[0m"
    if [ -d "$HOME/.nvm" ]; then
        load_nvm
        if nvm install node --reinstall-packages-from=node 2>&1 | grep -q "is already installed"; then
            echo -e "✅ \e[1;32mNode.js is already the latest version!\e[0m"
        else
            nvm alias default node > /dev/null 2>&1
            echo -e "🎉 \e[1;32mNode.js updated!\e[0m"
        fi
    fi
    eval "$CLEAN" >> "$LOG_FILE" 2>&1
    echo -e "\n🧹 \e[1;32mStorage cleanup complete!\e[0m\n"
}

uninstall_all() {
    clear
    show_header
    echo -e "⚠️  \e[1;31mDANGER ZONE - FULL WIPE\e[0m\n"
    read -p "Are you sure you want to COMPLETELY remove NVM, Node.js, and Python 3? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "\n🗑️  \e[33mRemoving NVM & Node.js...\e[0m"
        rm -rf "$HOME/.nvm"
        
        echo -e "🗑️  \e[33mRemoving Python 3, Pip & Venv...\e[0m"
        if [ -n "$FIX_DEPS" ]; then eval "$FIX_DEPS" >> "$LOG_FILE" 2>&1; fi
        eval "$REMOVE" >> "$LOG_FILE" 2>&1
        rm -rf "$HOME/.local/lib/python*"
        rm -rf "$HOME/.local/bin/black" "$HOME/.local/bin/virtualenv"
        
        echo -e "\n✅ \e[1;32mEnvironment completely uninstalled successfully.\e[0m\n"
    else
        echo -e "\n❌ \e[1;33mUninstall aborted.\e[0m\n"
    fi
}

show_info() {
    clear
    show_header
    echo -e "\e[1;36m✨ PYJS Ultimate Dev Environment v2026 ✨\e[0m\n"
    echo -e "Author : \e[1;37mMahesh Technicals\e[0m"
    echo -e "Purpose: 1-Click setup for Node.js & Python\n"
    echo -e "\e[1;33m💡 COMMAND LINE FLAGS SUPPORT:\e[0m"
    echo -e "You can bypass this UI by using flags:"
    echo -e "  \e[36m./alltools.sh -n\e[0m  ➔ Install Node.js"
    echo -e "  \e[36m./alltools.sh -p\e[0m  ➔ Install Python 3"
    echo -e "  \e[36m./alltools.sh -b\e[0m  ➔ Install Both (With Summary)"
    echo -e "  \e[36m./alltools.sh -d\e[0m  ➔ Install Dev Tools"
    echo -e "  \e[36m./alltools.sh -v\e[0m  ➔ Create Python Venv"
    echo -e "  \e[36m./alltools.sh -u\e[0m  ➔ Smart Auto-Update"
    echo -e "  \e[36m./alltools.sh -c\e[0m  ➔ Clean & Uninstall"
    echo -e "  \e[36m./alltools.sh -h\e[0m  ➔ Show this Help/Info\n"
    echo -e "📜 \e[1;33mLOGS:\e[0m If any error occurs, check: \e[4m/tmp/pyjs_install.log\e[0m\n"
}

show_cli_help() {
    clear
    echo -e "\e[1;36mPYJS Command Line Interface\e[0m"
    echo -e "Usage: \e[1;32m./alltools.sh [FLAG]\e[0m\n"
    echo -e "  \e[33m-n\e[0m   Install Node.js"
    echo -e "  \e[33m-p\e[0m   Install Python"
    echo -e "  \e[33m-b\e[0m   Install Both Node & Python (With Summary)"
    echo -e "  \e[33m-d\e[0m   Install Dev Tools"
    echo -e "  \e[33m-v\e[0m   Create Venv in current directory"
    echo -e "  \e[33m-u\e[0m   Auto Update Environment"
    echo -e "  \e[33m-c\e[0m   Uninstall & Clean"
    echo -e "  \e[33m-h\e[0m   Show this help\n"
    exit 0
}

# ==========================================
# 5. CLI Flag Processing
# ==========================================
if [ $# -gt 0 ]; then
    while getopts "npbdvuch" flag; do
        case $flag in
            n) install_node; exit 0 ;;
            p) install_python; exit 0 ;;
            b) install_both; exit 0 ;;
            d) install_dev_tools; exit 0 ;;
            v) create_venv; exit 0 ;;
            u) update_env; exit 0 ;;
            c) uninstall_all; exit 0 ;;
            h) show_cli_help; exit 0 ;;
            *) echo "Invalid flag. Use -h for help."; exit 1 ;;
        esac
    done
fi

# ==========================================
# 6. Main Terminal Loop
# ==========================================
while true; do
    show_header
    echo -e "  \e[1;36m[1]\e[0m 🟢 Install Latest Node.js"
    echo -e "  \e[1;36m[2]\e[0m 🐍 Install Python 3 & Pip"
    echo -e "  \e[1;36m[3]\e[0m 📦 Install Both (Node + Python)"
    echo -e "  \e[1;36m[4]\e[0m 🛠️  Install Global Dev Tools (Yarn, PM2)"
    echo -e "  \e[1;36m[5]\e[0m 📁 Create Python Venv (Current Folder)"
    echo -e "  \e[1;36m[6]\e[0m 🔄 Smart Auto-Update & System Cleanup"
    echo -e "  \e[1;36m[7]\e[0m 🗑️  Uninstall Environment (Danger)"
    echo -e "  \e[1;36m[8]\e[0m 📖 Help & Information"
    echo -e "  \e[1;36m[9]\e[0m 🚪 Exit & Refresh Terminal"
    echo -e "\e[1;30m=======================================================================\e[0m"
    
    read -p $'\e[1;32mSelect an option (1-9): \e[0m' CHOICE

    case $CHOICE in
        1) install_node; pause_to_continue ;;
        2) install_python; pause_to_continue ;;
        3) install_both; pause_to_continue ;;
        4) install_dev_tools; pause_to_continue ;;
        5) create_venv; pause_to_continue ;;
        6) update_env; pause_to_continue ;;
        7) uninstall_all; pause_to_continue ;;
        8) show_info; pause_to_continue ;;
        9) 
            clear
            echo -e "✨ \e[32mApplying changes and refreshing your terminal...\e[0m"
            exec $SHELL
            ;;
        *) 
            echo -e "\n❌ \e[31mInvalid option. Please choose between 1 and 9.\e[0m"
            sleep 1 
            ;;
    esac
done
