#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
echo "[1/5] shell syntax"; for f in scripts/*.sh; do bash -n "$f"; done
echo "[2/5] Python compile"; python3 -m compileall -q control_plane scripts/model_scorecard.py scripts/record_evaluation.py
echo "[3/5] JSON parse"; python3 - <<'PYJSON'
import json
from pathlib import Path
for p in list(Path('schemas').glob('*.json'))+[Path('agents/profiles.json')]: json.loads(p.read_text()); print('  ok',p)
PYJSON
echo "[4/5] unit tests"; python3 -m unittest discover -s tests -v
echo "[5/5] template invariants"; test -f project-template/AGENTS.md; test -f project-template/PROJECT.md; test -f project-template/metrics/model-evaluations.jsonl; test -f project-template/.github/workflows/ci.yml
echo "SMOKE TEST PASS"
