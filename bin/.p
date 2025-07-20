#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: .p <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  i, install <name> [destination]    Copy template to current directory or specified folder"
    echo ""
    echo "Description:"
    echo "  Copy template from templates directory to current directory or specified folder"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    exit 1
}

# Function to handle install command
handle_install() {
    if [ -z "$1" ]; then
        echo "Error: Template name is required"
        usage
    fi

    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
    
    # Use environment variable if set, otherwise use templates directory in the same folder as the script
    TEMPLATES_DIR="${TEMPLATES_DIR:-$SCRIPT_DIR/templates}"
    
    TEMPLATE_NAME="$1"
    TEMPLATE_PATH="$TEMPLATES_DIR/$TEMPLATE_NAME"
    CURRENT_DIR=$(pwd)
    
    # Check if a destination folder was specified
    DESTINATION_DIR="$CURRENT_DIR"
    if [ ! -z "$2" ]; then
        DESTINATION_DIR="$CURRENT_DIR/$2"
        # Create the destination directory if it doesn't exist
        mkdir -p "$DESTINATION_DIR"
    fi
    
    # Check if template exists
    if [ ! -d "$TEMPLATE_PATH" ]; then
        echo "Error: Template '$TEMPLATE_NAME' not found in templates directory"
        echo "Templates directory: $TEMPLATES_DIR"
        exit 1
    fi
    
    if [ "$DESTINATION_DIR" = "$CURRENT_DIR" ]; then
        echo "Installing template '$TEMPLATE_NAME' to current directory..."
    else
        echo "Installing template '$TEMPLATE_NAME' to '$2'..."
    fi
    
    # Create a temporary file for rsync exclude patterns
    EXCLUDE_FILE=$(mktemp)
    
    # Check if .gitignore exists in the current directory
    if [ -f "$CURRENT_DIR/.gitignore" ]; then
        # Copy .gitignore patterns to exclude file
        cat "$CURRENT_DIR/.gitignore" > "$EXCLUDE_FILE"
    fi
    
    # Check if .gitignore exists in the template
    if [ -f "$TEMPLATE_PATH/.gitignore" ]; then
        # Append template's .gitignore patterns to exclude file
        cat "$TEMPLATE_PATH/.gitignore" >> "$EXCLUDE_FILE"
    fi
    
    # Add some default exclusions
    echo ".git/" >> "$EXCLUDE_FILE"
    echo ".DS_Store" >> "$EXCLUDE_FILE"
    
    # Use rsync to copy files, excluding patterns from .gitignore
    rsync -av --exclude-from="$EXCLUDE_FILE" "$TEMPLATE_PATH/" "$DESTINATION_DIR/"
    
    # Clean up temporary file
    rm "$EXCLUDE_FILE"
    
    if [ "$DESTINATION_DIR" = "$CURRENT_DIR" ]; then
        echo "Template '$TEMPLATE_NAME' installed successfully!"
    else
        echo "Template '$TEMPLATE_NAME' installed successfully to '$2'!"
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    usage
fi

COMMAND="$1"
shift

case "$COMMAND" in
    i|install)
        handle_install "$@"
        ;;
    --help|-h)
        usage
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        usage
        ;;
esac 