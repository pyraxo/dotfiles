#!/bin/bash

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    printf "\r  [ ${BLUE}..${NC} ] $1\n"
}

user() {
    printf "\r  [ ${YELLOW}??${NC} ] $1\n"
}

success() {
    printf "\r\033[2K  [ ${GREEN}OK${NC} ] $1\n"
}

fail() {
    printf "\r\033[2K  [${RED}FAIL${NC}] $1\n"
    echo ''
}

banner() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                    ║${NC}"
    echo -e "${BLUE}║      Dotfiles Setup Installer      ║${NC}"
    echo -e "${BLUE}║                                    ║${NC}"
    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo ""
}

banner

# Ask which setup type
user "Which setup are you configuring?"
echo "  1) home  - macOS work laptop"
echo "  2) lab   - Linux server/homelab"
echo ""
read -p "Enter choice [1-2]: " setup_choice

case $setup_choice in
    1)
        SETUP_TYPE="home"
        info "Selected: home (macOS)"
        ;;
    2)
        SETUP_TYPE="lab"
        info "Selected: lab (Linux)"
        ;;
    *)
        fail "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""

# Install zsh if on Linux and not already installed
if [ "$SETUP_TYPE" = "lab" ]; then
    info "Checking for zsh..."
    if ! command -v zsh >/dev/null 2>&1; then
        info "Installing zsh..."
        sudo apt-get install -y zsh
        success "zsh installed"
    else
        success "zsh already installed"
    fi
fi

# Install Oh My Zsh
info "Checking for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh installed"
else
    success "Oh My Zsh already installed"
fi

# Set up zshrc
ZSHRC="$HOME/.zshrc"
REPO_ZSHRC="$REPO_DIR/config/.zshrc"

info "Configuring zsh..."
if [ -f "$ZSHRC" ] && [ ! -L "$ZSHRC" ]; then
    if ! grep -q "source $REPO_ZSHRC" "$ZSHRC"; then
        echo "" >> "$ZSHRC"
        echo "# Source dotfiles repo zshrc" >> "$ZSHRC"
        echo "source $REPO_ZSHRC" >> "$ZSHRC"
        success "Appended source line to $ZSHRC"
    else
        info "Zshrc already configured"
    fi
elif [ ! -e "$ZSHRC" ]; then
    ln -s "$REPO_ZSHRC" "$ZSHRC"
    success "Created symlink: $ZSHRC -> $REPO_ZSHRC"
else
    info "Zshrc symlink already exists"
fi

# Add bin to PATH
if ! grep -q "export PATH=\"$REPO_DIR/bin:\$PATH\"" "$ZSHRC"; then
    echo "" >> "$ZSHRC"
    echo "# Add dotfiles bin to PATH" >> "$ZSHRC"
    echo "export PATH=\"$REPO_DIR/bin:\$PATH\"" >> "$ZSHRC"
    success "Added bin directory to PATH"
else
    info "Bin already in PATH"
fi

# Add bin to current session
export PATH="$REPO_DIR/bin:$PATH"

echo ""

# Generate SSH key if it doesn't exist
info "Checking for SSH key..."
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    info "Generating SSH key (id_ed25519)..."
    ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
    success "SSH key generated at $HOME/.ssh/id_ed25519"
    echo ""
    echo -e "${YELLOW}Your SSH public key:${NC}"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
else
    success "SSH key already exists"
fi

echo ""

# Run setup based on type
if [ "$SETUP_TYPE" = "home" ]; then
    info "Running macOS (home) setup..."
    bash "$REPO_DIR/macos/setup.sh"
elif [ "$SETUP_TYPE" = "lab" ]; then
    info "Running Linux (lab) setup..."
    bash "$REPO_DIR/ubuntu/setup.sh"
fi

echo ""
success "Setup complete!"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Check that everything works"
echo ""
