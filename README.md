# Dotfiles

Personal dotfiles for macOS (home) and Linux (lab) environments.

## Quick Start

```bash
git clone <your-repo-url> ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

You'll be prompted to choose:
- **home** - macOS work laptop setup
- **lab** - Linux server/homelab setup

## What Gets Installed

### home (macOS)
- **Homebrew packages** - All packages from Brewfile (git, gh, ripgrep, fzf, etc.)
- **GUI apps** - aerospace, flashspace, linearmouse, etc.
- **Volta** - Node.js version manager
- **Node.js & pnpm** - Via Volta
- **Codex CLI** - OpenAI Codex command-line tool
- **Oh My Zsh** - Shell framework
- **Dotfiles** - Shell configuration and custom scripts

### lab (Linux)
- **Basic tools** - git, curl, wget, build-essential
- **uv** - Python package manager
- **Volta** - Node.js version manager
- **Node.js & pnpm** - Via Volta
- **Oh My Zsh** - Shell framework
- **Dotfiles** - Shell configuration and custom scripts

## Structure

```
dotfiles/
├── install.sh          # Main installer (run this)
├── Brewfile            # macOS packages (home only)
├── macos/
│   ├── setup.sh        # macOS setup script
│   └── install.sh      # Interactive package selector
├── ubuntu/
│   └── setup.sh        # Ubuntu setup script
├── config/
│   └── .zshrc          # Shell configuration
└── bin/                # Custom scripts (added to PATH)
```

## Usage

### Initial Setup

Just run `./install.sh` and follow the prompts.

### Updating Packages (macOS)

```bash
# Update Brewfile packages
brew bundle --file=~/Projects/dotfiles/Brewfile

# Or use the interactive installer
~/Projects/dotfiles/macos/install.sh
```

### Adding New Packages

**For macOS (home):**
Edit `Brewfile` and add packages:
```ruby
brew 'package-name'
cask 'app-name'
```

**For Linux (lab):**
Edit `ubuntu/setup.sh` and add apt packages or installation commands.

## Custom Scripts

All scripts in `bin/` are automatically added to your PATH. Create new scripts there for quick access.

## Requirements

- **macOS**: macOS 10.15+
- **Linux**: Ubuntu 20.04+ or Debian-based distro
- **Shell**: zsh (installed automatically)
- **Internet**: Required for downloading packages

## Troubleshooting

### Command not found after install
Restart your terminal or run:
```bash
source ~/.zshrc
```

### Homebrew issues
Update Homebrew:
```bash
brew update
brew doctor
```

### Oh My Zsh already installed
The installer will detect and skip if already present. If you want a fresh install:
```bash
rm -rf ~/.oh-my-zsh
./install.sh
```

### envxtract missing cryptography library
If you get an import error when running `envxtract`:
```bash
pip3 install cryptography
# or
uv pip install cryptography
```
