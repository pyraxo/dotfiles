#!/bin/bash
#
# install.sh - Main dotfiles installer
#
# This script sets up your development environment on macOS or Linux.

set -eu

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source shared libraries
# shellcheck source=lib/logging.sh
source "$REPO_DIR/lib/logging.sh"
# shellcheck source=lib/utils.sh
source "$REPO_DIR/lib/utils.sh"

banner "Dotfiles Setup Installer"

# Save dotfiles directory for future use
save_dotfiles_dir "$REPO_DIR"
success "Saved dotfiles location to config"

# Ask which setup type
user "Which setup are you configuring?"
echo "  1) home  - macOS work laptop"
echo "  2) lab   - Linux server/homelab"
echo ""
read -rp "Enter choice [1-2]: " setup_choice

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

# Set zsh as default shell if it isn't already
ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    info "Setting zsh as default shell..."
    chsh -s "$ZSH_PATH"
    success "Default shell set to zsh"
else
    success "zsh is already the default shell"
fi

# Install fast zsh config (zsh-snap + optional Starship)
info "Setting up fast zsh configuration..."
bash "$REPO_DIR/scripts/install-zsh-fast" --skip-backup
success "Fast zsh configuration installed"

# Add bin to PATH in .zshrc if not already there
ZSHRC="$HOME/.zshrc"
if ! grep -q "export PATH=\"$REPO_DIR/bin:\$PATH\"" "$ZSHRC"; then
    {
        echo ""
        echo "# Add dotfiles bin to PATH"
        echo "export PATH=\"$REPO_DIR/bin:\$PATH\""
    } >> "$ZSHRC"
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
