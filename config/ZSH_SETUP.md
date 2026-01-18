# Fast ZSH Setup Guide

This guide explains how to use the fast, portable ZSH configuration on both local machines and remote servers.

## Architecture

The setup uses a **layered configuration** approach:

```
~/.zshrc (machine-specific)
    └─> ~/Projects/dotfiles/config/.zshrc (dotfiles bootstrap)
            └─> ~/Projects/dotfiles/config/.zshrc.fast (portable, fast config)
```

### Key Files

- **`~/.zshrc`** - Machine-specific settings (PATH, functions, aliases unique to this computer)
- **`config/.zshrc`** - Dotfiles bootstrap (detects dotfiles dir, sources .zshrc.fast)
- **`config/.zshrc.fast`** - Portable, fast ZSH config (works everywhere, graceful fallbacks)
- **`bin/install-zsh-fast`** - Installation script for setting up on new machines

## Local Setup (Already Done)

Your local machine is already configured with:
- ✅ zsh-snap plugin manager
- ✅ Starship prompt
- ✅ Fast startup (~75ms)
- ✅ All your existing aliases and functions

## Remote Server Setup (tinymart)

### Option 1: Full Setup (Recommended)

SSH to your server and run:

```bash
# 1. Clone dotfiles (if not already)
git clone https://github.com/yourusername/dotfiles.git ~/Projects/dotfiles

# 2. Run install script with Starship
~/Projects/dotfiles/bin/install-zsh-fast --starship
```

This will:
- Install zsh-snap plugin manager
- Install Starship prompt
- Configure ~/.zshrc to source dotfiles config
- Backup existing .zshrc

### Option 2: Minimal Setup (No Starship)

If you don't want/need Starship on the server:

```bash
# Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/Projects/dotfiles

# Install without Starship (uses minimal fallback prompt)
~/Projects/dotfiles/bin/install-zsh-fast
```

The config will automatically use a clean minimal prompt with git status.

### Option 3: Manual Setup

If you can't run the install script:

```bash
# 1. Install zsh-snap
git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git ~/.zsh-snap

# 2. Create ~/.zshrc
cat > ~/.zshrc << 'EOF'
# Source dotfiles configuration
[[ -f "$HOME/Projects/dotfiles/config/.zshrc" ]] && source "$HOME/Projects/dotfiles/config/.zshrc"
EOF

# 3. Clone dotfiles if needed
git clone https://github.com/yourusername/dotfiles.git ~/Projects/dotfiles
```

## Customizing for Each Machine

### Machine-Specific Settings

Edit `~/.zshrc` on each machine to add:

```bash
# Machine-specific PATH
export VOLTA_HOME="$HOME/.volta"
path=("$VOLTA_HOME/bin" $path)

# Machine-specific aliases
alias deploy='ssh production'

# Machine-specific functions
function backup() {
  rsync -av /data /backup
}
```

### Shared Settings

Edit `~/Projects/dotfiles/config/.zshrc.fast` for settings you want everywhere:

```bash
# Shared aliases
alias ll='ls -lah'
alias g='git'

# Shared functions
function mkcd() {
  mkdir -p "$1" && cd "$1"
}
```

Then commit and push to git:

```bash
cd ~/Projects/dotfiles
git add config/.zshrc.fast
git commit -m "Add shared alias"
git push
```

Pull on other machines:

```bash
cd ~/Projects/dotfiles
git pull
source ~/.zshrc  # Reload
```

## What Gets Installed

### zsh-snap
- Fast plugin manager (~200 lines of code)
- Automatic plugin downloads on first load
- Async loading for speed
- Plugins installed:
  - `zsh-syntax-highlighting` - highlights commands
  - `zsh-autosuggestions` - suggests from history
  - `ohmyzsh/git` - git aliases (g, gst, gco, etc.)

### Starship (optional)
- Fast prompt written in Rust
- Shows git status, language versions, etc.
- Cross-shell compatible
- Highly customizable via `~/.config/starship.toml`

### Fallback Mode (No Starship)
- Clean minimal prompt: `user@host ~/path (branch) $ `
- Shows current directory
- Shows git branch (if in git repo)
- No external dependencies

## Performance

**Expected startup times:**
- First load: ~4-5 seconds (downloads plugins once)
- Subsequent loads: ~75-100ms

**Measure your startup time:**
```bash
time zsh -i -c exit
```

## Troubleshooting

### Plugins not loading
First load downloads plugins. If it fails:
```bash
# Manually download plugins
~/.zsh-snap/znap.zsh pull
```

### Starship not found
```bash
# Install manually (Linux)
curl -sS https://starship.rs/install.sh | sh

# Install manually (macOS)
brew install starship
```

### Config not loading
Check that dotfiles path is correct in `~/.zshrc`:
```bash
grep dotfiles ~/.zshrc
```

## Rollback

If something breaks, restore your backup:

```bash
# Find your backup
ls -l ~/.zshrc.backup-*

# Restore it
cp ~/.zshrc.backup-YYYYMMDD-HHMMSS ~/.zshrc
source ~/.zshrc
```

## Advanced: Syncing to Multiple Servers

Create a sync script to deploy to all your servers:

```bash
#!/bin/bash
# deploy-zsh.sh

SERVERS=(
  "tinymart"
  "prod-server"
  "dev-box"
)

for server in "${SERVERS[@]}"; do
  echo "Deploying to $server..."
  ssh "$server" "cd ~/Projects/dotfiles && git pull && source ~/.zshrc"
done
```

## Tips

1. **Keep ~/.zshrc minimal** - Only machine-specific stuff
2. **Put shared config in .zshrc.fast** - Committed to git
3. **Use .aliases file** - For project-specific aliases
4. **Test changes locally** - Before deploying to servers
5. **Version control everything** - Commit and push often

## Further Reading

- [zsh-snap documentation](https://github.com/marlonrichert/zsh-snap)
- [Starship documentation](https://starship.rs/)
- [ZSH performance tips](https://htr3n.github.io/2018/07/faster-zsh/)
