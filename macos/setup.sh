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
echo -e "${BLUE}=== macOS (home) Setup ===${NC}"
echo ""

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

# Install packages from Brewfile
info "Installing packages from Brewfile..."
brew bundle --file="$REPO_DIR/Brewfile"
success "Brewfile packages installed"

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

# Install Codex CLI
echo ""
if ! command -v codex >/dev/null 2>&1; then
    info "Installing Codex CLI..."
    npm install -g @openai/codex
    success "Codex CLI installed"
else
    success "Codex CLI already installed"
fi

echo ""
success "macOS (home) setup complete!"
