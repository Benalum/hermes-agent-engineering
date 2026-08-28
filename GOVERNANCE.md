# Governance

## Authority

- The user owns goals, destructive changes, credentials, releases, and policy changes.
- The Projects Manager owns portfolio organization and project bootstrap.
- A Project Manager owns planning and coordination within one project board.
- Workers execute bounded tasks and provide evidence.
- A Reviewer independently evaluates completed work.
- An Evaluator records model/task outcome evidence.

## Separation of duties

An implementation worker should not be the final reviewer of its own change. A Project Manager must not silently weaken acceptance criteria after seeing a weak result.

## Git policy

- No secrets in Git.
- `main` is the reviewed integration branch.
- Feature work uses branches/worktrees.
- PRs explain what changed and how it was verified.
- Failed tests must not be hidden, deleted, or disabled merely to make a task pass.

## Evaluation integrity

Model-performance records reflect the actual model and actual result. Corrections are explicit; historical records are not rewritten to favor a preferred model.
