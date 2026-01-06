#!/bin/bash
#
# .k - API key manager
#
# Manages API keys by syncing between .env and ~/.config/@cli/config

set -eu

# Function to display usage
usage() {
    echo "Usage: .k [command]"
    echo ""
    echo "Commands:"
    echo "  (no command)  Sync API keys between .env and config"
    echo "  i            Interactive mode to add new API keys"
    echo "  l            List all stored API keys"
    echo "  l <name>     Show value for specific API key (e.g. '.k l deepseek' for DEEPSEEK_API_KEY)"
    echo "  -h, --help   Show this help message"
    echo ""
    echo "Description:"
    echo "  Manages API keys by syncing between .env and ~/.config/@cli/config"
    echo "  - Checks for duplicate API keys in both files"
    echo "  - Comments out duplicates in .env"
    echo "  - Adds missing keys from ~/.config/@cli/config to .env"
    echo ""
    exit 1
}

# Check if files exist and create if necessary
init_files() {
    CONFIG_DIR="$HOME/.config/@cli"
    CONFIG_FILE="$CONFIG_DIR/config"
    
    # Create config directory with secure permissions
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        chmod 700 "$CONFIG_DIR"
    fi
    
    # Ensure directory has correct permissions even if it existed
    chmod 700 "$CONFIG_DIR"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        touch "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"
    fi
    
    # Ensure file has correct permissions even if it existed
    chmod 600 "$CONFIG_FILE"
    
    # Create .env if it doesn't exist
    if [ ! -f ".env" ]; then
        touch ".env"
    fi

    # Ensure .env is ignored by git if a .gitignore exists
    if [ -f ".gitignore" ]; then
        if ! grep -qF ".env" ".gitignore"; then
            echo ".env" >> ".gitignore"
            echo "Added .env to .gitignore"
        fi
    fi
}

# Function to get all API keys from a file
get_api_keys() {
    local file="$1"
    if [ -f "$file" ]; then
        # Get lines that look like API keys (containing _API_KEY or _SECRET)
        grep -E '^[^#]*(_API_KEY|_SECRET)=' "$file" | sed 's/=.*//' || true
    fi
}

# Function to handle interactive mode
interactive_mode() {
    init_files
    CONFIG_FILE="$HOME/.config/@cli/config"
    
    echo "Interactive API Key Management"
    echo "----------------------------"
    echo "Please paste your API key (input hidden):"
    read -rs api_key
    echo  # Add newline after hidden input
    
    # Validate input
    if [ -z "$api_key" ]; then
        echo "Error: API key cannot be empty"
        exit 1
    fi
    
    echo ""
    echo "What type of API key is this?"
    echo "Common options:"
    echo "1) anthropic"
    echo "2) openai"
    echo "Or enter your own (e.g. 'deepseek', 'github')"
    read -r choice
    
    case $choice in
        1|"anthropic")
            key_name="ANTHROPIC_API_KEY"
            ;;
        2|"openai")
            key_name="OPENAI_API_KEY"
            ;;
        *)
            # Convert input to uppercase and append _API_KEY if needed
            key_name=$(echo "$choice" | tr '[:lower:]' '[:upper:]')
            if [[ ! "$key_name" =~ _API_KEY$ && ! "$key_name" =~ _SECRET$ ]]; then
                key_name="${key_name}_API_KEY"
            fi
            ;;
    esac
    
    # Remove existing key if present
    sed -i.bak "/^$key_name=/d" "$CONFIG_FILE"
    
    # Add new key
    echo "$key_name=\"$api_key\"" >> "$CONFIG_FILE"
    echo "Added $key_name to config file"
    
    # Clean up backup file
    rm -f "${CONFIG_FILE}.bak"
    
    echo "To sync this key with your .env file, run '.k' with no arguments"
}

# Main function to handle key management
manage_keys() {
    init_files
    
    CONFIG_FILE="$HOME/.config/@cli/config"
    ENV_FILE=".env"
    
    # Temporary file for the new .env content
    TEMP_ENV=$(mktemp)
    # Ensure temp file is cleaned up on exit
    trap 'rm -f "$TEMP_ENV"' EXIT
    
    # Read the current .env file line by line
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines
        if [ -z "$line" ]; then
            echo "" >> "$TEMP_ENV"
            continue
        fi
        
        # Check if line is already commented
        if [[ "$line" =~ ^[[:space:]]*# ]]; then
            echo "$line" >> "$TEMP_ENV"
            continue
        fi
        
        # Check if line contains an API key
        if [[ "$line" =~ (_API_KEY|_SECRET)= ]]; then
            # Extract the key name
            key_name=$(echo "$line" | sed 's/=.*//')
            
            # Check if this key exists in config file
            if grep -q "^$key_name=" "$CONFIG_FILE"; then
                # Comment out the .env version and add the config version
                echo "# $line" >> "$TEMP_ENV"
                grep "^$key_name=" "$CONFIG_FILE" >> "$TEMP_ENV"
                echo "Synced $key_name from config file"
            else
                # Keep the original line
                echo "$line" >> "$TEMP_ENV"
            fi
        else
            # Not an API key line, keep as is
            echo "$line" >> "$TEMP_ENV"
        fi
    done < "$ENV_FILE"
    
    # Add any keys from config that aren't in .env
    while IFS= read -r config_key; do
        if ! grep -q "^$config_key=" "$ENV_FILE" && ! grep -q "^# *$config_key=" "$TEMP_ENV"; then
            grep "^$config_key=" "$CONFIG_FILE" >> "$TEMP_ENV"
            echo "Added $config_key from config file"
        fi
    done < <(get_api_keys "$CONFIG_FILE")
    
    # Replace the old .env with the new one
    mv "$TEMP_ENV" "$ENV_FILE"
    
    echo "API key synchronization complete"
}

# Function to list all API keys
list_keys() {
    init_files
    CONFIG_FILE="$HOME/.config/@cli/config"
    
    if [ -n "$1" ]; then
        # Convert input to uppercase for matching
        search_key=$(echo "$1" | tr '[:lower:]' '[:upper:]')
        
        # Try to find and display the key value (looks for _API_KEY or _SECRET suffix)
        if [ -s "$CONFIG_FILE" ]; then
            value=$(grep -E "^(${search_key}_API_KEY|${search_key}_SECRET)=" "$CONFIG_FILE" | cut -d'"' -f2)
            if [ -n "$value" ]; then
                echo "$value"
            else
                echo "No API key found for: $search_key"
            fi
        else
            echo "No API keys found in config"
        fi
    else
        echo "Stored API Keys:"
        echo "---------------"
        if [ -s "$CONFIG_FILE" ]; then
            while IFS='=' read -r key value; do
                # Only show key names, not the actual values
                if [[ "$key" =~ (_API_KEY|_SECRET)$ ]]; then
                    echo "$key"
                fi
            done < "$CONFIG_FILE"
        else
            echo "No API keys found in config"
        fi
    fi
}

# Main script logic
case "$1" in
    "i")
        interactive_mode
        ;;
    "l")
        list_keys "$2"
        ;;
    "-h"|"--help")
        usage
        ;;
    "")
        manage_keys
        ;;
    *)
        echo "Unknown command: $1"
        usage
        ;;
esac 