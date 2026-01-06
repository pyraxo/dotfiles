#!/bin/bash
#
# colors.sh - Color definitions for terminal output
#
# Usage: source "$(dirname "$0")/../lib/colors.sh"
#
# Provides color variables for consistent terminal output across all scripts.
# All colors auto-disable when output is not a TTY (e.g., piped to file).

# Disable colors if not in a terminal
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m' # No Color / Reset
else
    RED=''
    GREEN=''
    BLUE=''
    YELLOW=''
    CYAN=''
    MAGENTA=''
    BOLD=''
    DIM=''
    NC=''
fi

# Export for subshells
export RED GREEN BLUE YELLOW CYAN MAGENTA BOLD DIM NC
