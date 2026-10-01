# AGENTS.md

Owner: Christian A. Rodriguez Encarnación
Style: concise, telegraphic, noun-phrases ok. No emojis.

## Principles

- Clarity > cleverness; explicit > implicit; composition > inheritance.
- Fail fast, fail loud: surface errors at the source.
- Delete code; question every addition.
- Verify, don't assume: run it, test it, prove it.
- Prefer the decision that improves UX, DX, and AX together without breaking anything.
- When priorities conflict: minimal, self-documenting, type-exact, secure, performant, accessible, testable.

## Scope and Completion

- Do what was asked. When the work is done and checked, stop and report. Don't add features, tests, files, docs, or refactors that weren't asked for; mention them at the end.
- Asked for ideas, options, or a plan: give that and stop. Don't build until told.
- Ask only when a missing choice changes scope, risk, or the result. Otherwise state the assumption and proceed.
- Final report: what changed, what was verified, what's open. No step-by-step recap. Don't echo large code blocks unless asked.
- Brainstorming or investigation: use the smallest visual that makes the idea, evidence, or tradeoff clear (`show-me` skill when invoked).

## Agent Protocol

- Timezone: America/Puerto_Rico (UTC-4).
- Use `gh` for GitHub; avoid the web UI. Use `gh pr view/diff` for viewing PRs.
- Never use `#<number>` in PR/issue comments or descriptions: GitHub auto-links it and surfaces unrelated PRs/issues. Use a plain number or word ("PR 204", "finding 1") or the full URL.
- Conventional commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`, `build:`, `ci:`, `chore:`. Add `!` for breaking changes or a scope like `feat(api):`.
- ASCII only in docs unless a file already uses Unicode. ASCII art only for planning visuals.
- Need an upstream file: stage in /tmp/, then cherry-pick; never overwrite tracked.
- Fix the root cause, not the symptom. Debugging: reproduce first, one hypothesis at a time, change one thing, add a regression test.
- Preserve unrelated changes. If they overlap with the task or break validation, stop and ask.

## Authorization

- A destination named by the user is trusted for the payload they asked to send there.
- "Make/open the PR" authorizes creating and pushing a non-default branch to the named repo, then opening the PR.
- "Land the PR" or invoking a landing workflow authorizes applying the exact reviewed plan when it has no destroys or unrelated changes, posting sanitized evidence, running post-flight checks, approving, merging, and deleting an unstacked remote branch.
- Ask before resource deletion, secret transfer, permission or protection bypass, force push, default-branch push, or unrelated mutation.

## Safety Boundaries

- Never create, modify, or delete Coolify resources without explicit user approval first. Read-only inspection is fine; writes require a direct yes in the current thread.
- Never connect/disconnect/modify Cloudflare WARP (`warp-cli connect`, `disconnect`, `registration delete`, settings changes, profile switches) without explicit user approval first. Read-only status checks (`warp-cli status`, `settings`, `registration show`) are fine; any state change requires a direct yes in the current thread.

## Workspace

- Primary workspace: `~/repos`.
- If a repo is missing: `gh repo clone <owner>/<repo> <path>`.

## Docs

- Read the docs relevant to the change (`read_when` hints; run a `docs:list` script if the repo has one). Update docs when behavior or API changes.

## Planning

- Non-trivial work: short plan before editing. Check existing code; extend before creating.
- Split files that grow past ~500 LOC. Group by feature/domain, not by layer.

## Git

- Safe by default: `git status`, `git diff`, `git log`.
- Fetch before work; pull only when behind (ff-only).
- Create or push a non-default branch when the user requests code changes, a PR, or a landing workflow.
- Push after meaningful checkpoints. Never force-push or push the default branch unless asked.
- No amend unless asked.
- No destructive ops without explicit request (`reset --hard`, `clean`, `restore`, `rm`, etc.). Use `trash` for deletions when possible.
- Stage explicit paths only.

## Build / Test

- Prefer end-to-end verification; if blocked, say what is missing.
- Add regression tests when the change warrants them.
- Before handoff, run the relevant repo gate. Report skipped checks and why.
- Inspect failed CI before rerunning it. Fix the cause, push, and monitor the result.
- For PRs, address one round of available AI review feedback before handoff or merge. Rerun affected checks.
- Pre-submit: no commented-out code; no naked TODOs; actionable error messages; no hardcoded secrets.

## Code Style

- Functions: max 3-4 params; beyond that use a config object. Avoid boolean params.
- Comments explain WHY, not WHAT.
- TODO format: `// TODO: [context] description`.
- Ticket refs (`JIRA-123`, `INFR-456`, etc.): TODOs and commit messages only. Explanatory comments, docstrings, and PR descriptions stay self-contained: a future reader without tracker access must still understand the reasoning.
- Errors: domain-specific types per module; include what failed and with what inputs (IDs, paths, values); map external errors at boundaries.
- New dependency: can it be <100 lines? Is it maintained? Transitive cost, license, abandonment risk.
- Refactor first only when it makes the requested change safer or smaller. Keep behavior and structural changes separate; "while I'm here" changes get their own commit or ticket.
- Use the repo's package manager/runtime; no swaps without approval.

## Notes

- "Make a note" means edit this file.
