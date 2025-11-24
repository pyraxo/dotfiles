#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}AI Development Tools Setup${NC}"
echo ""

# Check if npm is available
if ! command -v npm >/dev/null 2>&1; then
    echo -e "${YELLOW}npm not found. Installing Node.js...${NC}"

    # Check if volta is installed
    if command -v volta >/dev/null 2>&1; then
        echo -e "${BLUE}Using Volta to install Node.js...${NC}"
        volta install node
    else
        echo -e "${BLUE}Installing Node.js via apt...${NC}"
        sudo apt-get update
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
fi

# Install OpenAI Codex CLI
echo ""
if command -v codex >/dev/null 2>&1; then
    echo -e "${BLUE}OpenAI Codex CLI already installed${NC}"
else
    echo -e "${YELLOW}Installing OpenAI Codex CLI...${NC}"

    # Configure npm to use global directory in user home to avoid permission issues
    if [ ! -d "$HOME/.npm-global" ]; then
        mkdir -p "$HOME/.npm-global"
        npm config set prefix "$HOME/.npm-global"

        # Add to PATH if not already there
        if ! grep -q 'npm-global/bin' "$HOME/.zshrc" 2>/dev/null; then
            echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.zshrc"
        fi
        export PATH="$HOME/.npm-global/bin:$PATH"
    fi

    npm install -g @openai/codex
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ OpenAI Codex CLI installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install OpenAI Codex CLI${NC}"
    fi
fi

# Install Claude Code
echo ""
if command -v claude >/dev/null 2>&1; then
    echo -e "${BLUE}Claude Code already installed${NC}"
else
    echo -e "${YELLOW}Installing Claude Code...${NC}"

    if curl -fsSL https://claude.ai/install.sh | bash; then
        echo -e "${GREEN}✓ Claude Code installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install Claude Code${NC}"
        echo -e "${YELLOW}You can manually run: curl -fsSL https://claude.ai/install.sh | bash${NC}"
    fi
fi

echo ""
echo -e "${GREEN}AI Development Tools setup complete!${NC}"
echo ""
echo "Installed tools:"
echo "  - OpenAI Codex CLI (codex)"
echo "  - Claude Code"
echo ""
echo -e "${YELLOW}Note: You may need to restart your shell or add ~/.local/bin to your PATH${NC}"
