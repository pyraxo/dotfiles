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

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo -e "${GREEN}Homebrew installed successfully${NC}"
else
    echo -e "${BLUE}Homebrew already installed${NC}"
fi

# Check if Node.js/npm is available
if ! command -v npm >/dev/null 2>&1; then
    echo -e "${YELLOW}npm not found. Installing Node.js via Homebrew...${NC}"
    brew install node
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

# Install Claude Code
echo ""
if brew list --cask claude-code &>/dev/null; then
    echo -e "${BLUE}Claude Code already installed${NC}"
else
    echo -e "${YELLOW}Installing Claude Code...${NC}"
    brew install --cask claude-code
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Claude Code installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install Claude Code${NC}"
    fi
fi

echo ""
echo -e "${GREEN}AI Development Tools setup complete!${NC}"
echo ""
echo "Installed tools:"
echo "  - OpenAI Codex CLI (codex)"
echo "  - Claude Code"
echo ""
