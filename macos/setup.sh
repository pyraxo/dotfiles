#!/bin/bash
#
# macos/setup.sh - macOS (home) setup script
#
# Installs Homebrew, packages from Brewfile, and development tools.

set -eu

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Source shared libraries
# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"

header "macOS (home) Setup"

# ============================================================================
# Homebrew
# ============================================================================

install_homebrew() {
    if command_exists brew; then
        success "Homebrew already installed ($(get_version brew))"
        return 0
    fi
    
    info "Installing Homebrew..."
    # SECURITY: Trusted vendor installation script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    success "Homebrew installed"
}

# ============================================================================
# Brewfile packages
# ============================================================================

install_brewfile_packages() {
    local brewfile="$REPO_DIR/Brewfile"
    
    if [[ ! -f "$brewfile" ]]; then
        warn "Brewfile not found at $brewfile"
        return 1
    fi
    
    info "Installing packages from Brewfile..."
    brew bundle --file="$brewfile"
    success "Brewfile packages installed"
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    # Install Homebrew
    install_homebrew
    
    # Install Brewfile packages
    install_brewfile_packages
    
    echo ""
    
    # Install Node.js development stack
    install_volta
    install_nodejs
    install_pnpm
    
    echo ""
    
    # Install Bun
    install_bun
    
    echo ""
    
    # Install Codex CLI
    install_codex_cli
    
    echo ""
    success "macOS (home) setup complete!"
}

main "$@"
