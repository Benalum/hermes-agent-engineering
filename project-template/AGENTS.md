# Project agent instructions

This is a public repo managed by Hermes Agent Engineering.

1. Read `PROJECT.md` before changing scope.
2. Treat this `AGENTS.md` as protected policy. Read it; do not modify it during normal task execution.
3. Never commit secrets, tokens, cookies, `.env` values, or private data.
4. Keep changes scoped to the active task.
5. Persistent project work uses `dir:<project-root>` or an explicit git worktree. Never use ephemeral scratch for implementation, testing, review, evaluation, or finalization.
6. Do not implement directly on `main`; use a feature branch and GitHub PR.
7. Sequential workers continue on the same delivery branch/PR unless an explicit integration workflow exists.
8. Add/update tests when behavior changes and run documented verification before completion.
9. Implementation workers do not approve their own work.
10. Tester/Reviewer inspect the persistent candidate PR; missing candidate artifacts are blockers.
11. Reviewer approval requires a real PR/diff plus required verification/CI evidence.
12. Evaluation records are append-only in `metrics/model-evaluations.jsonl` and use actual evidence.
13. Delivery is not complete until required review/CI/evaluation gates pass and the approved PR is merged.

## Project-specific architecture
Put project-specific architecture in `PROJECT.md` or normal documentation, not by rewriting this protected policy file.

## Verification
Record exact project verification commands in `PROJECT.md` or normal docs. CI should run them when practical.
