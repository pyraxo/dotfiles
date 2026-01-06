#!/bin/bash
#
# ubuntu/setup.sh - Linux (lab) setup script
#
# Installs development tools for Ubuntu/Debian systems.

set -eu

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Source shared libraries
# shellcheck source=../lib/common.sh
source "$REPO_DIR/lib/common.sh"

header "Linux (lab) Setup"

# ============================================================================
# APT Packages
# ============================================================================

install_apt_packages() {
    info "Updating apt..."
    sudo apt-get update -qq
    success "apt updated"
    
    info "Installing basic tools (git, curl, wget, build-essential)..."
    sudo apt-get install -y git curl wget build-essential
    success "Basic tools installed"
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
    # Install APT packages
    install_apt_packages
    
    echo ""
    
    # Install uv (Python package manager)
    install_uv
    
    echo ""
    
    # Install Node.js development stack
    install_volta
    install_nodejs
    install_pnpm
    
    echo ""
    
    # Install Bun
    install_bun
    
    echo ""
    success "Linux (lab) setup complete!"
    echo ""
    echo -e "${YELLOW}Note: You may need to restart your shell or run: source ~/.zshrc${NC}"
}

main "$@"
