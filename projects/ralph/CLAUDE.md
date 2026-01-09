# Ralph

Autonomous agent loop for Claude Code. Memory persists via git, `progress.txt`, and `prd.json`.

## Skills

- `/prd` - Generate a PRD from feature description → saves to `tasks/prd-[name].md`
- `/ralph` - Convert PRD to JSON → saves to `scripts/ralph/prd.json`

## Running

```bash
./scripts/ralph/ralph.sh [max_iterations]
```

## Files

| File | Purpose |
|------|---------|
| `scripts/ralph/prd.json` | Task list with `passes` status |
| `scripts/ralph/progress.txt` | Learnings for future iterations |
| `scripts/ralph/prompt.md` | Instructions for each iteration |
