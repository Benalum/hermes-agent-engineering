#!/usr/bin/env bash
set -euo pipefail
if [[ $# -lt 3 ]]; then echo "Usage: $0 <slug> <name> <description>" >&2; exit 2; fi
SLUG="$1"; NAME="$2"; DESCRIPTION="$3"
[[ "$SLUG" =~ ^[a-z0-9][a-z0-9_-]{0,63}$ ]] || { echo "Invalid slug: $SLUG" >&2; exit 2; }
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; PROJECTS_ROOT="${HERMES_PROJECTS_ROOT:-$HOME/projects}"; TARGET="$PROJECTS_ROOT/$SLUG"
for cmd in git gh hermes python3 rsync; do command -v "$cmd" >/dev/null || { echo "ERROR: $cmd required" >&2; exit 1; }; done
gh auth status >/dev/null || { echo "ERROR: run gh auth login" >&2; exit 1; }
OWNER="$(gh api user --jq .login)"
[[ ! -e "$TARGET" ]] || { echo "ERROR: local path exists: $TARGET" >&2; exit 1; }
! gh repo view "$OWNER/$SLUG" >/dev/null 2>&1 || { echo "ERROR: repo exists: $OWNER/$SLUG" >&2; exit 1; }
mkdir -p "$TARGET"; rsync -a "$ROOT/project-template/" "$TARGET/"
python3 - "$TARGET" "$NAME" "$DESCRIPTION" <<'PYPROJECT'
from pathlib import Path
import sys
root=Path(sys.argv[1]); name=sys.argv[2]; desc=sys.argv[3]
for p in root.rglob('*'):
    if p.is_file():
        try: text=p.read_text(encoding='utf-8')
        except UnicodeDecodeError: continue
        p.write_text(text.replace('{{PROJECT_NAME}}',name).replace('{{PROJECT_DESCRIPTION}}',desc),encoding='utf-8')
PYPROJECT
cd "$TARGET"; git init -b main; git add .; git commit -m "chore: initialize $NAME"
gh repo create "$OWNER/$SLUG" --public --description "$DESCRIPTION" --source . --remote origin --push
if ! hermes kanban boards list 2>/dev/null | grep -qE "(^|[[:space:]])${SLUG}([[:space:]]|$)"; then hermes kanban boards create "$SLUG" --name "$NAME" --description "$DESCRIPTION"; fi
hermes kanban --board "$SLUG" create "Project kickoff and architecture" --assignee project-manager --workspace "dir:$TARGET" --body "Read PROJECT.md and AGENTS.md. Define MVP architecture, exact verification commands, milestones, task taxonomy for model evaluation, and dependency-aware worker tasks. Do not implement the whole project yourself."
echo "Repo: https://github.com/$OWNER/$SLUG"; echo "Local: $TARGET"; echo "Board: $SLUG"; echo "Set the board Project Directory to $TARGET in hermes dashboard before using automatic worktree tasks."
