# @cli

Super-opinionated collection of custom command-line tools for my own use.

## Available Tools

### PATH Manager (.b)

Add directories to PATH with persistent or temporary options.

```bash
.b [-t] [directory]
```

**Options:**
- `-t` - Temporary: Only add to current session PATH (not to .zshrc)
- No args - Adds current directory to PATH

### Brew Install Manager (.bi)

Install packages with brew and automatically add them to Brewfile.

```bash
.bi [options] <package>
```

**Options:**
- `-c, --cask` - Force install as a cask
- `-t, --tap` - Force add as a tap
- `-f, --formula` - Force install as a formula
- Auto-detects package type if no option specified

### Chat with Files (.cw)

Chat with files in the current directory as context using an LLM.

```bash
.cw [file, folder name, or glob]
```

Uses glimpse to scan files and prepare context, then opens an interactive chat session with OpenAI. Excludes common non-relevant directories (.git, node_modules, etc.).

### Git Helper (.g)

Streamlined interface for common Git operations.

```bash
.g <command> [arguments]
```

**Commands:**
- `cl, clone <repo> [dir]` - Clone repository (tries git:, then https:)
- `i, init [-f]` - Initialize git repo, create initial commit
- `cm, commit <msg>` - Commit with message (no quotes needed)
- `ac <msg>` - Add all and commit
- `acp <msg>` - Add all, commit, and push
- `p, push` / `pl, pull` / `f, fetch` - Remote operations
- `b` - List branches
- `bc <name>` - Create and checkout branch
- `bs <name>` - Switch branch
- `bd <name>` - Delete branch
- `bm <name>` - Merge branch
- `ro <url>` - Set remote origin URL
- `rs` - Reset soft (undo commit, keep changes)
- `rh` - Reset hard (discard all changes)
- `rw` - Rewind to previous commit
- `am <msg>` - Amend last commit

### API Key Manager (.k)

Manage API keys across projects, syncing between local `.env` files and global config.

```bash
.k [command]
```

**Commands:**
- `(no command)` - Sync API keys between .env and global config
- `i` - Interactive mode to add new API keys
- `l` - List all stored API keys

Stores API keys in `~/.config/@cli/config`. Supports common providers (anthropic, openai) and custom key types.

### Project Initializer (.pi)

Interactive command to prepare projects for AI agentic coding.

```bash
.pi [init]
```

**Commands:**
- `(no command)` - Prepare existing project for AI agentic coding
- `init` - Create new project and prepare it

**Sets up:**
- Claude Code Infrastructure (cc-infra)
- Beads issue tracking system
- Codex-1up documentation
- Docs folder structure with guidelines

### SSH Manager (.ssh)

Manage SSH connections and keys.

```bash
.ssh <command>
```

**Commands:**
- `ex` - Export SSH public key to remote machine (interactive)

Finds default SSH key and walks through interactive export process.

### Tmux Session Manager (.t)

Quickly manage tmux sessions.

```bash
.t [session]
```

**Commands:**
- `(no command)` - List all tmux sessions
- `<session>` - Attach to session by number or name

### Dotfiles Manager (dot)

Manage dotfiles installation and updates.

```bash
dot [options]
```

**Options:**
- `-e, --edit` - Open dotfiles directory for editing
- `-l, --list` - List all available commands in bin directory
- `-f, --force` - Force update by discarding local changes
- `-x <script>` - Execute a script from the scripts directory
- No args - Update dotfiles with git pull and run system updates

### Environment File Backup (envxtract)

Securely backup and restore environment files across a project.

```bash
envxtract [command]
```

**Commands:**
- `(no args)` - Extract (backup) all .env* files in current directory
- `--load <file>` - Restore .env files from backup
- `-h, --help` - Show help message

**Features:**
- Recursively scans for all `.env*` files (excludes `.env.example`)
- Password-based encryption using AES-256 with PBKDF2 key derivation
- Compression with gzip for smaller backup files
- Excludes common directories (node_modules, .git, vendor, etc.)
- Stores backups in gitignored `tmp/` directory
- Automatically backs up existing files as `{filename}-backup-YYYYMMDD` during restore
- Backup format: `tmp/YYYYMMDD-envxtract-XXXXXX.envx`

**Requirements:**
- Python 3.8+
- `cryptography` library: `pip3 install cryptography` or `uv pip install cryptography`

**Examples:**
```bash
# Backup all .env files
envxtract

# Restore from backup
envxtract --load tmp/20251122-envxtract-a4f2c9.envx
```
