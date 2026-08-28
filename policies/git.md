# Git policy
- `main` is the reviewed integration branch.
- Implementation tasks use isolated branches/worktrees.
- Recommended branch: `agent/<task-id>-<short-slug>`.
- PRs include verification evidence.
- Never force-push `main`.
- Never commit secrets/private runtime state.
