from __future__ import annotations
import json
from pathlib import Path

def load_jsonl(path: str | Path) -> list[dict]:
    p=Path(path)
    if not p.exists(): return []
    rows=[]
    for n,line in enumerate(p.read_text(encoding="utf-8").splitlines(),1):
        if not line.strip(): continue
        try: rows.append(json.loads(line))
        except json.JSONDecodeError as exc: raise ValueError(f"invalid JSONL at {p}:{n}: {exc}") from exc
    return rows

def append_jsonl(path: str | Path, record: dict) -> None:
    p=Path(path); p.parent.mkdir(parents=True,exist_ok=True)
    with p.open("a",encoding="utf-8") as fh: fh.write(json.dumps(record,sort_keys=True)+"\n")
