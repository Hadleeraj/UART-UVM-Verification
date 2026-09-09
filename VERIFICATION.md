# Verification plan and evidence

The baseline run on 9 September 2026 used VCS X-2025.06-SP1 and the installed VCS UVM library selected by EDA Playground. The saved playground invocation did not explicitly set a random seed; no seed value is claimed for this recorded result.

Observed: 95 scoreboard TEST PASSED messages, zero TEST FAILED messages, zero UVM warnings/errors/fatals, and completion at 97,130,450 ns. The run reported 85.58% overall functional coverage, 100% baud/length/parity-enable/stop coverpoints, and 50% payload-pattern coverage. See results/baseline_excerpt.log.

## Pass criteria

Run bash run.sh with a licensed VCS installation and UVM_HOME pointing to its UVM library. The script compiles files.f, runs the simulation, and invokes check_log.py. Pass an explicit supported VCS runtime seed option (for example +ntb_random_seed=1) for a repeatable new run. The shell command is an adaptation of the observed playground invocation; execution on a separate local installation has not been tested here.

The checker requires exactly 95 matching transfers, no TEST FAILED message, and a complete UVM summary with zero errors/fatals. This matters because the original scoreboard logs a mismatch through uvm_info. The archived log is only a summary excerpt and cannot satisfy the 95-message checker by itself; use the complete new run log.

## Coverage interpretation

The monitor leaves op at its default value and the subscriber samples reset transactions. Do not use operation coverage or the aggregate percentage as a closure metric without fixing that sampling. Some TX-data pattern/range bins overlap and the two-stop-bit stimulus covers only a subset of framing combinations.

| Feature | Existing stimulus/check | Follow-up |
|---|---|---|
| Data lengths | 5, 6, 7, 8 bits | Directed boundaries and pattern completeness |
| Baud rates | Six constrained rates; first sequence fixed at 9600 | Explicit configuration matrix and multi-seed run |
| Parity | Enabled/disabled loopback | Independent odd/even model and injected errors |
| Stop bits | One and two stop-bit controls | Independent wire timing checks |
| Reset | Startup reset | Reset mid-frame and recovery |
| Scoreboard | TX data equals RX output | Error severity, counters and watchdog |
| Coverage | Coverpoints and three crosses | Completed-transfer-only sampling and closure analysis |

This verifies a shared-RTL loopback. It does not independently establish UART interoperability or full protocol compliance.
