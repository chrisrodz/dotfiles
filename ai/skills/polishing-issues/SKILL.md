---
name: polishing-issues
description: Make a GitHub issue self-contained for a single feature/fix so any coding agent can execute it without back-and-forth. Focus on scope, file touchpoints, acceptance criteria, and validation.
---

# Polish Issue Scope (Single Feature)

Goal: turn one issue into a complete, actionable spec for a single feature or fix. Keep it concise, technical, and executable without follow-up questions.

## Use When
- Issue is missing scope, acceptance criteria, or validation.
- Issue references a feature/fix but lacks file touchpoints or constraints.
- You need an execution-ready issue for a coding agent.

## Do Not Use
- Multi-epic planning or multi-sprint roadmaps.
- Full product/spec interviews (use the interview skill for that).

## Workflow

1) Fetch the issue
```bash
gh issue view <number> --repo <owner/repo> --json title,body,labels,state,comments
```

2) Scan the codebase
- Locate related files or patterns with `rg`.
- Identify likely files to modify or create.
- Note constraints (existing APIs, data models, UI patterns, tests).

3) Resolve blockers
- Ask at most 1-3 blocking questions.
- If not blocking, make explicit assumptions and proceed.

4) Draft a concise scope block
- Keep to bullets, no fluff.
- Provide enough context to implement without follow-up.

5) Show preview and confirm
- Present exact markdown to append.
- Wait for explicit approval before editing the issue.

6) Update the issue
```bash
CURRENT_BODY=$(gh issue view <number> --repo <owner/repo> --json body -q .body)

gh issue edit <number> --repo <owner/repo> --body "$CURRENT_BODY

---

[scope block here]"
```

## Scope Block Template

```markdown
## Scope

**Summary**
- <1-2 sentence summary of the change>

**Goals**
- <what must be true when done>

**Non-goals**
- <explicitly out of scope>

**User impact**
- <who is affected and how>

**Touchpoints**
- Modify: `path/to/file.ts` - <why>
- Create: `path/to/new-file.ts` - <why>

**API/data changes** (if any)
- <schema, endpoints, migrations>

**Edge cases**
- <list>

**Acceptance criteria**
- [ ] <testable outcome>
- [ ] <testable outcome>

**Validation**
- Tests: `<command or file>`
- Manual: <steps>

**Task breakdown** (atomic, commit-ready)
1. <small task> - validation: <test or check>
2. <small task> - validation: <test or check>

**Dependencies / risks**
- <libs, feature flags, env vars, rollout concerns>
```

## Rules
- Prefer explicit file paths and code locations.
- Each task must be small and independently verifiable.
- If there are multiple viable approaches, list them briefly and pick a recommendation unless the choice blocks implementation.
- Avoid long narrative; keep it scannable.
