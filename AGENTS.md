# AGENTS.md

Owner: Christian A. Rodriguez Encarnación
Style: concise, telegraphic, noun-phrases ok, minimal tokens. No emojis.

## Agent Protocol

- Timezone: America/Puerto_Rico (UTC-4).
- Use `gh` for GitHub; avoid the web UI. Use `gh pr view/diff` for viewing PRs
- Use concise conventional commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:`, `chore:`. Add `!` for breaking changes or scope like `feat(api):`.
- ASCII only in docs unless a file already uses Unicode.
- ASCII art allowed only for planning visuals.
- Need upstream file: stage in /tmp/, then cherry-pick; never overwrite tracked.
- Fix root cause (not band-aid).
- Unsure: read more code; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.
- Leave breadcrumb notes in thread.

## Workspace

- Primary workspace: `~/repos`.
- If a repo is missing: `gh repo clone <owner>/<repo> <path>`.

## Docs

- If a repo has docs, list them early (run any `docs:list` script or `docs-list` helper if present).
- Follow `read_when` hints before coding.
- Update docs when behavior/API changes.

## Code Quality Priorities

1) Minimal.
2) Self-documenting.
3) Type-exact.
4) Secure.
5) Performant.
6) Accessible.
7) Testable.

## Planning

- For non-trivial work, provide a short plan before editing.
- Keep scope tight; split large files when they grow past ~500 LOC.

## Git

- Safe by default: `git status`, `git diff`, `git log`.
- Fetch before work; pull only when behind (ff-only).
- Branch changes require user consent.
- For non-main branches: push after meaningful checkpoints.
- For main: push only when asked.
- No amend unless asked.
- No destructive ops without explicit request (`reset --hard`, `clean`, `restore`, `rm`, etc.).
- Use `trash` for deletions when possible.
- Prefer `committer` helper when available; stage explicit paths only.
- If unexpected changes appear, stop and ask.

## Build / Test

- Prefer end-to-end verification; if blocked, say what is missing.
- Add regression tests when the change warrants it.
- Before handoff: run full gate (lint/typecheck/tests/docs).
- CI red: gh run list/view, rerun, fix, push, repeat til green.

## Tooling

- Use repo package manager/runtime; no swaps without approval.
- Slash commands:
  - Codex global: `~/.codex/prompts/`
  - Claude repo: `.claude/commands/`
  - Cursor repo: `.cursor/commands/`
  - Cursor global: `~/.cursor/commands/`

## Notes

- "Make a note" means edit this file.
