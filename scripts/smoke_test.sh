#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[1/8] shell syntax"
for f in scripts/*.sh project-template/scripts/*.sh; do
    bash -n "$f"
done

echo "[2/8] Python compile"
python3 -m compileall -q \
    control_plane \
    scripts/model_scorecard.py \
    scripts/record_evaluation.py \
    scripts/validate_evaluations.py \
    project-template/scripts/record_evaluation.py \
    project-template/scripts/validate_evaluations.py

echo "[3/8] JSON parse"
python3 - <<'PYJSON'
import json
from pathlib import Path

paths = list(Path("schemas").glob("*.json"))
paths += [Path("project-template/schemas/evaluation.schema.json")]
paths += [Path("agents/profiles.json")]

for p in paths:
    json.loads(p.read_text())
    print("  ok", p)
PYJSON

echo "[4/8] unit tests"
python3 -m unittest discover -s tests -v

echo "[5/8] template invariants"
test -f project-template/AGENTS.md
test -f project-template/PROJECT.md
test -f project-template/metrics/model-evaluations.jsonl
test -f project-template/.github/workflows/ci.yml

test -x project-template/scripts/verify.sh
test -x project-template/scripts/check_candidate.sh
test -x project-template/scripts/record_evaluation.py
test -x project-template/scripts/validate_evaluations.py

test -f project-template/schemas/evaluation.schema.json

grep -Fq 'HERMES_VERIFY_PLACEHOLDER' \
    project-template/scripts/verify.sh

grep -Fq 'project-verification:' \
    project-template/.github/workflows/ci.yml

grep -Fq 'evaluation-schema:' \
    project-template/.github/workflows/ci.yml

grep -Fq -- '--require-records' \
    project-template/.github/workflows/ci.yml

grep -Fq 'A metrics PR may change only metrics/model-evaluations.jsonl' \
    project-template/.github/workflows/ci.yml

echo "[6/8] immutable-delivery invariants"

grep -Fq \
    'implementation -> tester -> reviewer -> delivery-finalizer -> evaluator -> metrics-finalizer' \
    agents/project-manager/SOUL.md

grep -Fq \
    'Never require or preselect `APPROVE`' \
    agents/project-manager/SOUL.md

grep -Fq 'git status --porcelain' agents/tester/SOUL.md
grep -Fq 'HERMES-TEST' agents/tester/SOUL.md
grep -Fq 'HERMES-REVIEW' agents/reviewer/SOUL.md

grep -Fq \
    'Evaluation runs only after the software delivery PR has been merged' \
    agents/evaluator/SOUL.md

grep -Fq \
    'Do not directly write, append, or hand-author JSON objects' \
    agents/evaluator/SOUL.md

grep -Fq 'PR_STATE' project-template/scripts/check_candidate.sh
grep -Fq 'PR_BASE' project-template/scripts/check_candidate.sh

grep -Fq \
    'successful software evaluation requires --delivery-valid' \
    scripts/record_evaluation.py

grep -Fq 'state=MERGED' agents/project-manager/SOUL.md
grep -Fq 'evaluation-schema' agents/project-manager/SOUL.md

grep -Fxq \
    'project-template/scripts/check_candidate.sh' \
    MANIFEST.txt

grep -Fxq \
    'project-template/scripts/verify.sh' \
    MANIFEST.txt

grep -Fxq \
    'project-template/scripts/record_evaluation.py' \
    MANIFEST.txt

grep -Fxq \
    'project-template/scripts/validate_evaluations.py' \
    MANIFEST.txt

grep -Fxq \
    'project-template/schemas/evaluation.schema.json' \
    MANIFEST.txt

grep -Fq \
    'do not call `kanban_request_changes`' \
    agents/reviewer/SOUL.md

python3 - <<'PYEVAL'
from pathlib import Path
import json
import subprocess
import tempfile

sha = "0" * 40

with tempfile.TemporaryDirectory() as td:
    p = Path(td) / "eval.jsonl"

    subprocess.run([
        "python3",
        "scripts/record_evaluation.py",
        str(p),

        "--project", "smoke",
        "--task-id", "t_smoke",
        "--task-type", "smoke",
        "--role", "coder",
        "--model", "smoke-model",

        "--success",
        "--evidence-valid",
        "--delivery-valid",
        "--merged",

        "--delivery-head-sha", sha,
        "--tested-sha", sha,
        "--reviewed-sha", sha,
        "--merged-sha", sha,

        "--ci-check", "project-verification",
        "--ci-passed",
        "--workspace-clean",
        "--pr-head-matched",

        "--tests-total", "5",
        "--tests-passed", "5",
        "--review-outcome", "APPROVE",
    ], check=True, stdout=subprocess.DEVNULL)

    row = json.loads(p.read_text())

    assert row["schema_version"] == 2
    assert row["evidence"]["merged_sha"] == sha
    assert row["result"]["delivery_valid"] is True
    assert row["verification"]["tests_total"] == 5
    assert row["verification"]["tests_passed"] == 5

    subprocess.run([
        "python3",
        "scripts/validate_evaluations.py",
        str(p),
        "--schema",
        "schemas/evaluation.schema.json",
    ], check=True, stdout=subprocess.DEVNULL)

print("  ok schema-v2 evaluation writer+validator")
PYEVAL

python3 - <<'PYNEG'
from pathlib import Path
import subprocess
import tempfile

sha = "0" * 40

with tempfile.TemporaryDirectory() as td:
    p = Path(td) / "invalid.jsonl"

    cp = subprocess.run([
        "python3",
        "scripts/record_evaluation.py",
        str(p),

        "--project", "smoke",
        "--task-id", "t_invalid",
        "--task-type", "python_backend",
        "--role", "coder",
        "--model", "smoke-model",

        "--success",

        "--delivery-head-sha", sha,
        "--tested-sha", sha,
        "--reviewed-sha", sha,
        "--merged-sha", sha,

        "--ci-check", "project-verification",
        "--workspace-clean",
        "--pr-head-matched",
        "--delivery-valid",
        "--merged",
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    assert cp.returncode != 0, \
        "invalid success without evidence/CI unexpectedly accepted"

print("  ok invalid-success guard")
PYNEG

echo "[7/8] evaluation enforcement"

python3 - <<'PYV13'
from pathlib import Path
import json
import subprocess
import tempfile

bad = {
    "provider": "custom",
    "model": "old-flat-format",
    "task_type": "implementation",
    "role_id": "coder",
    "task_id": "t_old",
    "candidate_sha": "0" * 40,
    "result": {
        "success": True,
    },
}

with tempfile.TemporaryDirectory() as td:
    p = Path(td) / "old-format.jsonl"
    p.write_text(json.dumps(bad) + "\n")

    cp = subprocess.run([
        "python3",
        "scripts/validate_evaluations.py",
        str(p),
        "--schema",
        "schemas/evaluation.schema.json",
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    assert cp.returncode != 0, \
        "obsolete flat evaluation format unexpectedly accepted"

    cp_template = subprocess.run([
        "python3",
        "project-template/scripts/validate_evaluations.py",
        str(p),
        "--schema",
        "project-template/schemas/evaluation.schema.json",
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    assert cp_template.returncode != 0, \
        "template validator accepted obsolete flat evaluation format"

print("  ok obsolete flat metrics rejected")
print("  ok generated-project validator rejects obsolete metrics")
PYV13


echo "[8/8] empty metrics rejection"
python3 - <<'PYEMPTY'
from pathlib import Path
import subprocess
import tempfile

with tempfile.TemporaryDirectory() as td:
    p = Path(td) / "empty.jsonl"
    p.write_text("")

    cp = subprocess.run([
        "python3",
        "scripts/validate_evaluations.py",
        str(p),
        "--schema",
        "schemas/evaluation.schema.json",
        "--require-records",
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    assert cp.returncode != 0, \
        "empty metrics unexpectedly accepted with --require-records"

print("  ok empty metrics rejected")
PYEMPTY

echo "SMOKE TEST PASS"
