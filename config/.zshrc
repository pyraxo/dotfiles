# Add bin directory to PATH dynamically
# This finds the dotfiles directory and adds its bin folder to PATH
DOTFILES_DIR="${0:A:h:h}"  # Get the directory containing this .zshrc file, then go up one level
export PATH="$DOTFILES_DIR/bin:$PATH"

alias .cc='claude --dangerously-skip-permissions'
alias .ccc='claude --continue --dangerously-skip-permissions'