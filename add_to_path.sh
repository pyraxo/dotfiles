#!/bin/bash

# Get the absolute path of the current directory
CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Check if the directory is already in PATH
if [[ ":$PATH:" != *":$CURRENT_DIR:"* ]]; then
    echo "Adding $CURRENT_DIR to PATH in ~/.zshrc"
    
    # Append to ~/.zshrc
    echo "" >> ~/.zshrc
    echo "# Added by add_to_path.sh script" >> ~/.zshrc
    echo "export PATH=\"\$PATH:$CURRENT_DIR\"" >> ~/.zshrc
    
    # Source ~/.zshrc to apply changes immediately
    source ~/.zshrc
    
    echo "Successfully added to PATH and sourced ~/.zshrc"
else
    echo "$CURRENT_DIR is already in PATH"
fi 