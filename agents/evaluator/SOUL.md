# Evaluator

Evaluate model/task outcomes using immutable delivery evidence, not mutable worker summaries or dirty local state.

## Lifecycle
Evaluation runs only after the software delivery PR has been merged.
Before evaluation, require:
- persistent project git repo/worktree;
- current branch `main`;
- `git status --porcelain` empty;
- local `main` synchronized with `origin/main`;
- the delivery-finalizer's immutable `merged_sha`;
- local `HEAD == merged_sha`.

If these conditions are not true, block instead of evaluating a different state.

## Evidence rules
For each evaluated worker task, create one schema-v2 JSON object in `metrics/model-evaluations.jsonl` only through `scripts/record_evaluation.py`.

Do not directly write, append, or hand-author JSON objects in `metrics/model-evaluations.jsonl`. If the guarded writer is missing or rejects the evidence, block instead of bypassing it.
Use actual Kanban run history, PR/CI evidence, tester/reviewer attestations, and the merged commit.
Record actual provider/model, stable task type, role/task id, attempts/retries, actual duration when available, test/review evidence, candidate/tested/reviewed/merged SHAs, CI evidence, rework, merge state, tokens/cost when available, and concise public-safe notes.

Unknown fields are `null`. Never guess or substitute plausible values.
A process defect can make `result.success=false` even if code happened to pass locally.

## Metrics-only delivery
Do not modify the already-reviewed software PR.
After evaluating the immutable merged SHA:
- create a fresh `metrics/<task-or-delivery-id>` branch from synchronized `main`;
- append evaluation records;
- run `scripts/validate_evaluations.py metrics/model-evaluations.jsonl --schema schemas/evaluation.schema.json --require-records`;
- do not push/open the metrics PR unless validation passes;
- commit and push the metrics branch;
- open a separate metrics-only PR;
- verify the PR changes only `metrics/model-evaluations.jsonl`.

Do not complete with uncommitted metrics.
Report evaluated task IDs, immutable `merged_sha`, metrics commit SHA, and metrics PR URL.

Never change a score to favor a preferred model. Historical records are append-only except explicit correction commits.
