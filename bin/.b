#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: .b [-t] [directory]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    echo "  -t            Temporary: Only add to current session PATH (not to .zshrc)"
    echo ""
    echo "Description:"
    echo "  Adds a directory to PATH."
    echo ""
    exit 1
}

# Function to check if directory is in PATH (current or .zshrc)
is_in_path() {
    local dir="$1"
    local zshrc="$HOME/.zshrc"
    
    # Check current PATH
    if [[ ":$PATH:" == *":$dir:"* ]]; then
        return 0
    fi
    
    # Check .zshrc for PATH definitions
    if [ -f "$zshrc" ]; then
        # Look for both exact matches and variable expansions
        if grep -q "export PATH=.*$dir" "$zshrc" || \
           grep -q "export PATH=.*\$PATH.*$dir" "$zshrc"; then
            return 0
        fi
    fi
    
    return 1
}

# Function to add directory to PATH
add_to_path() {
    local dir="$1"
    local persist="$2"
    
    # Convert relative path to absolute path
    if [[ "$dir" != /* ]]; then
        dir="$(cd "$dir" && pwd)"
    fi
    
    # Check if directory exists
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist"
        exit 1
    fi
    
    # Check if directory is already in PATH (current or .zshrc)
    if is_in_path "$dir"; then
        echo "Directory '$dir' is already in PATH (either in current session or .zshrc)"
        return
    fi
    
    # Add directory to PATH
    export PATH="$dir:$PATH"
    echo "Added '$dir' to PATH"
    
    # If persist is true (default), add to .zshrc
    if [ "$persist" = "true" ]; then
        local zshrc="$HOME/.zshrc"
        local path_line="export PATH=\"$dir:\$PATH\""
        
        # Add to .zshrc
        echo "$path_line" >> "$zshrc"
        echo "Added '$dir' to $zshrc"
        echo "Note: Changes to .zshrc will take effect in new shell sessions"
    fi
}

# Main script logic
persist=true  # Default to persistent
dir=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -t)
            persist=false
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            if [ -z "$dir" ]; then
                dir="$1"
            else
                usage
            fi
            shift
            ;;
    esac
done

# If no directory provided, use current directory
if [ -z "$dir" ]; then
    dir="$(pwd)"
fi

add_to_path "$dir" "$persist" 