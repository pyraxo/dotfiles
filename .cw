#!/bin/bash

# Take a look at ell: https://github.com/simonmysun/ell

# Function to display usage
usage() {
    echo "Usage: .cw [file, folder name, or glob]"
    echo ""
    echo "Description:"
    echo "  Chat with files in the current directory as context."
    echo "  This tool uses glimpse to scan files and prepare context,"
    echo "  then opens an interactive chat session with an LLM provider."
    echo "  If no arguments are provided, the current directory will be used."
    echo "  Hidden files are included in the context, but common non-relevant"
    echo "  directories (.git, node_modules, etc.) are excluded."
    echo ""
    exit 1
}

# Function to check if glimpse is installed
check_glimpse() {
    if ! command -v glimpse &> /dev/null; then
        echo "Error: glimpse is not installed."
        echo "Please install glimpse first: https://github.com/glimpse-cli/glimpse"
        exit 1
    fi
}

# Function to check if jq is installed
check_jq() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed."
        echo "Please install jq first: https://stedolan.github.io/jq/download/"
        exit 1
    fi
}

# Function to handle chat session
handle_chat() {
    # Check if required tools are installed
    check_glimpse
    check_jq

    # Create a temporary file to store the context
    CONTEXT_FILE=$(mktemp)
    
    # Define excluded directories
    EXCLUDE_DIRS=".git/*,node_modules/*,.venv/*,venv/*,.env,__pycache__,dist/*,build/*,.idea/*,.vscode/*"
    
    # Use glimpse to scan files and save the context to the temporary file
    echo "Scanning files and preparing context..."
    echo "Excluding directories: $EXCLUDE_DIRS"
    
    # Build the glimpse command with all the provided patterns
    if [ $# -eq 0 ]; then
        # If no arguments provided, use current directory
        echo "No specific files provided. Using current directory as context."
        glimpse -H --print --exclude "$EXCLUDE_DIRS" . > "$CONTEXT_FILE"
    else
        # Build command with provided arguments
        GLIMPSE_CMD="glimpse -H --print --exclude \"$EXCLUDE_DIRS\""
        for pattern in "$@"; do
            GLIMPSE_CMD="$GLIMPSE_CMD \"$pattern\""
        done
        eval $GLIMPSE_CMD > "$CONTEXT_FILE"
    fi
    
    # Check if the context file is empty
    if [ ! -s "$CONTEXT_FILE" ]; then
        echo "Error: No context was generated. Please check your file patterns."
        rm "$CONTEXT_FILE"
        exit 1
    fi
    
    # Display token count information if available
    echo "Token count information:"
    if grep -q "Token Count Summary:" "$CONTEXT_FILE"; then
        grep -A 10 "Token Count Summary:" "$CONTEXT_FILE"
    else
        echo "No token count information available."
    fi
    
    # Start interactive chat session
    echo ""
    echo "Starting chat session with context. Type 'exit' to quit."
    echo "-----------------------------------------------------"
    
    # Check for API key
    if [ -z "$OPENAI_API_KEY" ]; then
        # Try to load from config file
        if [ -f "$HOME/.config/cw/config" ]; then
            source "$HOME/.config/cw/config"
        fi
        
        # If still not set, prompt for it
        if [ -z "$OPENAI_API_KEY" ]; then
            echo "OpenAI API key not found."
            echo -n "Please enter your OpenAI API key: "
            read -r OPENAI_API_KEY
            
            # Save to config for future use
            mkdir -p "$HOME/.config/cw"
            echo "OPENAI_API_KEY=\"$OPENAI_API_KEY\"" > "$HOME/.config/cw/config"
            chmod 600 "$HOME/.config/cw/config"
        fi
    fi
    
    # Start interactive chat loop
    while true; do
        # Prompt for user input
        echo -n "> "
        read -r user_input
        
        # Check if user wants to exit
        if [ "$user_input" = "exit" ] || [ "$user_input" = "quit" ]; then
            break
        fi
        
        # Prepare the prompt with context and user query
        PROMPT_FILE=$(mktemp)
        echo "I have the following code/files as context:" > "$PROMPT_FILE"
        cat "$CONTEXT_FILE" >> "$PROMPT_FILE"
        echo "" >> "$PROMPT_FILE"
        echo "My question is: $user_input" >> "$PROMPT_FILE"
        
        # Read the content of the prompt file
        PROMPT_CONTENT=$(cat "$PROMPT_FILE")
        
        # Call OpenAI API
        echo "Querying OpenAI API..."
        RESPONSE=$(curl --silent --location --request POST 'https://api.openai.com/v1/chat/completions' \
            --header "Authorization: Bearer $OPENAI_API_KEY" \
            --header 'Content-Type: application/json' \
            --data-raw "{
                \"model\": \"gpt-4\",
                \"messages\": [
                    {\"role\": \"system\", \"content\": \"You are a helpful assistant providing answers in a command-line terminal. Be concise and direct. Do not use markdown formatting. Avoid unnecessary explanations unless specifically asked. Format your output for readability in a plain text terminal.\"},
                    {\"role\": \"user\", \"content\": $(echo "$PROMPT_CONTENT" | jq -Rs .)}
                ],
                \"temperature\": 0.7
            }")
        
        # Extract and display the response
        ERROR=$(echo "$RESPONSE" | jq -r '.error.message')
        if [ "$ERROR" != "null" ]; then
            echo "Error: $ERROR"
        else
            echo "$RESPONSE" | jq -r '.choices[0].message.content'
        fi
        
        # Clean up the prompt file
        rm "$PROMPT_FILE"
    done
    
    # Clean up the context file
    rm "$CONTEXT_FILE"
    
    echo "Chat session ended."
}

# Main script logic
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
fi

handle_chat "$@" 