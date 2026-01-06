#!/bin/bash
#
# .bi - Brew install with automatic Brewfile management
#
# Install packages with brew and automatically add them to Brewfile.
# Automatically detects if package is a formula, cask, or tap.

set -eu

usage() {
    echo ".bi -- brew install with automatic Brewfile management"
    echo ""
    echo "Description:"
    echo "  Install packages with brew and automatically add them to Brewfile"
    echo "  Automatically detects if package is a formula, cask, or tap"
    echo ""
    echo "Usage: .bi [options] <package>"
    echo ""
    echo "Options:"
    echo "  -c, --cask    Force install as a cask"
    echo "  -t, --tap     Force add as a tap"
    echo "  -f, --formula Force install as a formula"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Examples:"
    echo "  .bi wget              # Auto-detect and install"
    echo "  .bi firefox           # Auto-detect (will find cask)"
    echo "  .bi homebrew/cask     # Auto-detect (will find tap)"
    echo "  .bi -c firefox        # Force install as cask"
    exit 0
}

# Find the dotfiles directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
DOTFILES_DIR="$(cd "$(dirname "$SCRIPT_DIR")" && pwd -P)"
BREWFILE="$DOTFILES_DIR/Brewfile"

# Check if Brewfile exists
if [ ! -f "$BREWFILE" ]; then
    echo "Error: Brewfile not found at $BREWFILE"
    exit 1
fi

# Parse options
INSTALL_TYPE="auto"
PACKAGE=""

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -c|--cask)
            INSTALL_TYPE="cask"
            shift
            ;;
        -t|--tap)
            INSTALL_TYPE="tap"
            shift
            ;;
        -f|--formula)
            INSTALL_TYPE="brew"
            shift
            ;;
        *)
            PACKAGE="$1"
            shift
            ;;
    esac
done

# Validate package name
if [ -z "$PACKAGE" ]; then
    echo "Error: No package specified"
    usage
fi

# Auto-detect install type if not forced
if [ "$INSTALL_TYPE" = "auto" ]; then
    echo "› Auto-detecting package type..."

    # Check if it's a tap (contains a slash and matches user/repo pattern)
    if [[ "$PACKAGE" == *"/"* ]]; then
        # Try to check if it's an existing tap
        if brew tap | grep -q "^${PACKAGE}$" 2>/dev/null; then
            echo "  Already tapped, will ensure it's in Brewfile"
            INSTALL_TYPE="tap"
        elif brew tap-info "$PACKAGE" &>/dev/null; then
            echo "  Detected as tap"
            INSTALL_TYPE="tap"
        else
            # Could be a formula from a tap like homebrew/cask/firefox
            # Try cask first, then formula
            if brew info --cask "$PACKAGE" &>/dev/null; then
                echo "  Detected as cask"
                INSTALL_TYPE="cask"
            elif brew info --formula "$PACKAGE" &>/dev/null; then
                echo "  Detected as formula"
                INSTALL_TYPE="brew"
            else
                echo "  Unable to find package, assuming tap"
                INSTALL_TYPE="tap"
            fi
        fi
    else
        # Check if it's a cask first (casks are more specific)
        if brew info --cask "$PACKAGE" &>/dev/null; then
            echo "  Detected as cask"
            INSTALL_TYPE="cask"
        elif brew info --formula "$PACKAGE" &>/dev/null; then
            echo "  Detected as formula"
            INSTALL_TYPE="brew"
        else
            echo "  Package not found in brew repositories"
            echo "  Assuming formula (will fail if incorrect)"
            INSTALL_TYPE="brew"
        fi
    fi
fi

# Check if package already exists in Brewfile
if grep -q "^${INSTALL_TYPE} ['\"]${PACKAGE}['\"]" "$BREWFILE" || grep -q "^${INSTALL_TYPE} '${PACKAGE}'" "$BREWFILE"; then
    echo "Package '${PACKAGE}' already exists in Brewfile as ${INSTALL_TYPE}"
    read -p "Do you want to continue with installation anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Install the package
echo "› Installing ${PACKAGE} using brew ${INSTALL_TYPE}..."
case "$INSTALL_TYPE" in
    brew)
        brew install "$PACKAGE"
        ;;
    cask)
        brew install --cask "$PACKAGE"
        ;;
    tap)
        brew tap "$PACKAGE"
        ;;
esac

# Add to Brewfile if installation succeeded
echo "› Adding ${PACKAGE} to Brewfile..."

# Create the new entry
NEW_ENTRY="${INSTALL_TYPE} '${PACKAGE}'"

# Add the entry to the appropriate section in Brewfile
# We'll find the last occurrence of the type and add after it
if grep -q "^${INSTALL_TYPE} " "$BREWFILE"; then
    # Find the last line with this type and add after it
    # Use awk to find the last occurrence and insert after it
    awk -v type="^${INSTALL_TYPE} " -v entry="$NEW_ENTRY" '
    {
        lines[NR] = $0
        if ($0 ~ type) last_match = NR
    }
    END {
        for (i = 1; i <= NR; i++) {
            print lines[i]
            if (i == last_match) print entry
        }
    }
    ' "$BREWFILE" > "$BREWFILE.tmp"
    mv "$BREWFILE.tmp" "$BREWFILE"
else
    # Type doesn't exist yet, add at the end
    echo "" >> "$BREWFILE"
    echo "$NEW_ENTRY" >> "$BREWFILE"
fi

echo "✓ Successfully installed ${PACKAGE} and added to Brewfile"
