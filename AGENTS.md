# AGENTS.md - Coding Agent Guidelines

This is a personal dotfiles repository for macOS and Linux development environments.
All scripts are written in Bash/Shell. There is no build system - this is a shell-based configuration repo.

## Quick Reference

| Action | Command |
|--------|---------|
| Lint shell scripts | `shellcheck -x lib/*.sh` |
| Lint single file | `shellcheck -x <file>` |
| Lint YAML | `yamllint -d relaxed .github/workflows/*.yml` |
| Verify setup | `dot doctor` |
| Check tool versions | `dot status` |

## Project Structure

```
dotfiles/
├── install.sh           # Main installer entry point
├── Brewfile             # Homebrew packages (macOS)
├── lib/                 # Shared shell libraries (source these)
│   ├── colors.sh        # Terminal color variables
│   ├── logging.sh       # Logging functions (info, success, warn, fail, die)
│   ├── utils.sh         # Utilities (command_exists, confirm, is_macos, etc.)
│   └── common.sh        # Cross-platform installation functions
├── config/.zshrc        # Shell configuration
├── bin/                 # CLI tools (added to PATH, use . prefix: .g, .k, .bi)
├── macos/               # macOS-specific setup scripts
├── ubuntu/              # Linux-specific setup scripts
├── scripts/             # Additional utilities
└── .github/workflows/   # CI (ShellCheck + yamllint)
```

## Linting

ShellCheck is the only linter. Always use `-x` flag to follow sourced files:

```bash
shellcheck -x lib/*.sh          # Lint all libraries
shellcheck -x bin/dot           # Lint single file
```

CI runs ShellCheck on `lib/*.sh`, `bin/*`, `install.sh`, and platform setup scripts.

## Code Style Guidelines

### Reference Files

For code patterns, refer to these well-structured examples:
- **Script structure**: `bin/dot` - headers, sourcing, usage functions, command routing
- **Library patterns**: `lib/utils.sh` - function docs, error handling, platform detection
- **Simple CLI tool**: `bin/.g` - subcommand handling with case statements
- **Logging usage**: `lib/logging.sh` - available logging functions

### Key Conventions

**Script Header** - Every script starts with:
- `#!/bin/bash` (not `/bin/sh`)
- Descriptive comment block
- `set -eu` for strict error handling

**Sourcing Libraries** - Use shellcheck directives:
```bash
# shellcheck source=../lib/logging.sh
source "$DOTFILES_DIR/lib/logging.sh"
```

**Naming**:
- Functions: `snake_case` (or `handle_` prefix for command handlers)
- Constants/exports: `UPPER_CASE`
- Local variables: `lower_case` with `local` keyword
- bin/ tools: `.` prefix (`.g`, `.k`, `.bi`) to avoid conflicts

**Error Handling**:
- `command_exists` / `require_command` for checking commands
- `|| true` to prevent exit on expected failures
- `die "message"` for fatal errors

**Platform Detection**: `is_macos` / `is_linux` from `lib/utils.sh`

**Logging** (from `lib/logging.sh`):
- `info`, `success`, `warn`, `fail`, `die`
- `header`, `banner`, `user`

**User Interaction** (from `lib/utils.sh`):
- `confirm`, `confirm_default_yes`, `confirm_default_no`

### Security Practices

- Hide sensitive input: `read -rs password`
- Config file permissions: `chmod 600`
- Config directory permissions: `chmod 700`
- Comment trusted external scripts: `# SECURITY: Trusted vendor installation script`

## File Permissions

- Scripts in `bin/`: executable (`chmod +x`)
- Config files: `600` (owner read/write only)
- Config directories: `700` (owner only)

## Testing Changes

There is no test suite. Verify changes by:

1. Running `shellcheck -x` on modified files
2. Running `dot doctor` to check configuration
3. Running `dot status` to verify tool detection
4. Manual testing of the specific functionality

## CI/CD

GitHub Actions runs on push/PR to main:
- ShellCheck on shell scripts
- yamllint on workflow files

See `.github/workflows/lint.yml` for configuration.
