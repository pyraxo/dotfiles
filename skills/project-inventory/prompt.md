# Project Inventory Skill

You are now running the project-inventory skill to help the user maintain a comprehensive catalog of all their projects.

## Your Task

1. Run the inventory scanner script to analyze all projects
2. Read and present the generated inventory file to the user
3. Highlight key findings like:
   - Total number of projects
   - Number of stubs (empty/minimal projects)
   - Any interesting patterns in tech stacks
   - Recently modified projects

## Commands to Run

First, run the scanner:
```bash
~/.claude/skills/project-inventory/scan-projects.sh
```

Then, read and present the inventory file:
```bash
cat ~/Projects/PROJECT_INVENTORY.md
```

## Notes

- The inventory file is a living document stored at `~/Projects/PROJECT_INVENTORY.md`
- The user can manually edit this file if needed
- Future runs of this skill will regenerate the file with updated information
- The scanner looks for various tech stack indicators (package.json, requirements.txt, etc.)
- Projects with fewer than 5 files (excluding node_modules, .git, etc.) are considered "stubs"

## After Running

Provide the user with:
1. A summary of the scan results
2. The location of the inventory file
3. Suggestions for what they might want to do next (clean up stubs, organize by tech stack, etc.)
