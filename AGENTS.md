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
- Make the best decision that will elevate all three: the user experience (UX), developer experience (DX), and agent experience (AX) always, without breaking anything.

## Agent Protocol

- Timezone: America/Puerto_Rico (UTC-4).
- Use `gh` for GitHub; avoid the web UI. Use `gh pr view/diff` for viewing PRs
- Never use `#<number>` in PR/issue comments or descriptions — GitHub auto-links it and surfaces unrelated PRs/issues. Use a plain number or word ("PR 204", "finding 1") or the full URL.
- Use concise conventional commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:`, `chore:`. Add `!` for breaking changes or scope like `feat(api):`.
- ASCII only in docs unless a file already uses Unicode.
- ASCII art allowed only for planning visuals.
- Need upstream file: stage in /tmp/, then cherry-pick; never overwrite tracked.
- Fix root cause (not band-aid).
- Ask only when a missing choice changes scope, risk, or the result. Otherwise state the assumption and proceed.
- Conflicts: call out; pick safer path.
- Preserve unrelated changes. If they overlap with the task or break validation, stop and ask.
- Leave breadcrumb notes in thread.

## Authorization

- A destination named by the user is trusted for the payload they asked to send there.
- "Make/open the PR" authorizes creating and pushing a non-default branch to the named repo, then opening the PR.
- "Land the PR" or invoking a landing workflow authorizes applying the exact reviewed plan when it has no destroys or unrelated changes, posting sanitized evidence, running post-flight checks, approving, merging, and deleting an unstacked remote branch.
- Ask before resource deletion, secret transfer, permission or protection bypass, force push, default-branch push, or unrelated mutation.

## Safety Boundaries

- Never create, modify, or delete Coolify resources without explicit user approval first. Read-only inspection is fine; writes require a direct yes in the current thread.
- Never connect/disconnect/modify Cloudflare WARP (`warp-cli connect`, `disconnect`, `registration delete`, settings changes, profile switches) without explicit user approval first. Read-only status checks (`warp-cli status`, `settings`, `registration show`) are fine; any state change requires a direct yes in the current thread.

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
- Identify failure modes: invalid inputs, missing deps, network/IO, concurrency, resource exhaustion.
- Classify scope: A) core flow, B) edge cases, C) out of scope (document, don't implement).
- Check existing code — extend before creating.

## Planning

- For non-trivial work, provide a short plan before editing.
- Keep scope tight; split large files when they grow past ~500 LOC.
- Group by feature/domain, not by layer.
- For every brainstorming or investigation task, use the globally installed
  `show-me` skill. Pick the smallest visual that makes the key idea, evidence,
  or tradeoff clear; keep supporting prose concise.

## Git

- Safe by default: `git status`, `git diff`, `git log`.
- Fetch before work; pull only when behind (ff-only).
- Create or push a non-default branch when the user requests code changes, a PR, or a landing workflow.
- Push after meaningful checkpoints. Never force-push or push the default branch unless asked.
- No amend unless asked.
- No destructive ops without explicit request (`reset --hard`, `clean`, `restore`, `rm`, etc.).
- Use `trash` for deletions when possible.
- Prefer `committer` helper when available; stage explicit paths only.

## Build / Test

- Prefer end-to-end verification; if blocked, say what is missing.
- Add regression tests when the change warrants it.
- Before handoff, run the relevant repo gate. Report skipped checks and why.
- Inspect failed CI before rerunning it. Fix the cause, push, and monitor the result.
- For PRs, address one round of available AI review feedback before handoff or merge. Rerun affected checks.
- Pre-submit: no commented-out code; no naked TODOs (use `// TODO: [reason] desc`); actionable error msgs; no hardcoded secrets.
- Test behavior, not implementation. Public interface, not private details.
- Unit tests by default. Integration tests for: critical paths, complex interactions, external service contracts.

## Code Style
- Functions: max 3-4 params; beyond that use a config object.
- Avoid boolean params — they obscure intent at call sites.
- Comments explain WHY, not WHAT. Delete comments that restate code.
- TODO format: `// TODO: [context] description`
- Ticket refs (`JIRA-123`, `INFR-456`, etc.): TODOs + commit messages only. Explanatory comments, docstrings, PR descriptions: self-contained — a future reader without tracker access must still understand the reasoning.

## Error Handling
- Define domain-specific error types per module.
- Include context: what failed, with what inputs (IDs, paths, values).
- Map external errors at boundaries — don't leak implementation details.
- Fail at the source; don't pass invalid state downstream.

## Refactoring
- Refactor first only when it makes the requested change safer or smaller.
- Keep behavior and structural changes separate when practical.
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
- Avoid redundant reads and reruns. Repeat when output was incomplete, state may have changed, or verification requires it.
- Don't echo large blocks of code unless asked.
- Batch related edits — don't make 5 edits when 1 handles it.
- Don't summarize what you just did unless result is ambiguous.

## Notes

- "Make a note" means edit this file.
