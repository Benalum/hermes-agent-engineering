# Model evaluation design

Use stable task types such as `backend.python.api`, `backend.database.schema`, `frontend.react.component`, `debugging.python`, `testing.unit.python`, `research.technical`, `review.security`, and `documentation.api`.

Required fields: project, task ID, task type, role, provider/model, success/failure.

Recommended: selection rationale, attempts, runtime, tokens/cost, reviewer score 0–10, rework, merge status, and short public-safe evidence.

Do not overfit tiny samples. The reference router requires three comparable records by default; raise this threshold as data accumulates.
