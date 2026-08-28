#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"; cd "$ROOT"
echo "[1/6] shell syntax"; for f in scripts/*.sh project-template/scripts/*.sh; do bash -n "$f"; done
echo "[2/6] Python compile"; python3 -m compileall -q control_plane scripts/model_scorecard.py scripts/record_evaluation.py
echo "[3/6] JSON parse"; python3 - <<'PYJSON'
import json
from pathlib import Path
for p in list(Path('schemas').glob('*.json'))+[Path('agents/profiles.json')]:
    json.loads(p.read_text())
    print('  ok',p)
PYJSON
echo "[4/6] unit tests"; python3 -m unittest discover -s tests -v
echo "[5/6] template invariants"
test -f project-template/AGENTS.md
test -f project-template/PROJECT.md
test -f project-template/metrics/model-evaluations.jsonl
test -f project-template/.github/workflows/ci.yml
test -x project-template/scripts/verify.sh
test -x project-template/scripts/check_candidate.sh
grep -Fq 'HERMES_VERIFY_PLACEHOLDER' project-template/scripts/verify.sh
grep -Fq 'project-verification:' project-template/.github/workflows/ci.yml
echo "[6/6] immutable-delivery invariants"
grep -Fq 'implementation -> tester -> reviewer -> delivery-finalizer -> evaluator -> metrics-finalizer' agents/project-manager/SOUL.md
grep -Fq 'Never require or preselect `APPROVE`' agents/project-manager/SOUL.md
grep -Fq 'git status --porcelain' agents/tester/SOUL.md
grep -Fq 'HERMES-TEST' agents/tester/SOUL.md
grep -Fq 'HERMES-REVIEW' agents/reviewer/SOUL.md
grep -Fq 'Evaluation runs only after the software delivery PR has been merged' agents/evaluator/SOUL.md
grep -Fq 'PR_STATE' project-template/scripts/check_candidate.sh
grep -Fq 'PR_BASE' project-template/scripts/check_candidate.sh
grep -Fq 'successful software evaluation requires --delivery-valid' scripts/record_evaluation.py
grep -Fxq 'project-template/scripts/check_candidate.sh' MANIFEST.txt
grep -Fxq 'project-template/scripts/verify.sh' MANIFEST.txt
grep -Fq 'do not call `kanban_request_changes`' agents/reviewer/SOUL.md
python3 - <<'PYEVAL'
from pathlib import Path
import json, subprocess, tempfile
sha='0'*40
with tempfile.TemporaryDirectory() as td:
    p=Path(td)/'eval.jsonl'
    subprocess.run([
        'python3','scripts/record_evaluation.py',str(p),
        '--project','smoke','--task-id','t_smoke','--task-type','smoke',
        '--role','coder','--model','smoke-model','--success',
        '--delivery-head-sha',sha,'--tested-sha',sha,'--reviewed-sha',sha,
        '--merged-sha',sha,'--ci-check','project-verification','--ci-passed',
        '--workspace-clean','--pr-head-matched','--evidence-valid',
        '--delivery-valid','--merged'
    ], check=True, stdout=subprocess.DEVNULL)
    row=json.loads(p.read_text())
    assert row['schema_version']==2
    assert row['evidence']['merged_sha']==sha
    assert row['result']['delivery_valid'] is True
print('  ok schema-v2 evaluation writer')
PYEVAL
python3 - <<'PYNEG'
from pathlib import Path
import subprocess, tempfile
sha='0'*40
with tempfile.TemporaryDirectory() as td:
    p=Path(td)/'invalid.jsonl'
    cp=subprocess.run([
        'python3','scripts/record_evaluation.py',str(p),
        '--project','smoke','--task-id','t_invalid','--task-type','python_backend',
        '--role','coder','--model','smoke-model','--success',
        '--delivery-head-sha',sha,'--tested-sha',sha,'--reviewed-sha',sha,
        '--merged-sha',sha,'--ci-check','project-verification',
        '--workspace-clean','--pr-head-matched','--delivery-valid','--merged'
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    assert cp.returncode != 0, 'invalid success without evidence/CI unexpectedly accepted'
print('  ok invalid-success guard')
PYNEG
echo "SMOKE TEST PASS"
