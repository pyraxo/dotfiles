#!/bin/bash
#
# macos/ai-setup.sh - Install AI development tools on macOS
#

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# shellcheck source=../lib/utils.sh
source "$REPO_DIR/lib/utils.sh"

header "AI Development Tools Setup"

# Ensure Homebrew is available
if ! command_exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    success "Homebrew installed"
fi

# Ensure npm is available
if ! command_exists npm; then
    info "npm not found, installing Node.js via Homebrew..."
    brew install node
fi

# Install OpenAI Codex CLI
if command_exists codex; then
    success "Codex CLI already installed"
else
    info "Installing Codex CLI..."

    # Configure npm global directory to avoid permission issues
    if [ ! -d "$HOME/.npm-global" ]; then
        mkdir -p "$HOME/.npm-global"
        npm config set prefix "$HOME/.npm-global"
    fi
    export PATH="$HOME/.npm-global/bin:$PATH"

    if npm install -g @openai/codex; then
        success "Codex CLI installed"
    else
        fail "Failed to install Codex CLI"
    fi
fi

# Install Claude Code
if command_exists claude; then
    success "Claude Code already installed"
else
    info "Installing Claude Code..."
    if curl -fsSL https://claude.ai/install.sh | bash; then
        success "Claude Code installed"
    else
        fail "Failed to install Claude Code"
    fi
fi

echo ""
success "AI Development Tools setup complete!"
