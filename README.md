# Hermes Agent Engineering

A public, version-controlled engineering factory for Hermes Agent.

This repository defines reusable agent roles, project governance, project templates, model-performance tracking, and bootstrap tooling for a hierarchy of:

```text
User
  └─ Projects Manager
       └─ Project Manager (one project/board at a time)
            ├─ Coder
            ├─ Researcher
            ├─ Tester
            ├─ Reviewer
            ├─ Documentation
            └─ Evaluator
```

## Core rules

1. Every managed project is its own **public GitHub repository**.
2. Every project gets its own **Hermes Kanban board**.
3. Hermes profiles represent reusable **roles**, not individual projects.
4. Project-specific behavior is committed in the project's `AGENTS.md`.
5. Coding work uses branches/worktrees and pull requests instead of direct changes to `main`.
6. Every evaluated task records the **model**, task type, success, quality, retries, duration, and cost/token data when available.
7. Model routing is evidence-based: use historical results by task type, with a cold-start fallback to the profile's default model.
8. Secrets, tokens, cookies, credentials, private memory, `.env` files, and browser profiles are never committed.

## Quick start

```bash
git clone https://github.com/Benalum/hermes-agent-engineering.git
cd hermes-agent-engineering
./scripts/install_profiles.sh
./scripts/smoke_test.sh
```

Create a new public project:

```bash
./scripts/create_project.sh inventory-api "Inventory API"   "REST API for products, inventory, customers, and orders"
```

Then:

```bash
hermes gateway start
hermes dashboard
```

See `ARCHITECTURE.md` and `docs/TESTING.md` for the full flow.
