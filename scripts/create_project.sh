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
KICKOFF_BODY="Read PROJECT.md and AGENTS.md. AGENTS.md is protected policy. Kickoff/decomposition is READ-ONLY for tracked project files: do not modify PROJECT.md, code, tests, CI, or other tracked files; put planning in task bodies/comments and assign any needed tracked documentation change to the delivery branch. Every child task MUST explicitly use persistent workspace dir:$TARGET; never use scratch. Required sequential chain: implementation -> tester -> reviewer -> delivery-finalizer -> evaluator -> metrics-finalizer. First coder creates one feature branch/PR and MUST replace HERMES_VERIFY_PLACEHOLDER in scripts/verify.sh with reproducible project verification. Coder/Tester must complete only with clean workspace and local HEAD == origin branch HEAD == PR HEAD. Tester posts HERMES-TEST with exact tested_sha and requires project-verification green for that SHA. Reviewer is outcome-neutral: exactly APPROVE, REQUEST_CHANGES, or BLOCK; never preselect APPROVE. Reviewer is a pre-created downstream card: APPROVE completes it; REQUEST_CHANGES or BLOCK must block it for remediation and must not use same-card kanban_request_changes. Reviewer is read-only, requires clean state, tested_sha == reviewed_sha == PR HEAD, project-verification green for that SHA, and posts HERMES-REVIEW. Delivery-finalizer runs BEFORE evaluator and merges only if current PR HEAD still equals tested/reviewed SHA; after merge record immutable merged_sha. Evaluator runs AFTER merge on synchronized clean main at merged_sha, never mutates the software PR, never guesses evidence, and opens a separate metrics-only PR changing only metrics/model-evaluations.jsonl. Metrics-finalizer validates and merges that metrics-only PR. Do not implement the project yourself."
hermes kanban --board "$SLUG" create "Project kickoff and architecture" --assignee project-manager --workspace "dir:$TARGET" --body "$KICKOFF_BODY"
echo "Repo: https://github.com/$OWNER/$SLUG"; echo "Local: $TARGET"; echo "Board: $SLUG"; echo "Set the board Project Directory to $TARGET in hermes dashboard before using automatic worktree tasks."
