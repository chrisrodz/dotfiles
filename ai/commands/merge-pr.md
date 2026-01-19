# /merge-pr

Purpose: merge a PR into the default branch and sync local main.

Input

- PR: <pr-number> or URL (required)

1) Guardrails

- Working tree must be clean: `git status -sb`
- PR must not be draft.
- PR base must be `main` (or repo default). If not, stop and ask.
- If mergeable state is conflicted or unknown, stop and ask.

1) Capture context

- `START_BRANCH="$(git branch --show-current)"`
- `gh pr view <PR> --json number,title,author,baseRefName,headRefName,isDraft,mergeable`
- If `isDraft` or `mergeable` != MERGEABLE: stop.

1) CI checks

- `gh pr checks <PR>`
- If any required checks are failing, stop and fix.

1) Sync base branch

- `git checkout main || git checkout "$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"`
- `git pull --ff-only`

1) Run the repo gate (if defined)

- Prefer the repo's standard lint/test/build scripts.
- If unsure, search: `rg -n "lint|test|build|ci" package.json Makefile scripts -S`
- Run the smallest gate that represents the repo's standard checks.

1) Merge PR

- Pick the best allowed merge method:
  - `merge_method=$(gh repo view --json mergeCommitAllowed,rebaseMergeAllowed,squashMergeAllowed --jq 'if .rebaseMergeAllowed then "rebase" elif .squashMergeAllowed then "squash" else "merge" end')`
- Merge and delete the PR branch:
  - `gh pr merge <PR> --$merge_method --delete-branch`

1) Sync local main and verify

- `git pull --ff-only`
- `gh pr view <PR> --json mergedAt,mergeCommit`
- End on `main`.
