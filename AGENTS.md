# Factory repository instructions

This repository defines the engineering factory itself.

Before changing factory behavior:

1. Read `ARCHITECTURE.md` and `GOVERNANCE.md`.
2. Keep role definitions generic; project-specific rules belong in generated project `AGENTS.md` files.
3. Keep secrets out of this public repository.
4. Run `./scripts/smoke_test.sh` before review.
5. Changes to schemas, routing math, or agent authority require tests or explicit verification evidence.
