#!/bin/bash
#
# logging.sh - Logging functions for consistent output
#
# Usage: source "$(dirname "$0")/../lib/logging.sh"
#
# Provides standardized logging functions for all scripts.
# Automatically sources colors.sh if not already loaded.

# Source colors if not already loaded
if [[ -z "${NC:-}" ]]; then
    # shellcheck source=colors.sh
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

# info - Display informational message
# Usage: info "message"
info() {
    printf "\r  [ ${BLUE}..${NC} ] %s\n" "$1"
}

# user - Display prompt/question for user
# Usage: user "question"
user() {
    printf "\r  [ ${YELLOW}??${NC} ] %s\n" "$1"
}

# success - Display success message
# Usage: success "message"
success() {
    printf "\r\033[2K  [ ${GREEN}OK${NC} ] %s\n" "$1"
}

# warn - Display warning message
# Usage: warn "message"
warn() {
    printf "\r\033[2K  [ ${YELLOW}!!${NC} ] %s\n" "$1"
}

# fail - Display failure message
# Usage: fail "message"
fail() {
    printf "\r\033[2K  [${RED}FAIL${NC}] %s\n" "$1"
    echo ''
}

# die - Display error message and exit
# Usage: die "message" [exit_code]
die() {
    fail "$1"
    exit "${2:-1}"
}

# header - Display section header
# Usage: header "Section Name"
header() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
    echo ""
}

# banner - Display application banner
# Usage: banner "App Name"
banner() {
    local title="${1:-Dotfiles}"
    local width=40
    local padding=$(( (width - ${#title} - 2) / 2 ))
    local pad_left pad_right
    pad_left=$(printf '%*s' "$padding" '')
    pad_right=$(printf '%*s' $(( width - ${#title} - 2 - padding )) '')
    
    echo ""
    echo -e "${BLUE}╔$(printf '═%.0s' $(seq 1 $width))╗${NC}"
    echo -e "${BLUE}║${pad_left} ${title} ${pad_right}║${NC}"
    echo -e "${BLUE}╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
    echo ""
}

# Export functions for subshells
export -f info user success warn fail die header banner 2>/dev/null || true
