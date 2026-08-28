#!/usr/bin/env python3
import argparse
from control_plane.evaluation import load_jsonl
from control_plane.model_router import score_models

def main():
    ap=argparse.ArgumentParser(); ap.add_argument("evaluation_file"); ap.add_argument("task_type"); ap.add_argument("--min-samples",type=int,default=3); a=ap.parse_args()
    ranked=score_models(load_jsonl(a.evaluation_file),a.task_type,a.min_samples)
    if not ranked:
        print("No model has enough comparable evidence; use the profile default model."); return 0
    for i,r in enumerate(ranked,1):
        q="n/a" if r.avg_quality is None else f"{r.avg_quality:.2f}/10"; c="n/a" if r.avg_cost_usd is None else f"${r.avg_cost_usd:.4f}"
        print(f"{i}. {r.provider or 'unknown-provider'}/{r.model} score={r.score:.3f} samples={r.samples} success={r.success_rate:.1%} quality={q} avg_cost={c}")
    return 0
if __name__=="__main__": raise SystemExit(main())
