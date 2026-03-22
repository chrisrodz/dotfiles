# AGENTS.md

Owner: Christian A. Rodriguez Encarnación
Style: concise, telegraphic, noun-phrases ok, minimal tokens. No emojis.

## Core Principles
- Clarity > cleverness — maintainable, not impressive
- Explicit > implicit — no magic; make behavior obvious
- Composition > inheritance — small units that combine
- Fail fast, fail loud — surface errors at the source
- Delete code — less code = fewer bugs; question every addition
- Verify, don't assume — run it, test it, prove it

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
- Never create, modify, or delete Coolify resources without explicit user approval first. Read-only inspection is fine; writes require a direct yes in the current thread.

## Debugging
1. Reproduce reliably.
2. Isolate: smallest input that fails.
3. Read the error — full stack trace.
4. Form one hypothesis.
5. Test it: log, write a test, inspect state.
6. Fix and verify — change one thing.
7. Add regression test.

Don't: change multiple things at once; assume cause without evidence; fix symptoms instead of root causes.

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

## Before Writing Code
- Restate the goal; ask if ambiguous.
- Identify failure modes: invalid inputs, missing deps, network/IO, concurrency, resource exhaustion.
- Classify scope: A) core flow, B) edge cases, C) out of scope (document, don't implement).
- Check existing code — extend before creating.

## Planning

- For non-trivial work, provide a short plan before editing.
- Keep scope tight; split large files when they grow past ~500 LOC.
- Group by feature/domain, not by layer.

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
- Pre-submit: no commented-out code; no naked TODOs (use `// TODO: [reason] desc`); actionable error msgs; no hardcoded secrets.
- Test behavior, not implementation. Public interface, not private details.
- Unit tests by default. Integration tests for: critical paths, complex interactions, external service contracts.

## Code Style
- Functions: max 3-4 params; beyond that use a config object.
- Avoid boolean params — they obscure intent at call sites.
- Comments explain WHY, not WHAT. Delete comments that restate code.
- TODO format: `// TODO: [context] description`

## Error Handling
- Define domain-specific error types per module.
- Include context: what failed, with what inputs (IDs, paths, values).
- Map external errors at boundaries — don't leak implementation details.
- Fail at the source; don't pass invalid state downstream.

## Refactoring
- Refactor before adding a feature (make the change easy, then make the easy change).
- Never change behavior and structure in the same step.
- Don't refactor while debugging or without test coverage.
- "While I'm here" changes: separate commit or ticket.

## Dependencies
Before adding: can we solve this in <100 lines? Is it maintained? Transitive cost? License? Abandonment risk?

## Tooling

- Use repo package manager/runtime; no swaps without approval.
- Slash commands:
  - Codex global: `~/.codex/prompts/`
  - Claude repo: `.claude/commands/`
  - Cursor repo: `.cursor/commands/`
  - Cursor global: `~/.cursor/commands/`

## Token Efficiency
- Never re-read files you just wrote or edited.
- Never re-run commands to verify unless outcome was uncertain.
- Don't echo large blocks of code unless asked.
- Batch related edits — don't make 5 edits when 1 handles it.
- Don't summarize what you just did unless result is ambiguous.

## Notes

- "Make a note" means edit this file.
