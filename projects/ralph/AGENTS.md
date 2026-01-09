# Ralph - Autonomous Agent Loop

Ralph runs Claude Code in a loop until all PRD tasks are complete. Each iteration is a fresh context.

## Workflow

1. **Create PRD**: Use `/prd` skill to generate `tasks/prd-[feature].md`
2. **Convert to JSON**: Use `/ralph` skill to create `scripts/ralph/prd.json`
3. **Run loop**: `./scripts/ralph/ralph.sh [max_iterations]`

## How It Works

- Each iteration reads `prd.json`, picks the first story with `passes: false`
- Implements the story, runs quality checks, commits if passing
- Updates `prd.json` to mark `passes: true`
- Appends learnings to `progress.txt`
- Exits when all stories pass or max iterations reached

## Key Rules

- Stories must be small (completable in one context window)
- Order stories by dependency (schema → backend → UI)
- Every story needs "Typecheck passes" in acceptance criteria
- UI stories need "Verify in browser" in acceptance criteria
