#!/usr/bin/env python3
import argparse
from datetime import datetime,timezone
from control_plane.evaluation import append_jsonl

def main():
    ap=argparse.ArgumentParser(); ap.add_argument("evaluation_file"); ap.add_argument("--project",required=True); ap.add_argument("--task-id",required=True); ap.add_argument("--task-type",required=True); ap.add_argument("--role",required=True); ap.add_argument("--model",required=True); ap.add_argument("--provider"); ap.add_argument("--selection-reason"); ap.add_argument("--success",action=argparse.BooleanOptionalAction,required=True); ap.add_argument("--reviewer-score",type=float); ap.add_argument("--required-rework",action=argparse.BooleanOptionalAction); ap.add_argument("--attempts",type=int,default=1); ap.add_argument("--duration-seconds",type=float); ap.add_argument("--input-tokens",type=int); ap.add_argument("--output-tokens",type=int); ap.add_argument("--estimated-cost-usd",type=float); ap.add_argument("--merged",action=argparse.BooleanOptionalAction); ap.add_argument("--notes"); a=ap.parse_args()
    if a.reviewer_score is not None and not 0<=a.reviewer_score<=10: ap.error("--reviewer-score must be 0..10")
    rec={"schema_version":1,"timestamp":datetime.now(timezone.utc).isoformat(),"project":a.project,"task_id":a.task_id,"task_type":a.task_type,"role":a.role,"model":{"provider":a.provider,"name":a.model,"selection_reason":a.selection_reason},"execution":{"attempts":a.attempts,"duration_seconds":a.duration_seconds,"input_tokens":a.input_tokens,"output_tokens":a.output_tokens,"estimated_cost_usd":a.estimated_cost_usd},"verification":{"reviewer_score":a.reviewer_score,"required_rework":a.required_rework,"evidence":[]},"result":{"success":a.success,"merged":a.merged,"status":None},"notes":a.notes}
    append_jsonl(a.evaluation_file,rec); print(f"Appended evaluation for {a.task_id} using {a.provider or 'unknown-provider'}/{a.model}"); return 0
if __name__=="__main__": raise SystemExit(main())
