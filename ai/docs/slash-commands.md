---
summary: 'Slash commands overview and redirect to docs/slash-commands.'
read_when:
  - Editing or adding slash commands.
---
# Slash Commands

Canonical docs live in `ai/docs/slash-commands/`. See `ai/docs/slash-commands/README.md` for the index.

1. **Create a markdown file** in `~/repos/dotfiles/ai/commands/` (canonical source):

   ```bash
   echo "# /mycommand\n\nYour prompt instructions..." > ~/repos/dotfiles/ai/commands/mycommand.md
   ```

2. **Use the command** in Codex/Claude/Cursor sessions:

```text
   /mycommand
   ```

3. **The agent will execute** the prompt from the file

## Best Practices

- **Be specific:** Include exact commands, safety checks, and exit conditions
- **Document constraints:** No destructive git, coordination rules, scope boundaries
- **Make them reusable:** Avoid task-specific details (dates, ticket numbers)
- **Test them:** Run the slash command to verify it works as expected
- **Version control:** Consider storing project-specific commands in `.claude/commands/` (repo-local)

## Project-Local Commands

For project-specific workflows, you can also create commands in the repo root:

**`.claude/commands/`** - For Claude Code
**`.cursor/commands/`** - For Cursor AI

These are checked into version control and shared with the team.

### This Project's Commands

This repository keeps shared commands in `ai/commands/` and symlinks them into:

- `~/.codex/prompts/`
- `~/.claude/commands/`
- `~/.cursor/commands/`

**Available commands:**

- `/create-pull-request` - Create a pull request with all changes committed.
- `/handoff` - Capture current state for the next agent.
- `/interview-spec` - Run a product/tech spec interview.
- `/merge-pr` - Merge a PR into the default branch and sync main.
- `/pickup` - Rehydrate context when starting work.
- `/raise` - Open next `Unreleased` section after a release.
- `/review-technical-writing` - Review documentation and polish it.
