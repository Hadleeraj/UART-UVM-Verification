#!/usr/bin/env python3
"""Check UART transfers and the UVM summary, including info-level mismatches."""
import re
import sys
from pathlib import Path
text = Path(sys.argv[1] if len(sys.argv)>1 else "results/latest.log").read_text(errors="replace")
problems=[]
for severity in ("UVM_ERROR", "UVM_FATAL"):
    counts=re.findall(r"(?m)^"+severity+r"\s*:\s*(\d+)\s*$",text)
    if not counts or int(counts[-1]) != 0:
        problems.append(severity+" summary missing or nonzero")
passes=len(re.findall(r"\[SCO\] TEST PASSED",text))
if passes != 95:
    problems.append(f"expected 95 matching transfers, found {passes}")
if "TEST FAILED" in text:
    problems.append("scoreboard mismatch reported")
if problems:
    print("FAIL: "+"; ".join(problems))
    sys.exit(1)
print("PASS: 95 matching transfers and zero UVM errors/fatals")
