#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
command -v hermes >/dev/null || { echo "ERROR: hermes is not installed/in PATH" >&2; exit 1; }

roles=(projects-manager project-manager coder researcher tester reviewer documentation evaluator)
descriptions=(
  "Portfolio manager for creating, prioritizing, and supervising public Hermes-managed projects."
  "Plans one project, decomposes goals, assigns workers, coordinates review, and tracks evidence."
  "Implements bounded software tasks and tests in an assigned project/worktree."
  "Researches source code, authoritative documentation, APIs, and technical alternatives."
  "Independently verifies implementations and reports reproducible evidence."
  "Independently reviews correctness, tests, security, maintainability, and acceptance criteria."
  "Maintains accurate public user/developer documentation and operations."
  "Records evidence-based model/task performance and scorecards."
)

i=0
for role in "${roles[@]}"; do
  description="${descriptions[$i]}"
  if hermes profile show "$role" >/dev/null 2>&1; then
    echo "Profile exists: $role"
  else
    hermes profile create "$role" --clone --description "$description"
  fi
  dest="$HOME/.hermes/profiles/$role/SOUL.md"
  mkdir -p "$(dirname "$dest")"
  cp "$ROOT/agents/$role/SOUL.md" "$dest"
  i=$((i + 1))
done

cat <<'EOF'
Profiles installed/refreshed.
The installer deliberately does NOT overwrite model/provider/tool configuration.
Review agents/profiles.json, then configure toolsets/models for your machine.
EOF
