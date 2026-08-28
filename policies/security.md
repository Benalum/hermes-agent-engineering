# Security policy
Prompt instructions are not a sandbox. Use technical controls for important boundaries.

Minimum controls:
- credentials in `.env`/secret manager, never Git;
- protect `main` with PR/CI rules when practical;
- give roles only needed tools/credentials;
- prefer worktrees, containers, restricted OS users for risky execution;
- keep browser cookies/session profiles outside repos;
- review diffs for accidental sensitive data before push.
