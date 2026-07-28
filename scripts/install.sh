#!/usr/bin/env bash

# ==============================================================================
# EndeavourOS-Shell Installation Script
# Project: EndeavourOS-Shell
# Description: Automated setup script to build themes, link configuration files,
#              install required dependencies, and apply KWin window rules.
# ==============================================================================

set -euo pipefail

# Formatting and Color Helpers
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()    { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
success() { printf "${GREEN}[OK]${NC} %s\n" "$*"; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$*" >&2; }
die()     { error "$*"; exit 1; }

# Paths & Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$(basename "${SCRIPT_DIR}")" = "scripts" ]; then
    ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
else
    ROOT_DIR="${SCRIPT_DIR}"
fi

CONFIG_DIR="${HOME}/.config"
FOOT_CONFIG_DIR="${CONFIG_DIR}/foot"
EOS_SHELL_CONFIG_DIR="${CONFIG_DIR}/EndeavourOS-Shell"
BASHRC="${HOME}/.bashrc"

# Pre-flight Checks
info "Checking dependencies..."

# Check Lua interpreter (bezpečné hledání pod 'set -e')
LUA_CMD=""
for cmd in lua lua5.5 lua5.4; do
    if command -v "$cmd" &>/dev/null; then
        LUA_CMD="$cmd"
        break
    fi
done

if [ -z "$LUA_CMD" ]; then
    die "Lua is required but not found in PATH. Please install Lua."
fi

info "Using Lua interpreter: ${LUA_CMD}"

# Check for foot terminal
if ! command -v foot &>/dev/null; then
    warn "Foot terminal is not installed. Configuration will still be deployed."
fi

# Check for font
FONT_NAME="JetBrainsMono"
if command -v fc-list &>/dev/null; then
    if fc-list | grep -i "${FONT_NAME}" &>/dev/null; then
        success "Font '${FONT_NAME} Nerd Font' detected."
    else
        warn "Font '${FONT_NAME} Nerd Font' not found in system fonts. Icons/glyphs might not render correctly."
    fi
fi

# Generate Configuration files
info "Generating theme configs using Lua script..."

if [ ! -f "${ROOT_DIR}/lua/generate.lua" ]; then
    die "Could not find '${ROOT_DIR}/lua/generate.lua'. Ensure you run this script from the project repository."
fi

(cd "${ROOT_DIR}" && "${LUA_CMD}" lua/generate.lua) || die "Failed to generate theme files."
success "Generated theme configurations successfully."

# Deploy Foot configuration
info "Deploying Foot terminal configuration..."

mkdir -p "${FOOT_CONFIG_DIR}"

if [ -f "${FOOT_CONFIG_DIR}/foot.ini" ] && [ ! -L "${FOOT_CONFIG_DIR}/foot.ini" ]; then
    info "Backing up existing foot.ini to foot.ini.bak"
    cp "${FOOT_CONFIG_DIR}/foot.ini" "${FOOT_CONFIG_DIR}/foot.ini.bak"
fi

ln -sf "${ROOT_DIR}/themes/foot.ini" "${FOOT_CONFIG_DIR}/foot.ini"
success "Linked Foot config -> ${FOOT_CONFIG_DIR}/foot.ini"

# Deploy Shell prompt
info "Deploying Modern Prompt configuration..."

mkdir -p "${EOS_SHELL_CONFIG_DIR}"
ln -sf "${ROOT_DIR}/themes/prompt.sh" "${EOS_SHELL_CONFIG_DIR}/prompt.sh"
success "Linked Modern Prompt -> ${EOS_SHELL_CONFIG_DIR}/prompt.sh"

# Update .bashrc if not already present
PROMPT_SOURCE_LINE='[ -f "$HOME/.config/EndeavourOS-Shell/prompt.sh" ] && source "$HOME/.config/EndeavourOS-Shell/prompt.sh"'

if [ -f "${BASHRC}" ]; then
    if grep -Fq "prompt.sh" "${BASHRC}"; then
        info "Modern Prompt is already sourced in ${BASHRC}."
    else
        info "Adding Modern Prompt entry to ${BASHRC}..."
        printf "\n# EndeavourOS-Shell Modern Prompt\n%s\n" "${PROMPT_SOURCE_LINE}" >> "${BASHRC}"
        success "Added prompt source line to ${BASHRC}."
    fi
else
    warn "${BASHRC} does not exist. Creating and adding prompt configuration..."
    printf "# EndeavourOS-Shell Modern Prompt\n%s\n" "${PROMPT_SOURCE_LINE}" > "${BASHRC}"
    success "Created ${BASHRC} with prompt configuration."
fi

# Apply KWIN
apply_kwin_rules() {
    info "Checking for KDE KWin environment..."
    
    if command -v kwriteconfig5 &>/dev/null || command -v kwriteconfig6 &>/dev/null; then
        KWRITECMD="kwriteconfig5"
        command -v kwriteconfig6 &>/dev/null && KWRITECMD="kwriteconfig6"
        
        info "Applying KWin window rules for Foot terminal border radius / effects using ${KWRITECMD}..."
        
        RULE_GROUP="WindowMatchingRules_Foot_EndeavourOS"
        
        "${KWRITECMD}" --file kwinrulesrc --group "${RULE_GROUP}" --key Description "EndeavourOS Shell Foot Rules"
        "${KWRITECMD}" --file kwinrulesrc --group "${RULE_GROUP}" --key wmclass "foot"
        "${KWRITECMD}" --file kwinrulesrc --group "${RULE_GROUP}" --key wmclassmatch "1"
        "${KWRITECMD}" --file kwinrulesrc --group "${RULE_GROUP}" --key blockcompositingrule "2"
        
        if command -v qdbus &>/dev/null; then
            qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
        fi
        
        success "KWin window rules applied."
    else
        info "KDE KWin configuration tools not found. Skipping KWin rule setup."
    fi
}

apply_kwin_rules

# Finish
printf "\n"
printf "${GREEN}${BOLD}====================================================${NC}\n"
printf "${GREEN}${BOLD} Installation Complete!                            ${NC}\n"
printf "${GREEN}${BOLD}====================================================${NC}\n"
printf "To apply prompt changes immediately, run:\n"
printf "  ${CYAN}source ~/.bashrc${NC}\n\n"
