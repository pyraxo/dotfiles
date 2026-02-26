#!/bin/bash

# Project Inventory Scanner
# Scans all projects and creates a comprehensive inventory

PROJECTS_DIR="$HOME/Projects"
OUTPUT_FILE="$PROJECTS_DIR/PROJECT_INVENTORY.md"
TEMP_FILE=$(mktemp)

echo "Scanning projects in $PROJECTS_DIR..."

# Initialize the markdown file
cat > "$TEMP_FILE" << 'HEADER'
# Project Inventory

*Last Updated: $(date)*

This is a living document that catalogs all projects in the Projects folder.

## Table of Contents
- [Active Projects](#active-projects)
- [Stubs & Empty Projects](#stubs--empty-projects)
- [Statistics](#statistics)

---

## Active Projects

HEADER

# Arrays to track stubs
declare -a STUBS=()
TOTAL_PROJECTS=0
ACTIVE_PROJECTS=0

# Function to detect tech stack
detect_stack() {
    local dir="$1"
    local stack=""

    # Check for various tech indicators
    [[ -f "$dir/package.json" ]] && stack="${stack}Node.js/JavaScript, "
    [[ -f "$dir/requirements.txt" ]] && stack="${stack}Python, "
    [[ -f "$dir/Pipfile" ]] && stack="${stack}Python, "
    [[ -f "$dir/pyproject.toml" ]] && stack="${stack}Python, "
    [[ -f "$dir/go.mod" ]] && stack="${stack}Go, "
    [[ -f "$dir/Cargo.toml" ]] && stack="${stack}Rust, "
    [[ -f "$dir/pom.xml" ]] && stack="${stack}Java/Maven, "
    [[ -f "$dir/build.gradle" ]] && stack="${stack}Java/Gradle, "
    [[ -f "$dir/composer.json" ]] && stack="${stack}PHP, "
    [[ -f "$dir/Gemfile" ]] && stack="${stack}Ruby, "
    [[ -f "$dir/pubspec.yaml" ]] && stack="${stack}Dart/Flutter, "
    [[ -f "$dir/.swift-version" ]] && stack="${stack}Swift, "
    [[ -f "$dir/CMakeLists.txt" ]] && stack="${stack}C/C++, "
    [[ -f "$dir/Makefile" ]] && stack="${stack}Make, "
    [[ -f "$dir/docker-compose.yml" ]] && stack="${stack}Docker, "
    [[ -f "$dir/Dockerfile" ]] && stack="${stack}Docker, "

    # Framework detection
    if [[ -f "$dir/package.json" ]]; then
        if grep -q "\"react\"" "$dir/package.json" 2>/dev/null; then
            stack="${stack}React, "
        fi
        if grep -q "\"next\"" "$dir/package.json" 2>/dev/null; then
            stack="${stack}Next.js, "
        fi
        if grep -q "\"vue\"" "$dir/package.json" 2>/dev/null; then
            stack="${stack}Vue, "
        fi
        if grep -q "\"@angular" "$dir/package.json" 2>/dev/null; then
            stack="${stack}Angular, "
        fi
        if grep -q "\"express\"" "$dir/package.json" 2>/dev/null; then
            stack="${stack}Express, "
        fi
    fi

    # Remove trailing comma and space
    stack=$(echo "$stack" | sed 's/, $//')

    [[ -z "$stack" ]] && stack="Unknown"
    echo "$stack"
}

# Function to get project description
get_description() {
    local dir="$1"
    local desc=""

    # Try to get from package.json
    if [[ -f "$dir/package.json" ]]; then
        desc=$(jq -r '.description // empty' "$dir/package.json" 2>/dev/null)
    fi

    # Try to get from README
    if [[ -z "$desc" ]]; then
        for readme in "$dir/README.md" "$dir/README.txt" "$dir/README" "$dir/readme.md"; do
            if [[ -f "$readme" ]]; then
                # Get first non-empty line that's not a heading with just the project name
                desc=$(head -20 "$readme" | grep -v "^#" | grep -v "^$" | head -1 | sed 's/^[[:space:]]*//' | cut -c1-100)
                [[ -n "$desc" ]] && break
            fi
        done
    fi

    # Try Python docstring
    if [[ -z "$desc" && -f "$dir/setup.py" ]]; then
        desc=$(grep -m 1 "description=" "$dir/setup.py" | sed 's/.*description=["'\'']\(.*\)["'\''].*/\1/' | cut -c1-100)
    fi

    [[ -z "$desc" ]] && desc="No description available"
    echo "$desc"
}

# Function to check if project is a stub
is_stub() {
    local dir="$1"

    # Count non-hidden files (excluding common generated dirs)
    local file_count=$(find "$dir" -type f \
        -not -path "*/node_modules/*" \
        -not -path "*/.git/*" \
        -not -path "*/venv/*" \
        -not -path "*/__pycache__/*" \
        -not -path "*/dist/*" \
        -not -path "*/build/*" \
        -not -path "*/.next/*" \
        -not -name ".DS_Store" \
        2>/dev/null | wc -l)

    # Consider it a stub if < 5 files
    if [[ $file_count -lt 5 ]]; then
        return 0
    else
        return 1
    fi
}

# Function to get git info
get_git_info() {
    local dir="$1"
    local git_info=""

    if [[ -d "$dir/.git" ]]; then
        cd "$dir" || return

        # Get remote origin
        local origin=$(git remote get-url origin 2>/dev/null || echo "No remote")

        # Get creation date (first commit)
        local created=$(git log --reverse --format="%ai" | head -1 | cut -d' ' -f1 2>/dev/null || echo "Unknown")

        # Get last commit date
        local last_commit=$(git log -1 --format="%ai" | cut -d' ' -f1 2>/dev/null || echo "Unknown")

        # Check if it's a clone (has remote) vs original
        if [[ "$origin" != "No remote" ]]; then
            git_info="**Cloned from:** $origin  \n**First commit:** $created  \n**Last commit:** $last_commit"
        else
            git_info="**Created:** $created  \n**Last commit:** $last_commit  \n**Type:** Original (no remote)"
        fi

        cd - > /dev/null || return
    else
        # Not a git repo, use filesystem dates
        local modified=$(stat -f "%Sm" -t "%Y-%m-%d" "$dir" 2>/dev/null || stat -c "%y" "$dir" 2>/dev/null | cut -d' ' -f1)
        git_info="**Last modified:** $modified  \n**Type:** Not a git repository"
    fi

    echo -e "$git_info"
}

# Scan all directories
for project_dir in "$PROJECTS_DIR"/*/; do
    # Remove trailing slash and get just the name
    project_dir="${project_dir%/}"
    project_name=$(basename "$project_dir")

    # Skip hidden directories and the inventory file
    [[ "$project_name" == .* ]] && continue
    [[ "$project_name" == "PROJECT_INVENTORY.md" ]] && continue

    ((TOTAL_PROJECTS++))

    echo "  Scanning: $project_name"

    # Gather project info
    description=$(get_description "$project_dir")
    stack=$(detect_stack "$project_dir")
    git_info=$(get_git_info "$project_dir")

    # Check if stub
    if is_stub "$project_dir"; then
        STUBS+=("$project_name")
    else
        ((ACTIVE_PROJECTS++))

        # Add to markdown
        cat >> "$TEMP_FILE" << PROJECT

### $project_name

**Description:** $description

**Tech Stack:** $stack

$git_info

---

PROJECT
    fi
done

# Add stubs section
cat >> "$TEMP_FILE" << 'STUBS_HEADER'

## Stubs & Empty Projects

These projects have minimal files and may be incomplete or empty:

STUBS_HEADER

if [[ ${#STUBS[@]} -eq 0 ]]; then
    echo "*No stubs found*" >> "$TEMP_FILE"
else
    for stub in "${STUBS[@]}"; do
        echo "- **$stub**" >> "$TEMP_FILE"
    done
fi

# Add statistics
cat >> "$TEMP_FILE" << STATS

---

## Statistics

- **Total Projects:** $TOTAL_PROJECTS
- **Active Projects:** $ACTIVE_PROJECTS
- **Stubs:** ${#STUBS[@]}
- **Last Scan:** $(date '+%Y-%m-%d %H:%M:%S')

STATS

# Replace the output file
mv "$TEMP_FILE" "$OUTPUT_FILE"

echo ""
echo "✓ Inventory complete!"
echo "  - Total projects: $TOTAL_PROJECTS"
echo "  - Active: $ACTIVE_PROJECTS"
echo "  - Stubs: ${#STUBS[@]}"
echo ""
echo "Inventory saved to: $OUTPUT_FILE"
