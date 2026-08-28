from __future__ import annotations
from collections import defaultdict
from dataclasses import dataclass
from typing import Iterable

@dataclass(frozen=True)
class ModelScore:
    model:str; provider:str|None; samples:int; success_rate:float; avg_quality:float|None; rework_efficiency:float; avg_cost_usd:float|None; score:float

def score_models(records:Iterable[dict],task_type:str,min_samples:int=3)->list[ModelScore]:
    buckets=defaultdict(list)
    for row in records:
        if row.get("task_type")!=task_type: continue
        m=row.get("model") or {}; name=m.get("name")
        if name: buckets[(m.get("provider"),name)].append(row)
    out=[]
    for (provider,model),rows in buckets.items():
        if len(rows)<min_samples: continue
        successes=[1.0 if (r.get("result") or {}).get("success") else 0.0 for r in rows]
        qualities=[(r.get("verification") or {}).get("reviewer_score") for r in rows if (r.get("verification") or {}).get("reviewer_score") is not None]
        rework=[(r.get("verification") or {}).get("required_rework") for r in rows if (r.get("verification") or {}).get("required_rework") is not None]
        costs=[(r.get("execution") or {}).get("estimated_cost_usd") for r in rows if (r.get("execution") or {}).get("estimated_cost_usd") is not None]
        success=sum(successes)/len(successes)
        quality=sum(qualities)/len(qualities) if qualities else None
        rework_eff=1.0-(sum(1 for x in rework if x)/len(rework)) if rework else 0.5
        if costs:
            avg_cost=sum(costs)/len(costs); max_cost=max(costs) or 1.0; cost_eff=max(0.0,1.0-(avg_cost/max_cost))
        else: avg_cost=None; cost_eff=0.5
        qnorm=(quality/10.0) if quality is not None else 0.5
        score=.55*success+.30*qnorm+.10*rework_eff+.05*cost_eff
        out.append(ModelScore(model,provider,len(rows),success,quality,rework_eff,avg_cost,score))
    return sorted(out,key=lambda x:(x.score,x.samples),reverse=True)

def choose_model(records:Iterable[dict],task_type:str,min_samples:int=3)->ModelScore|None:
    ranked=score_models(records,task_type,min_samples)
    return ranked[0] if ranked else None
