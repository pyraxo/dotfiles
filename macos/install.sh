#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo -e "${GREEN}Homebrew installed successfully${NC}"
else
    echo -e "${BLUE}Homebrew already installed${NC}"
fi

# Check if gum is installed, install if not
if ! command -v gum >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing gum for interactive menu...${NC}"
    brew install gum
fi

echo ""
gum style --border normal --padding "1 2" --border-foreground 212 "macOS Package Installer" "Select packages to install using Homebrew"
echo ""

# Define brew packages with descriptions
declare -A BREW_PACKAGES
BREW_PACKAGES=(
    ["cloudflared"]="Cloudflare Tunnel client"
    ["imagemagick"]="Image manipulation tools and libraries"
    ["redis"]="In-memory data structure store"
    ["wireguard-tools"]="Fast, modern VPN tools"
    ["bitwarden-cli"]="Command-line interface for Bitwarden"
    ["cmake"]="Cross-platform build system"
    ["gh"]="GitHub CLI - GitHub from the command line"
    ["git-filter-repo"]="Tool for rewriting git history"
    ["nmap"]="Network exploration and security auditing"
    ["uv"]="Python package and project manager (fast)"
    ["go"]="Go programming language"
)

# Define cask packages with descriptions
declare -A CASK_PACKAGES
CASK_PACKAGES=(
    ["aerospace"]="Tiling window manager for macOS"
    ["flashspace"]="Workspace manager"
    ["linearmouse"]="Customize mouse/trackpad behavior"
    ["whatsapp"]="WhatsApp desktop application"
    ["raycast"]="Productivity launcher and tool"
    ["vlc"]="VLC media player"
    ["android-platform-tools"]="Android SDK platform tools (adb, fastboot)"
)

# Create options for brew packages
BREW_OPTIONS=()
for pkg in cloudflared imagemagick redis wireguard-tools bitwarden-cli cmake gh git-filter-repo nmap uv go; do
    # Check if already installed
    if brew list "$pkg" &>/dev/null; then
        status="✓"
    else
        status=" "
    fi
    BREW_OPTIONS+=("$status $pkg - ${BREW_PACKAGES[$pkg]}")
done

# Create options for cask packages
CASK_OPTIONS=()
for pkg in aerospace flashspace linearmouse whatsapp raycast vlc android-platform-tools; do
    # Check if already installed
    if brew list --cask "$pkg" &>/dev/null; then
        status="✓"
    else
        status=" "
    fi
    CASK_OPTIONS+=("$status $pkg - ${CASK_PACKAGES[$pkg]}")
done

# Select brew packages
echo -e "${BLUE}Select Homebrew packages (formulae):${NC}"
SELECTED_BREWS=$(printf "%s\n" "${BREW_OPTIONS[@]}" | gum choose --no-limit --height 15)

echo ""
# Select cask packages
echo -e "${BLUE}Select Homebrew casks (applications):${NC}"
SELECTED_CASKS=$(printf "%s\n" "${CASK_OPTIONS[@]}" | gum choose --no-limit --height 10)

# Extract package names from selections
BREW_TO_INSTALL=()
while IFS= read -r line; do
    if [ -n "$line" ]; then
        # Extract package name (remove status and description)
        pkg=$(echo "$line" | sed 's/^[✓ ]* //' | sed 's/ - .*//')
        # Only add if not already installed
        if ! brew list "$pkg" &>/dev/null; then
            BREW_TO_INSTALL+=("$pkg")
        fi
    fi
done <<< "$SELECTED_BREWS"

CASKS_TO_INSTALL=()
while IFS= read -r line; do
    if [ -n "$line" ]; then
        # Extract package name (remove status and description)
        pkg=$(echo "$line" | sed 's/^[✓ ]* //' | sed 's/ - .*//')
        # Only add if not already installed
        if ! brew list --cask "$pkg" &>/dev/null; then
            CASKS_TO_INSTALL+=("$pkg")
        fi
    fi
done <<< "$SELECTED_CASKS"

# Check if anything needs to be installed
if [ ${#BREW_TO_INSTALL[@]} -eq 0 ] && [ ${#CASKS_TO_INSTALL[@]} -eq 0 ]; then
    echo ""
    gum style --foreground 212 "No new packages to install. All selected packages are already installed."
    exit 0
fi

# Show summary
echo ""
echo -e "${YELLOW}Packages to install:${NC}"
if [ ${#BREW_TO_INSTALL[@]} -gt 0 ]; then
    echo -e "${BLUE}Formulae:${NC}"
    printf '  - %s\n' "${BREW_TO_INSTALL[@]}"
fi
if [ ${#CASKS_TO_INSTALL[@]} -gt 0 ]; then
    echo -e "${BLUE}Casks:${NC}"
    printf '  - %s\n' "${CASKS_TO_INSTALL[@]}"
fi
echo ""

# Confirm installation
if ! gum confirm "Proceed with installation?"; then
    echo "Installation cancelled."
    exit 0
fi

# Update Homebrew
echo ""
echo -e "${YELLOW}Updating Homebrew...${NC}"
brew update

# Install brew packages
if [ ${#BREW_TO_INSTALL[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Installing Homebrew formulae...${NC}"
    for pkg in "${BREW_TO_INSTALL[@]}"; do
        echo -e "${BLUE}Installing $pkg...${NC}"
        if brew install "$pkg"; then
            echo -e "${GREEN}✓ $pkg installed successfully${NC}"
        else
            echo -e "${RED}✗ Failed to install $pkg${NC}"
        fi
    done
fi

# Install cask packages
if [ ${#CASKS_TO_INSTALL[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Installing Homebrew casks...${NC}"
    for pkg in "${CASKS_TO_INSTALL[@]}"; do
        echo -e "${BLUE}Installing $pkg...${NC}"
        if brew install --cask "$pkg"; then
            echo -e "${GREEN}✓ $pkg installed successfully${NC}"
        else
            echo -e "${RED}✗ Failed to install $pkg${NC}"
        fi
    done
fi

echo ""
gum style --border double --padding "1 2" --border-foreground 212 --foreground 212 "Installation Complete!"
echo ""
echo -e "${GREEN}All selected packages have been installed.${NC}"
