# Changelog

All notable changes to this dotfiles repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-06

### Added

- **Shared Library System** (`lib/`)
  - `colors.sh` - Terminal color definitions with auto-disable for non-TTY
  - `logging.sh` - Standardized logging functions (info, success, warn, fail, die)
  - `utils.sh` - Common utilities (command_exists, confirm, get_version, etc.)
  - `common.sh` - Shared installation functions for cross-platform use

- **New `dot` Subcommands**
  - `dot setup` - First-time configuration, saves dotfiles location
  - `dot status` - System health check showing installed tool versions
  - `dot doctor` - Diagnose configuration issues
  - `dot backup` - Create JSON backup of installed packages
  - `dot restore` - Restore from backup file
  - `dot sync` - Two-way sync with remote repository

- **New `.g` Git Shortcuts**
  - `d`, `ds`, `dc` - Diff commands (unstaged, staged, cached)
  - `l`, `ll`, `lp` - Log commands (oneline, graph, patch)
  - `st`, `sta`, `stl`, `stp`, `std` - Stash commands
  - `s` - Status shortcut

- **Configuration Persistence**
  - DOTFILES_DIR saved to `~/.config/dotfiles/config`
  - Auto-detection on first run

- **Versioning**
  - Added VERSION file
  - Added CHANGELOG.md

- **CI/CD**
  - Added GitHub Actions workflow for shellcheck linting

### Changed

- All shell scripts now use `set -eu` for stricter error handling
- Refactored platform scripts (macos/ubuntu) to use shared `lib/common.sh`
- Improved security in `.k` API key manager:
  - Hidden input for API keys
  - Proper temp file cleanup with trap
  - Secured config directory permissions (700)
  - Secured config file permissions (600)
- Updated `config/.zshrc` to use cached DOTFILES_DIR for faster shell startup
- Improved banner display with proper Unicode box drawing characters
- Fixed macOS detection using proper bash syntax (`[[ "$OSTYPE" == darwin* ]]`)

### Fixed

- Banner closing character (was `╔`, now `╚`)
- macOS detection in `dot` command (was using sh-incompatible pattern)
- Unquoted variable expansions in logging functions

### Security

- API key input is now hidden (not visible on screen)
- Temp files are cleaned up on script exit via trap
- Config directories use 700 permissions
- Config files use 600 permissions

## [1.0.0] - Previous Version

Initial dotfiles setup with:
- macOS and Linux support
- Oh My Zsh integration
- Homebrew package management
- Custom CLI tools in `bin/`
- API key management with `.k`
- Git shortcuts with `.g`
- Project initialization with `.pi`
- Environment file backup with `envxtract`
