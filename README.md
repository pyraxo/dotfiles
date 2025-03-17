# @cli

Super-opinionated collection of custom command-line tools for my own use.

## Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/pyraxo/cli-scripts.git @cli
   ```

2. Run the initialization script:

   ```bash
   cd @cli
   ./init.sh
   ```

This will add the project directory to your PATH, allowing you to use the tools from anywhere.

## Available Tools

### Git Helper (.g)

A streamlined interface for common Git operations.

```bash
.g <command> [arguments]
```

#### Commands

- `cl, clone <repo> [directory]` - Clone a repository (tries git:, then https:)
- `i, init [-f]` - Initialize git repo, create initial commit (-f: resets .git folder)
- `cm, commit <message>` - Commit with message (no quotes needed)
- `ac <message>` - Add all files and commit (no quotes needed)
- `acp <message>` - Add all files, commit, and push (no quotes needed)
- `p, push` - Push to remote
- `pl, pull` - Pull from remote
- `f, fetch` - Fetch from remote
- `b` - List branches
- `bc <branch-name>` - Create and checkout new branch
- `bs <branch-name>` - Switch to branch
- `bd <branch-name>` - Delete branch
- `bm <branch-name>` - Merge branch into current branch
- `ro <url>` - Set remote origin URL (just username/repo)
- `rs` - Reset soft (undo last commit, keep changes)
- `rh` - Reset hard (discard all changes)
- `rw` - Rewind - reset hard to previous commit (HEAD^1)
- `am <message>` - Amend last commit with new message

### API Key Manager (.k)

A tool for managing API keys across projects, syncing between local `.env` files and a global config.

```bash
.k <command>
```

#### Commands

- `(no command)` - Sync API keys between .env and global config
- `i` - Interactive mode to add new API keys
- `l` - List all stored API keys

The tool stores API keys in `~/.config/@cli/config` and can sync them with local `.env` files. When adding keys interactively, you can:

- Choose from common options (anthropic, openai)
- Enter any custom key type (e.g. 'deepseek' becomes DEEPSEEK_API_KEY)

### Project Template Manager (.p)

A tool for managing and installing project templates.

```bash
.p <command> [arguments]
```

#### Commands

- `i, install <template-name> [destination-folder]` - Copy template from the templates directory to current directory or specified folder

#### Configuration

By default, templates are looked for in the `templates` directory within the @cli folder. You can customize this location by setting the `TEMPLATES_DIR` environment variable:

```bash
# In your .zshrc, .bashrc, or similar:
export TEMPLATES_DIR="/path/to/your/templates"
```

## Why Use These Tools?

- **Simplicity**: Reduces complex commands to simple, memorable shortcuts
- **Consistency**: Standardizes common operations across projects
- **Efficiency**: Saves time on repetitive tasks
- **Flexibility**: Works with your existing workflow and tools

## Project Structure

```
@cli/
├── .g                  # Git helper script
├── .p                  # Project template manager
├── init.sh             # Installation script
├── .gitignore          # Git ignore file
└── README.md           # This documentation
```

## Contributing

Contributions are welcome! Feel free to submit pull requests with new features, improvements, or bug fixes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
