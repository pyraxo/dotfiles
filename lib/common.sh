#!/bin/bash
#
# common.sh - Common installation functions shared between platforms
#
# Usage: source "$(dirname "$0")/../lib/common.sh"
#
# Provides installation functions for tools used on both macOS and Linux.

# Source utils (which sources logging and colors)
# shellcheck source=utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# install_volta - Install Volta (Node.js version manager)
# Usage: install_volta
install_volta() {
    if command_exists volta; then
        success "Volta already installed ($(get_version volta))"
        return 0
    fi
    
    info "Installing Volta..."
    # SECURITY: Trusted vendor installation script
    curl -fsSL https://get.volta.sh | bash -s -- --skip-setup
    
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    
    success "Volta installed"
}

# install_nodejs - Install Node.js via Volta
# Usage: install_nodejs
install_nodejs() {
    require_command volta "Volta is required. Run install_volta first."
    
    info "Installing Node.js via Volta..."
    volta install node
    success "Node.js installed ($(get_version node))"
}

# install_pnpm - Install pnpm via Volta
# Usage: install_pnpm
install_pnpm() {
    require_command volta "Volta is required. Run install_volta first."
    
    info "Installing pnpm via Volta..."
    volta install pnpm
    success "pnpm installed ($(get_version pnpm))"
}

# install_bun - Install Bun JavaScript runtime
# Usage: install_bun
install_bun() {
    if command_exists bun; then
        success "Bun already installed ($(get_version bun))"
        return 0
    fi
    
    info "Installing Bun..."
    # SECURITY: Trusted vendor installation script
    curl -fsSL https://bun.sh/install | bash
    
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    
    success "Bun installed"
}

# install_uv - Install uv (Python package manager)
# Usage: install_uv
install_uv() {
    if command_exists uv; then
        success "uv already installed ($(get_version uv))"
        return 0
    fi
    
    info "Installing uv (Python package manager)..."
    # SECURITY: Trusted vendor installation script
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    export PATH="$HOME/.local/bin:$PATH"
    
    success "uv installed"
}

# install_codex_cli - Install OpenAI Codex CLI
# Usage: install_codex_cli
install_codex_cli() {
    if command_exists codex; then
        success "Codex CLI already installed"
        return 0
    fi
    
    require_command npm "npm is required. Install Node.js first."
    
    info "Installing Codex CLI..."
    
    # Configure npm to use global directory in user home to avoid permission issues
    if [[ ! -d "$HOME/.npm-global" ]]; then
        mkdir -p "$HOME/.npm-global"
        npm config set prefix "$HOME/.npm-global"
        
        # Add to PATH if not already there
        if ! grep -q 'npm-global/bin' "$HOME/.zshrc" 2>/dev/null; then
            echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.zshrc"
        fi
    fi
    
    export PATH="$HOME/.npm-global/bin:$PATH"
    npm install -g @openai/codex
    
    success "Codex CLI installed"
}

# setup_node_stack - Install complete Node.js development stack
# Usage: setup_node_stack
setup_node_stack() {
    install_volta
    install_nodejs
    install_pnpm
    install_bun
}

# Export functions
export -f install_volta install_nodejs install_pnpm install_bun \
       install_uv install_codex_cli setup_node_stack 2>/dev/null || true
