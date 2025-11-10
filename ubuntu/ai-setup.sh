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
    npm install -g @openai/codex
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ OpenAI Codex CLI installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install OpenAI Codex CLI${NC}"
    fi
fi

# Install Claude Code (AppImage for Linux)
echo ""
if [ -f "$HOME/.local/bin/claude-code" ] || command -v claude-code >/dev/null 2>&1; then
    echo -e "${BLUE}Claude Code already installed${NC}"
else
    echo -e "${YELLOW}Installing Claude Code...${NC}"

    # Create local bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Download and install Claude Code AppImage
    echo -e "${BLUE}Downloading Claude Code...${NC}"
    CLAUDE_URL="https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-tagged/2025-04-30/claude-code_2025-04-30_amd64.AppImage"

    if curl -L "$CLAUDE_URL" -o "$HOME/.local/bin/claude-code"; then
        chmod +x "$HOME/.local/bin/claude-code"
        echo -e "${GREEN}✓ Claude Code installed successfully${NC}"
        echo -e "${YELLOW}Note: Make sure $HOME/.local/bin is in your PATH${NC}"
    else
        echo -e "${RED}✗ Failed to download Claude Code${NC}"
        echo -e "${YELLOW}You can manually download it from: https://claude.ai/download${NC}"
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
