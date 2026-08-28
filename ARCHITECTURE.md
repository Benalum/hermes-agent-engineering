# Architecture

```text
User
  │
  ▼
Projects Manager ── portfolio registry / project creation
  │
  ├── Project A: public GitHub repo + Hermes board
  │      └── Project Manager
  │             ├── Coder
  │             ├── Researcher
  │             ├── Tester
  │             ├── Reviewer
  │             ├── Documentation
  │             └── Evaluator
  │
  └── Project B: public GitHub repo + Hermes board
         └── same reusable roles
```

## Instruction layers

1. `SOUL.md`: durable role identity and behavioral boundaries.
2. Hermes profile configuration/toolsets: actual capabilities exposed to a role.
3. Project `AGENTS.md`: repository-specific architecture, commands, and rules.
4. Kanban task: exact goal, acceptance criteria, dependencies, workspace, and evidence.

A prompt is not a security sandbox. Important restrictions should also be enforced with GitHub branch rules, CI, credentials, operating-system permissions, and container/sandbox boundaries.

## Projects and boards

Each project maps 1:1 to a public GitHub repository, local working clone, Hermes Kanban board, project `AGENTS.md`, and public model-evaluation data under `metrics/`.

Hermes boards isolate task queues per project. The Projects Manager coordinates across boards through a portfolio registry rather than cross-board task dependencies.

## Git workflow

```text
main
 ├─ agent/TASK-101-auth-api ── PR ── review/CI ── merge
 ├─ agent/TASK-102-db-schema ─ PR ── review/CI ── merge
 └─ agent/TASK-103-ui-login ── PR ── review/CI ── merge
```

Coding tasks should use Hermes Kanban worktree workspaces after the board's Project Directory is configured.

## Model-routing loop

```text
classify task
   ↓
query comparable historical evaluations
   ↓
if enough samples → rank models
else → profile default
   ↓
run task → tests/review → append evaluation
   ↓
future routing improves
```

The reference router is deterministic; a model does not get to rewrite its own historical score.
