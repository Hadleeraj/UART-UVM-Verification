#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${UVM_HOME:?Set UVM_HOME to your installed VCS UVM library}"
mkdir -p results
vcs -full64 -sverilog -timescale=1ns/1ns \
  +incdir+"$UVM_HOME/src" "$UVM_HOME/src/uvm.sv" \
  "$UVM_HOME/src/dpi/uvm_dpi.cc" -CFLAGS -DVCS -f files.f -o simv \
  2>&1 | tee results/compile.log
./simv "$@" 2>&1 | tee results/latest.log
python3 check_log.py results/latest.log
