#!/usr/bin/env bash
# =========================================================
#   CLAUDE CODE INSTALLER — by Mahesh Technicals
#   GitHub: https://github.com/MaheshTechnicals
# =========================================================

GREEN='\033[01;32m'
CYAN='\033[01;36m'
YELLOW='\033[01;33m'
RED='\033[01;31m'
BLUE='\033[01;34m'
BOLD='\033[01m'
RESET='\033[00m'

print_banner() {
    clear
    echo -e "${CYAN}"
    echo -e "  ╔══════════════════════════════════════════════════╗"
    echo -e "  ║         MAHESH TECHNICALS - CLAUDE CODE          ║"
    echo -e "  ║              INSTALLER & CONFIGURATOR            ║"
    echo -e "  ╚══════════════════════════════════════════════════╝${RESET}"
    echo -e "  ${BLUE}GitHub: https://github.com/MaheshTechnicals${RESET}\n"
}

print_step() {
    echo -e "\n${CYAN}  ┌─ ${BOLD}$1${RESET}"
}

print_ok()   { echo -e "  ${GREEN}  ✔  $1${RESET}"; }
print_warn() { echo -e "  ${YELLOW}  ⚠  $1${RESET}"; }
print_err()  { echo -e "  ${RED}  ✖  $1${RESET}"; }
print_info() { echo -e "  ${BLUE}  ➜  $1${RESET}"; }

print_banner

# ─── STEP 1: Node.js & NPM ────────────────────────────────
print_step "STEP 1 — Node.js & NPM"
if command -v node &>/dev/null && command -v npm &>/dev/null; then
    NODE_VER=$(node -v)
    NPM_VER=$(npm -v)
    print_ok "Node.js $NODE_VER and NPM $NPM_VER already installed. Skipping."
else
    print_warn "Node.js/NPM missing. Installing..."
    sudo apt update -qq && sudo apt install nodejs npm -y -qq
    if command -v node &>/dev/null; then
        print_ok "Node.js and NPM installed successfully."
    else
        print_err "Installation failed. Check your internet or permissions."
        exit 1
    fi
fi

# ─── STEP 2: Claude Code Installation ─────────────────────
print_step "STEP 2 — Claude Code v2.1.112"
INSTALLED_CC_VER=$(claude --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1)
TARGET_VER="2.1.112"

if [ "$INSTALLED_CC_VER" == "$TARGET_VER" ]; then
    print_ok "Claude Code v$TARGET_VER already installed. Skipping reinstall."
else
    print_info "Installing Claude Code v$TARGET_VER (Android/Termux Safe)..."
    sudo npm install -g @anthropic-ai/claude-code@$TARGET_VER --silent 2>&1 | grep -v "^$"
    if [ $? -eq 0 ]; then
        print_ok "Claude Code v$TARGET_VER installed successfully."
    else
        print_err "Installation failed. Check permissions."
        exit 1
    fi
fi

# ─── STEP 3: API Key ──────────────────────────────────────
print_step "STEP 3 — OpenCode API Key"

EXISTING_KEY=""
SETTINGS_FILE="$HOME/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    EXISTING_KEY=$(python3 -c "
import json
try:
    with open('$SETTINGS_FILE') as f:
        d = json.load(f)
    print(d.get('env', {}).get('ANTHROPIC_API_KEY', ''))
except: print('')
" 2>/dev/null)
fi

if [ -n "$EXISTING_KEY" ]; then
    MASKED="${EXISTING_KEY:0:4}****${EXISTING_KEY: -4}"
    echo -e "\n  ${YELLOW}  Current API Key: ${MASKED}${RESET}"
    echo -ne "  ${BOLD}  Keep existing key? [Y/n]: ${RESET}"
    read -r KEEP_KEY
    KEEP_KEY=${KEEP_KEY:-Y}
    if [[ "$KEEP_KEY" =~ ^[Yy]$ ]]; then
        API_KEY="$EXISTING_KEY"
        print_ok "Using existing API Key."
    else
        ENTER_NEW=true
    fi
else
    ENTER_NEW=true
fi

if [ "$ENTER_NEW" == "true" ]; then
    echo -e "\n  ${BLUE}  Get your key at: https://opencode.ai/${RESET}"
    echo -ne "  ${BOLD}  Paste your OpenCode API Key: ${RESET}"
    unset API_KEY
    while IFS= read -r -s -n1 char; do
        if [[ -z $char ]]; then echo ""; break; fi
        if [[ $char == $'\177' || $char == $'\b' ]]; then
            if [ -n "$API_KEY" ]; then API_KEY="${API_KEY%?}"; echo -ne "\b \b"; fi
        else
            API_KEY+="$char"; echo -n "*"
        fi
    done
    if [ -z "$API_KEY" ]; then
        print_err "API Key cannot be empty. Aborting."
        exit 1
    fi
    print_ok "API Key captured."
fi

# ─── STEP 4: Fetch Live Free Models ───────────────────────
print_step "STEP 4 — Free Model Selection"
print_info "Fetching live models from OpenCode API..."

DIRECT_URL="https://opencode.ai/zen/v1/models"
ENCODED_URL=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$DIRECT_URL'))" 2>/dev/null)

fetch_models() {
    local url="$1"
    local raw
    raw=$(curl -s --max-time 10 "$url" 2>/dev/null)
    if echo "$raw" | grep -q '"data"'; then echo "$raw"; fi
}

MODELS_JSON=$(fetch_models "$DIRECT_URL")
[ -z "$MODELS_JSON" ] && MODELS_JSON=$(fetch_models "https://corsproxy.io/?$ENCODED_URL")
[ -z "$MODELS_JSON" ] && {
    WRAPPER=$(curl -s --max-time 10 "https://api.allorigins.win/get?url=$ENCODED_URL" 2>/dev/null)
    MODELS_JSON=$(python3 -c "
import sys,json
try:
    d=json.loads('''$WRAPPER''')
    print(d.get('contents',''))
except: print('')
" 2>/dev/null)
}

FREE_MODELS=()
if [ -n "$MODELS_JSON" ]; then
    mapfile -t FREE_MODELS < <(echo "$MODELS_JSON" | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    [print(m['id']) for m in d.get('data',[]) if 'free' in m.get('id','').lower()]
except: pass
" 2>/dev/null)
fi

EXISTING_MODEL=""
if [ -f "$SETTINGS_FILE" ]; then
    EXISTING_MODEL=$(python3 -c "
import json
try:
    with open('$SETTINGS_FILE') as f:
        d = json.load(f)
    print(d.get('env', {}).get('ANTHROPIC_MODEL', ''))
except: print('')
" 2>/dev/null)
fi

SELECTED_MODEL=""

if [ ${#FREE_MODELS[@]} -eq 0 ]; then
    print_warn "Could not fetch live models."
    if [ -n "$EXISTING_MODEL" ]; then
        print_ok "Keeping existing model: $EXISTING_MODEL"
        SELECTED_MODEL="$EXISTING_MODEL"
    else
        SELECTED_MODEL="minimax-m3-free"
        print_warn "Using default: $SELECTED_MODEL"
    fi
else
    echo -e "\n  ${CYAN}  ┌─────────────────────────────────────────────┐${RESET}"
    echo -e "  ${CYAN}  │      Free Models — Live from OpenCode API   │${RESET}"
    echo -e "  ${CYAN}  └─────────────────────────────────────────────┘${RESET}"
    for i in "${!FREE_MODELS[@]}"; do
        MARKER=""
        [ "${FREE_MODELS[$i]}" == "$EXISTING_MODEL" ] && MARKER=" ${YELLOW}← current${RESET}"
        echo -e "  ${YELLOW}    [$((i+1))]${RESET} ${FREE_MODELS[$i]}$MARKER"
    done
    echo ""

    if [ -n "$EXISTING_MODEL" ]; then
        echo -ne "  ${BOLD}  Keep current model ($EXISTING_MODEL)? [Y/n]: ${RESET}"
        read -r KEEP_MODEL
        KEEP_MODEL=${KEEP_MODEL:-Y}
        if [[ "$KEEP_MODEL" =~ ^[Yy]$ ]]; then
            SELECTED_MODEL="$EXISTING_MODEL"
            print_ok "Keeping model: $SELECTED_MODEL"
        fi
    fi

    if [ -z "$SELECTED_MODEL" ]; then
        echo -ne "  ${BOLD}  Select model number [1-${#FREE_MODELS[@]}]: ${RESET}"
        while true; do
            read -r CHOICE
            if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#FREE_MODELS[@]}" ]; then
                SELECTED_MODEL="${FREE_MODELS[$((CHOICE-1))]}"
                print_ok "Selected: $SELECTED_MODEL"
                break
            fi
            echo -ne "  ${RED}  Invalid. Enter 1–${#FREE_MODELS[@]}: ${RESET}"
        done
    fi
fi

# ─── STEP 5: Write Settings ───────────────────────────────
print_step "STEP 5 — Saving Configuration"
mkdir -p "$HOME/.claude"

cat > "$SETTINGS_FILE" << EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://opencode.ai/zen",
    "ANTHROPIC_MODEL": "$SELECTED_MODEL",
    "ANTHROPIC_API_KEY": "$API_KEY",
    "ENABLE_TOOL_SEARCH": "true"
  }
}
EOF

print_ok "Settings saved → ~/.claude/settings.json"
print_info "Model : $SELECTED_MODEL"

# ─── STEP 6: Shell Alias ──────────────────────────────────
print_step "STEP 6 — Shell Alias"
CURRENT_SHELL=$(basename "$SHELL")
case "$CURRENT_SHELL" in
    zsh)  PROFILE_FILE="$HOME/.zshrc" ;;
    bash) PROFILE_FILE="$HOME/.bashrc" ;;
    *)    PROFILE_FILE="$HOME/.profile" ;;
esac

if grep -q "alias claude=" "$PROFILE_FILE" 2>/dev/null; then
    print_ok "Alias already present in $PROFILE_FILE. Skipping."
else
    {
        echo ""
        echo "# Claude Code — Mahesh Technicals"
        echo "alias claude='claude --dangerously-skip-permissions'"
    } >> "$PROFILE_FILE"
    print_ok "Alias injected into $PROFILE_FILE"
fi

# ─── STEP 7: Apply Profile ────────────────────────────────
print_step "STEP 7 — Applying Profile"
print_info "Run this to activate in current session:"
echo -e "\n  ${CYAN}  source $PROFILE_FILE${RESET}\n"

# ─── DONE ─────────────────────────────────────────────────
echo -e "\n${GREEN}  ╔══════════════════════════════════════════════════╗"
echo -e "  ║   🎉  SETUP COMPLETE! READY TO AGENT CODES 🎉   ║"
echo -e "  ║                                                  ║"
echo -e "  ║   Model : $(printf '%-40s' "$SELECTED_MODEL")║"
echo -e "  ╚══════════════════════════════════════════════════╝${RESET}"
echo -e "  ${BLUE}  Then run: ${CYAN}claude${RESET}\n"

exec "$SHELL"
