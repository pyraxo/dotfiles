#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if whiptail is available, install if not
if ! command -v whiptail >/dev/null 2>&1; then
    echo "Installing whiptail for interactive menu..."
    sudo apt-get update -qq
    sudo apt-get install -y whiptail
fi

# Define packages with their descriptions
declare -A PACKAGES
PACKAGES=(
    ["imagemagick"]="Image manipulation tools and libraries"
    ["redis-server"]="In-memory data structure store"
    ["wireguard-tools"]="Fast, modern VPN tools"
    ["cmake"]="Cross-platform build system"
    ["nmap"]="Network exploration and security auditing"
    ["golang-go"]="Go programming language"
    ["build-essential"]="Essential compilation tools (gcc, make, etc.)"
    ["gh"]="GitHub CLI - GitHub from the command line"
    ["cloudflared"]="Cloudflare Tunnel client"
    ["git-filter-repo"]="Tool for rewriting git history"
    ["volta"]="Node.js version manager (fast, reliable)"
    ["uv"]="Python package and project manager (fast)"
)

# Create checklist options (package_name "description" status)
OPTIONS=()
for pkg in imagemagick redis-server wireguard-tools cmake nmap golang-go build-essential gh cloudflared git-filter-repo volta uv; do
    # Check if already installed
    status="OFF"
    if [[ "$pkg" == "build-essential" ]]; then
        if dpkg -l | grep -q "^ii  build-essential"; then
            status="ON"
        fi
    elif [[ "$pkg" == "golang-go" ]]; then
        if command -v go >/dev/null 2>&1; then
            status="ON"
        fi
    elif command -v "${pkg%%-*}" >/dev/null 2>&1 || command -v "$pkg" >/dev/null 2>&1; then
        status="ON"
    fi

    OPTIONS+=("$pkg" "${PACKAGES[$pkg]}" "$status")
done

# Show interactive checklist
CHOICES=$(whiptail --title "Ubuntu Package Installer" \
    --checklist "\nSelect packages to install (use SPACE to select, ENTER to confirm):" \
    24 78 14 \
    "${OPTIONS[@]}" \
    3>&1 1>&2 2>&3)

# Check if user cancelled
if [ $? -ne 0 ]; then
    echo "Installation cancelled."
    exit 0
fi

# Remove quotes from selections
SELECTED=$(echo "$CHOICES" | tr -d '"')

# Check if any packages were selected
if [ -z "$SELECTED" ]; then
    echo "No packages selected. Exiting."
    exit 0
fi

echo -e "${BLUE}Selected packages:${NC}"
for pkg in $SELECTED; do
    echo "  - $pkg"
done
echo ""

# Update package list
echo -e "${YELLOW}Updating apt package list...${NC}"
sudo apt-get update

# Arrays to track what needs installing
declare -a APT_PACKAGES
declare -a SPECIAL_PACKAGES

# Categorize selected packages
for pkg in $SELECTED; do
    case $pkg in
        imagemagick|redis-server|wireguard-tools|cmake|nmap|golang-go|build-essential)
            APT_PACKAGES+=("$pkg")
            ;;
        gh|cloudflared|git-filter-repo|volta|uv)
            SPECIAL_PACKAGES+=("$pkg")
            ;;
    esac
done

# Install APT packages
if [ ${#APT_PACKAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}Installing packages via apt...${NC}"
    # Ensure curl and wget are available for later installations
    sudo apt-get install -y curl wget
    sudo apt-get install -y "${APT_PACKAGES[@]}"
    echo -e "${GREEN}APT packages installed successfully${NC}"
fi

# Install special packages
for pkg in "${SPECIAL_PACKAGES[@]}"; do
    case $pkg in
        gh)
            if ! command -v gh >/dev/null 2>&1; then
                echo -e "${YELLOW}Installing GitHub CLI...${NC}"
                type -p curl >/dev/null || sudo apt-get install -y curl
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt-get update
                sudo apt-get install -y gh
                echo -e "${GREEN}GitHub CLI installed successfully${NC}"
            else
                echo -e "${BLUE}GitHub CLI already installed${NC}"
            fi
            ;;
        cloudflared)
            if ! command -v cloudflared >/dev/null 2>&1; then
                echo -e "${YELLOW}Installing cloudflared...${NC}"
                curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
                echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
                sudo apt-get update
                sudo apt-get install -y cloudflared
                echo -e "${GREEN}cloudflared installed successfully${NC}"
            else
                echo -e "${BLUE}cloudflared already installed${NC}"
            fi
            ;;
        git-filter-repo)
            if ! command -v git-filter-repo >/dev/null 2>&1; then
                echo -e "${YELLOW}Installing git-filter-repo...${NC}"
                # Install pipx if not available
                if ! command -v pipx >/dev/null 2>&1; then
                    echo -e "${YELLOW}Installing pipx...${NC}"
                    sudo apt-get install -y pipx
                    pipx ensurepath
                fi
                # Install git-filter-repo via pipx
                pipx install git-filter-repo
                echo -e "${GREEN}git-filter-repo installed successfully${NC}"
                echo -e "${YELLOW}Note: You may need to restart your shell or run: source ~/.bashrc (or ~/.zshrc)${NC}"
            else
                echo -e "${BLUE}git-filter-repo already installed${NC}"
            fi
            ;;
        volta)
            if ! command -v volta >/dev/null 2>&1; then
                echo -e "${YELLOW}Installing Volta...${NC}"
                curl https://get.volta.sh | bash
                echo -e "${GREEN}Volta installed successfully${NC}"
                echo -e "${YELLOW}Note: You may need to restart your shell or run: source ~/.bashrc (or ~/.zshrc)${NC}"
            else
                echo -e "${BLUE}Volta already installed${NC}"
            fi
            ;;
        uv)
            if ! command -v uv >/dev/null 2>&1; then
                echo -e "${YELLOW}Installing uv...${NC}"
                curl -LsSf https://astral.sh/uv/install.sh | sh
                echo -e "${GREEN}uv installed successfully${NC}"
            else
                echo -e "${BLUE}uv already installed${NC}"
            fi
            ;;
    esac
done

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Installed packages:"
for pkg in $SELECTED; do
    echo "  - $pkg"
done
echo ""
echo -e "${YELLOW}Note: Some tools (volta, uv) may require you to restart your shell or source your shell config.${NC}"
