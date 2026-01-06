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
- **GUI apps** - flashspace, linearmouse, raycast, etc.
- **Volta** - Node.js version manager
- **Node.js & pnpm** - Via Volta
- **Bun** - JavaScript runtime
- **Codex CLI** - OpenAI Codex command-line tool
- **Oh My Zsh** - Shell framework
- **Dotfiles** - Shell configuration and custom scripts

### lab (Linux)
- **Basic tools** - git, curl, wget, build-essential
- **uv** - Python package manager
- **Volta** - Node.js version manager
- **Node.js & pnpm** - Via Volta
- **Bun** - JavaScript runtime
- **Oh My Zsh** - Shell framework
- **Dotfiles** - Shell configuration and custom scripts

## Structure

```
dotfiles/
├── install.sh          # Main installer (run this)
├── Brewfile            # macOS packages (home only)
├── VERSION             # Current version
├── CHANGELOG.md        # Change history
├── lib/                # Shared shell libraries
│   ├── colors.sh       # Terminal colors
│   ├── logging.sh      # Logging functions
│   ├── utils.sh        # Utility functions
│   └── common.sh       # Common installation functions
├── macos/
│   ├── setup.sh        # macOS setup script
│   ├── install.sh      # Interactive package selector
│   └── set-defaults.sh # macOS system defaults
├── ubuntu/
│   ├── setup.sh        # Ubuntu setup script
│   └── install.sh      # Interactive package selector
├── config/
│   └── .zshrc          # Shell configuration
├── bin/                # Custom scripts (added to PATH)
└── scripts/            # Additional setup scripts
```

## CLI Tools

All tools in `bin/` are automatically added to your PATH.

### Core Management

| Command | Description |
|---------|-------------|
| `dot` | Dotfiles management (update, status, doctor, backup, sync) |
| `dot setup` | First-time configuration |
| `dot status` | Show installed tool versions |
| `dot doctor` | Diagnose configuration issues |
| `dot backup` | Create system state backup |
| `dot restore` | Restore from backup |
| `dot sync` | Sync with remote repository |

### Git Shortcuts (`.g`)

| Command | Description |
|---------|-------------|
| `.g cl <repo>` | Clone repository (SSH first, then HTTPS) |
| `.g i` | Initialize repo with initial commit |
| `.g ac <msg>` | Add all and commit |
| `.g acp <msg>` | Add, commit, and push |
| `.g d` | Show diff |
| `.g ds` | Show staged diff |
| `.g l` | Show last 10 commits |
| `.g ll` | Show commit graph |
| `.g st` | Stash changes |
| `.g sta` | Apply stash |
| `.g b` | List branches |
| `.g bc <name>` | Create branch |
| `.g bs <name>` | Switch branch |
| `.g rs` | Reset soft |
| `.g rh` | Reset hard |
| `.g loc` | Lines of code changed (24h) |

Run `.g --help` for the complete list.

### API Key Management (`.k`)

| Command | Description |
|---------|-------------|
| `.k` | Sync API keys between .env and config |
| `.k i` | Interactive mode to add new keys |
| `.k l` | List all stored keys |
| `.k l <name>` | Show specific key value |

### Other Tools

| Command | Description |
|---------|-------------|
| `.a` | Alias manager |
| `.b` | PATH manager |
| `.bi` | Brew install with Brewfile sync |
| `.cw` | Chat with files (LLM context) |
| `.pi` | Project initializer for AI coding |
| `.ssh` | SSH key export utility |
| `.t` | Tmux session manager |
| `envxtract` | Encrypted .env backup/restore |

## Configuration

### Dotfiles Location

The dotfiles location is saved on first run to:
```
~/.config/dotfiles/config
```

You can change it with:
```bash
dot setup
```

### API Keys

API keys are stored in `~/.config/@cli/config` and synced to project `.env` files using `.k`.

## Usage

### Initial Setup

Just run `./install.sh` and follow the prompts.

### Updating

```bash
dot              # Update dotfiles and packages
dot sync         # Two-way sync with remote
dot -f           # Force update (discard local changes)
```

### System Health

```bash
dot status       # Show installed tool versions
dot doctor       # Check for configuration issues
```

### Backup & Restore

```bash
dot backup       # Create backup
dot restore      # List available backups
dot restore <file>  # Restore from backup
```

### Adding Packages

**macOS:**
```bash
.bi <package>    # Auto-detect and install, update Brewfile
.bi -c <app>     # Install as cask
```

**Linux:**
Edit `ubuntu/setup.sh` to add apt packages.

## Shell Aliases

Default aliases in `config/.zshrc`:

```bash
.cc   # claude --dangerously-skip-permissions
.ccc  # claude --continue --dangerously-skip-permissions
```

Custom aliases can be added to `.aliases`.

## Requirements

- **macOS**: macOS 10.15+
- **Linux**: Ubuntu 20.04+ or Debian-based distro
- **Shell**: zsh (installed automatically)
- **Internet**: Required for downloading packages

## Troubleshooting

### Command not found after install
```bash
source ~/.zshrc
```

### Check configuration issues
```bash
dot doctor
```

### Homebrew issues (macOS)
```bash
brew update
brew doctor
```

### Oh My Zsh already installed
The installer will detect and skip. For fresh install:
```bash
rm -rf ~/.oh-my-zsh
./install.sh
```

### envxtract missing cryptography
```bash
pip3 install cryptography
# or
uv pip install cryptography
```

## License

MIT
