#!/bin/bash
#
# utils.sh - Common utility functions
#
# Usage: source "$(dirname "$0")/../lib/utils.sh"
#
# Provides common utilities used across multiple scripts.
# Automatically sources logging.sh (which sources colors.sh).

# Source logging if not already loaded
if ! command -v info &>/dev/null; then
    # shellcheck source=logging.sh
    source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"
fi

# XDG Base Directory paths with defaults
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Dotfiles-specific paths
export DOTFILES_CONFIG_DIR="${XDG_CONFIG_HOME}/dotfiles"
export DOTFILES_DATA_DIR="${XDG_DATA_HOME}/dotfiles"
export DOTFILES_CACHE_DIR="${XDG_CACHE_HOME}/dotfiles"

# get_dotfiles_dir - Get the dotfiles directory path
# Returns the configured DOTFILES_DIR or attempts to detect it
# Usage: DOTFILES_DIR=$(get_dotfiles_dir)
get_dotfiles_dir() {
    # Check if already set in environment
    if [[ -n "${DOTFILES_DIR:-}" ]]; then
        echo "$DOTFILES_DIR"
        return 0
    fi
    
    # Check config file
    local config_file="${DOTFILES_CONFIG_DIR}/config"
    if [[ -f "$config_file" ]]; then
        local saved_dir
        saved_dir=$(grep '^DOTFILES_DIR=' "$config_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"')
        if [[ -n "$saved_dir" && -d "$saved_dir" ]]; then
            echo "$saved_dir"
            return 0
        fi
    fi
    
    # Try to detect from script location
    local script_dir
    if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
        # If we're in lib/, go up one level
        if [[ "$(basename "$script_dir")" == "lib" ]]; then
            dirname "$script_dir"
            return 0
        fi
    fi
    
    # Default fallback
    echo "${HOME}/Projects/dotfiles"
}

# save_dotfiles_dir - Save the dotfiles directory to config
# Usage: save_dotfiles_dir "/path/to/dotfiles"
save_dotfiles_dir() {
    local dir="$1"
    
    # Ensure config directory exists with proper permissions
    mkdir -p "$DOTFILES_CONFIG_DIR"
    chmod 700 "$DOTFILES_CONFIG_DIR"
    
    local config_file="${DOTFILES_CONFIG_DIR}/config"
    
    # Update or add DOTFILES_DIR
    if [[ -f "$config_file" ]] && grep -q '^DOTFILES_DIR=' "$config_file"; then
        # Update existing entry
        local tmp_file
        tmp_file=$(mktemp)
        trap 'rm -f "$tmp_file"' RETURN
        sed "s|^DOTFILES_DIR=.*|DOTFILES_DIR=\"$dir\"|" "$config_file" > "$tmp_file"
        mv "$tmp_file" "$config_file"
    else
        # Add new entry
        echo "DOTFILES_DIR=\"$dir\"" >> "$config_file"
    fi
    
    chmod 600 "$config_file"
}

# is_macos - Check if running on macOS
# Usage: if is_macos; then ...; fi
is_macos() {
    [[ "$OSTYPE" == darwin* ]]
}

# is_linux - Check if running on Linux
# Usage: if is_linux; then ...; fi
is_linux() {
    [[ "$OSTYPE" == linux* ]]
}

# command_exists - Check if a command exists
# Usage: if command_exists brew; then ...; fi
command_exists() {
    command -v "$1" &>/dev/null
}

# require_command - Ensure a command exists or exit
# Usage: require_command git "Please install git"
require_command() {
    local cmd="$1"
    local msg="${2:-Command '$cmd' is required but not installed.}"
    
    if ! command_exists "$cmd"; then
        die "$msg"
    fi
}

# confirm - Ask for confirmation
# Usage: if confirm "Are you sure?"; then ...; fi
# Usage: confirm "Are you sure?" || exit 0
confirm() {
    local question="$1"
    local response
    
    printf "%s (y/n): " "$question"
    read -r response
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# confirm_default_yes - Ask for confirmation, default to yes
# Usage: if confirm_default_yes "Continue?"; then ...; fi
confirm_default_yes() {
    local question="$1"
    local response
    
    printf "%s (Y/n): " "$question"
    read -r response
    
    [[ -z "$response" || "$response" =~ ^[Yy]$ ]]
}

# confirm_default_no - Ask for confirmation, default to no
# Usage: if confirm_default_no "Delete all files?"; then ...; fi
confirm_default_no() {
    local question="$1"
    local response
    
    printf "%s (y/N): " "$question"
    read -r response
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# ensure_dir - Ensure a directory exists with optional permissions
# Usage: ensure_dir "/path/to/dir" [permissions]
ensure_dir() {
    local dir="$1"
    local perms="${2:-}"
    
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
    
    if [[ -n "$perms" ]]; then
        chmod "$perms" "$dir"
    fi
}

# backup_file - Create a backup of a file with timestamp
# Usage: backup_file "/path/to/file"
backup_file() {
    local file="$1"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.backup-${timestamp}"
        echo "${file}.backup-${timestamp}"
    fi
}

# get_version - Get version of a command
# Usage: version=$(get_version node)
get_version() {
    local cmd="$1"
    
    if ! command_exists "$cmd"; then
        echo "not installed"
        return 1
    fi
    
    case "$cmd" in
        node|npm|pnpm|bun|volta)
            "$cmd" --version 2>/dev/null | head -1 | sed 's/^v//'
            ;;
        brew)
            brew --version 2>/dev/null | head -1 | awk '{print $2}'
            ;;
        go)
            go version 2>/dev/null | awk '{print $3}' | sed 's/^go//'
            ;;
        python|python3)
            "$cmd" --version 2>/dev/null | awk '{print $2}'
            ;;
        uv)
            uv --version 2>/dev/null | awk '{print $2}'
            ;;
        git)
            git --version 2>/dev/null | awk '{print $3}'
            ;;
        *)
            "$cmd" --version 2>/dev/null | head -1
            ;;
    esac
}

# Export functions
export -f get_dotfiles_dir save_dotfiles_dir is_macos is_linux command_exists \
       require_command confirm confirm_default_yes confirm_default_no \
       ensure_dir backup_file get_version 2>/dev/null || true
