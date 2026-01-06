# Dotfiles shell configuration
#
# This file is sourced by ~/.zshrc to configure the dotfiles environment.

# ============================================================================
# Dotfiles Directory Detection
# ============================================================================

# Try to load from saved config first (fastest)
_DOTFILES_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/config"
if [[ -f "$_DOTFILES_CONFIG" ]]; then
    # shellcheck source=/dev/null
    source "$_DOTFILES_CONFIG" 2>/dev/null
fi

# Fallback: detect from this file's location
if [[ -z "${DOTFILES_DIR:-}" ]]; then
    # ${0:A:h:h} resolves symlinks and gets grandparent directory
    DOTFILES_DIR="${0:A:h:h}"
fi

export DOTFILES_DIR

# ============================================================================
# PATH Configuration
# ============================================================================

# Add bin directory to PATH if not already present
if [[ ":$PATH:" != *":$DOTFILES_DIR/bin:"* ]]; then
    export PATH="$DOTFILES_DIR/bin:$PATH"
fi

# ============================================================================
# Aliases
# ============================================================================

# Source aliases from .aliases file
if [[ -f "$DOTFILES_DIR/.aliases" ]]; then
    source "$DOTFILES_DIR/.aliases"
fi

# Claude Code shortcuts
alias .cc='claude --dangerously-skip-permissions'
alias .ccc='claude --continue --dangerously-skip-permissions'

# ============================================================================
# Auto-load .env files (optional, enable if you want direnv-like behavior)
# ============================================================================

# Uncomment to enable automatic .env loading when changing directories
# autoload -U add-zsh-hook
# _load_dotenv() {
#     if [[ -f .env && -r .env ]]; then
#         set -a
#         source .env
#         set +a
#     fi
# }
# add-zsh-hook chpwd _load_dotenv
# _load_dotenv  # Load on shell start
