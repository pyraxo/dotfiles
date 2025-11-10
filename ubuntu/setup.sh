#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { printf "\r  [ ${BLUE}..${NC} ] $1\n"; }
success() { printf "\r\033[2K  [ ${GREEN}OK${NC} ] $1\n"; }

echo ""
echo -e "${BLUE}=== Linux (lab) Setup ===${NC}"
echo ""

# Update apt
info "Updating apt..."
sudo apt-get update -qq
success "apt updated"

# Install basic tools
info "Installing basic tools (git, curl, wget)..."
sudo apt-get install -y git curl wget build-essential
success "Basic tools installed"

# Install uv
echo ""
if ! command -v uv >/dev/null 2>&1; then
    info "Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    success "uv installed"
else
    success "uv already installed"
fi

# Install Volta
echo ""
if ! command -v volta >/dev/null 2>&1; then
    info "Installing Volta..."
    curl https://get.volta.sh | bash
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    success "Volta installed"
else
    success "Volta already installed"
fi

# Install Node.js and pnpm via Volta
info "Installing Node.js via Volta..."
volta install node
success "Node.js installed"

info "Installing pnpm via Volta..."
volta install pnpm
success "pnpm installed"

echo ""
success "Linux (lab) setup complete!"
echo ""
echo -e "${YELLOW}Note: You may need to restart your shell or run: source ~/.zshrc${NC}"
