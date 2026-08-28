#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-Benalum/hermes-agent-engineering}"
DEST="${2:-$HOME/projects/hermes-agent-engineering}"
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for cmd in git gh rsync; do
  command -v "$cmd" >/dev/null || { echo "ERROR: $cmd required" >&2; exit 1; }
done
gh auth status >/dev/null || { echo "ERROR: run: gh auth login" >&2; exit 1; }

if [[ -e "$DEST/.git" ]]; then
  echo "Using existing clone: $DEST"
else
  mkdir -p "$(dirname "$DEST")"
  git clone "https://github.com/$REPO.git" "$DEST"
fi

cd "$DEST"

# An entirely empty GitHub repository has no main branch. Seed a minimal main
# commit first so the full factory can immediately obey its own PR workflow.
if ! git ls-remote --exit-code origin refs/heads/main >/dev/null 2>&1; then
  git checkout --orphan main
  git rm -rf . >/dev/null 2>&1 || true
  cp "$SOURCE/README.md" README.md
  git add README.md
  git commit -m "chore: initialize Hermes engineering factory"
  git push -u origin main
else
  git fetch origin main
  git checkout -B main origin/main
fi

# Create/recreate the bootstrap branch from current main.
git checkout -B bootstrap/factory-v1 main
rsync -a --delete --exclude .git/ "$SOURCE/" "$DEST/"
git add .

if git diff --cached --quiet; then
  echo "No factory changes to commit."
else
  git commit -m "feat: bootstrap Hermes multi-agent engineering factory"
fi

git push -u origin bootstrap/factory-v1 --force-with-lease

# Avoid creating a duplicate PR if the script is safely rerun.
if gh pr list --repo "$REPO" --head bootstrap/factory-v1 --state open --json number --jq 'length' | grep -qx '0'; then
  gh pr create --repo "$REPO" --base main --head bootstrap/factory-v1 \
    --title "Bootstrap Hermes multi-agent engineering factory" \
    --body "Adds reusable Hermes roles, governance, public-project template, model-performance evaluation/router, and bootstrap/smoke-test tooling."
else
  echo "An open bootstrap/factory-v1 PR already exists."
fi

echo "Factory branch pushed. Review CI and merge the PR when green."
