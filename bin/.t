#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: .t [session]"
    echo ""
    echo "Commands:"
    echo "  (no command)      List all tmux sessions"
    echo "  <session>         Attach to tmux session by number or name"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Description:"
    echo "  Manage tmux sessions quickly"
    echo "  - List all active tmux sessions with their details"
    echo "  - Attach to a session by number (from list) or by name"
    echo ""
    exit 1
}

# Function to list tmux sessions
list_sessions() {
    if ! command -v tmux &> /dev/null; then
        echo "Error: tmux is not installed"
        exit 1
    fi

    # Check if there are any tmux sessions
    if ! tmux list-sessions &> /dev/null; then
        echo "No tmux sessions found"
        exit 0
    fi

    echo "Active tmux sessions:"
    echo "--------------------"

    # List sessions with numbers
    local count=1
    while IFS= read -r line; do
        echo "$count) $line"
        ((count++))
    done < <(tmux list-sessions)
}

# Function to attach to a session
attach_session() {
    local target="$1"

    if ! command -v tmux &> /dev/null; then
        echo "Error: tmux is not installed"
        exit 1
    fi

    # Check if there are any tmux sessions
    if ! tmux list-sessions &> /dev/null; then
        echo "No tmux sessions found"
        exit 1
    fi

    # Check if input is a number
    if [[ "$target" =~ ^[0-9]+$ ]]; then
        # Get the session name by number
        session_name=$(tmux list-sessions -F "#{session_name}" | sed -n "${target}p")

        if [ -z "$session_name" ]; then
            echo "Error: No session found at index $target"
            echo ""
            list_sessions
            exit 1
        fi
    else
        # Treat as session name
        session_name="$target"
    fi

    # Check if session exists
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Error: Session '$session_name' not found"
        echo ""
        list_sessions
        exit 1
    fi

    # Attach to the session
    # If we're already in tmux, switch to the target session
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session_name"
    else
        tmux attach-session -t "$session_name"
    fi
}

# Main script logic
case "$1" in
    "-h"|"--help")
        usage
        ;;
    "")
        list_sessions
        ;;
    *)
        attach_session "$1"
        ;;
esac
