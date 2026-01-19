---
description: Create pull request with all changes committed
---

Create a pull request following best practices:

1. Check git status to ensure we're on a feature branch (not main)
2. Review all staged and unstaged changes with git diff
3. Stage all relevant files (excluding secrets like .env)
4. Create a concise commit message following conventional commit format (feat:, fix:, docs:, refactor:, etc.) based on actual changes
5. Commit all changes with the commit message
6. Push to remote with -u flag
7. Review git log and full diff from main branch to understand all commits in this PR
8. Create PR using gh pr create with:
   - Title following conventional commit format (determines version bump)
   - Body with Summary section (1-3 bullets describing changes)

IMPORTANT:

- Analyze ALL commits in the branch, not just the latest commit
- PR title must use conventional commit prefix (feat:, fix:, docs:, etc.)
- Commit message should match PR title for consistency
- Verify branch is not main before proceeding
- Return PR URL when complete
