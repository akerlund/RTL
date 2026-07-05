# cocotb TB Porting Plan — RTL/modules

## Context

`submodules/VIP/examples/vip_axi4_agent` and `vip_axi4s_agent` have just finished being
ported to a pyUVM/cocotb flow, and the underlying VIP libraries themselves
(`submodules/VIP/vip_axi4_agent/py`, `submodules/VIP/vip_axi4s_agent/py`) are fully ported.
That port's whole purpose was to unblock this next step: every module TB in `RTL/modules`
that talks AXI4 or AXI4-Stream can now reuse those finished cocotb agents instead of needing
a from-scratch BFM port.

**Goal:** every module in `RTL/modules` that currently has a UVM TB gets a cocotb TB too —
existing SV TB moved into a `sv/` subfolder, new cocotb TB in a sibling `py/` folder,
mirroring the layout the VIP examples already adopted.

**Scope:** only the 14 modules below that already have a UVM TB. 13 modules with **no**
simulation TB today (`clock_enable`, `clock_enable_scaler`, `delay_enable`,
`interfaces/axi4`, `math/lfsr`, `mechanics/button`, `mechanics/encoder`, `mechanics/switch`,
`memory/ram`, `memory/reg`, `synchronizers/{cdc_bit_sync,io,reset}`), plus `fifo` (SVA/formal
only), are **out of scope** — no UVM TB exists to move. Revisit later.

**Depth:** each module's cocotb TB should reach full parity with its existing SV testcases
(every `tc_*.sv` gets a matching passing cocotb testcase) before the module is considered
done.

## Established conventions — read before starting any module

- **`rtl/` never moves.** It's the actual DUT and is compiled by both the SV and cocotb
  flows — it stays at the module root, shared. Only `tb/` and `tc/` move (into `sv/tb/`,
  `sv/tc/`). No module DUT here uses an SV `interface` as a port (all plain `wire`/`logic`),
  so no cocotb flattening wrapper is needed — cocotb attaches directly to the existing rtl/
  ports.
- **Exactly one `.core` file stays at the module root.** `RTL/scripts/refuse.sh`'s
  `_refuse_module_dir` walks up from `$PWD` looking for a directory with exactly one
  `*.core` file — this must keep working. Update only the `tb:` fileset's file paths in
  `<module>.core` from `tb/...` / `tc/...` to `sv/tb/...` / `sv/tc/...`. Do **not** add a
  `.core` file under `py/`.
- **cocotb flow is a plain Makefile, not a FuseSoC flow.** `refuse.sh`'s `cocotb` subcommand
  (already implemented) runs `cd "$module_dir/py" && BUILD_DIR=... TESTCASE=... make` — it
  requires `py/Makefile` and never invokes fusesoc. This differs from
  `vip_axi4_agent_example_py.core`'s Edalize `sim`-flow approach used in the VIP examples;
  follow `refuse.sh`'s contract since it's the established entry point here. Source it with
  `source /home/shared/github/RTL/scripts/refuse.sh` then use:
  - `refuse vcs` — build the SV UVM sim
  - `refuse simv -t <test>` / `refuse simv --all` — run SV testcase(s)
  - `refuse cocotb -t <test>` — run a cocotb testcase (needs `py/Makefile`)
- **No clk/rst VIP agent, no report-server VIP in the cocotb TB.** cocotb owns the clock
  (`cocotb.clock.Clock`); Python `logging` replaces `vip_report_server`. Don't pull
  `vip_clk_rst_agent`/`vip_report_server` into the `py/` side.
- **Reuse the finished VIP cocotb agents directly** — import `vip_axi4_agent`/
  `vip_axi4s_agent` from `submodules/VIP/vip_{axi4,axi4s}_agent/py` the way
  `submodules/VIP/examples/vip_axi4_agent/py/axi4_tc_top.py` bootstraps `sys.path` /
  `PYTHONPATH`. Don't re-derive a BFM.
- **`vip_fixed_point`, `vip_math`, `vip_dsp` have no `py/` port yet.** They're only used by
  SV scoreboards for reference-value math (not stateful UVM agents) — write small
  Python/numpy equivalents per module as needed, not a full class-for-class port.
- **Filenames mirror 1:1** where there's a direct correspondence: `sv/tb/foo.sv` →
  `py/tb/foo.py`, `sv/tc/tc_bar.sv` → `py/tc/tc_bar.py` (subclassing a per-module
  `<x>_base_test.py`, mirroring `sv/tc/<x>_base_test.sv`).

## Per-module mechanical checklist (copy this block's shape per module below)

For each module:
1. Create `sv/`; `git mv tb sv/tb`; `git mv tc sv/tc`.
2. Edit `<module>.core`: update every `tb:` fileset path (`tb/…`→`sv/tb/…`, `tc/…`→`sv/tc/…`).
3. `refuse vcs && refuse simv --all` from the module dir — must stay green (proves the move
   didn't break the SV side) before writing any Python.
3b. If the module has a `REVIEW.md` (untracked, not committed — see below), fix the findings
   in the RTL/TB now, before writing the cocotb port, and re-run step 3.
4. Create `py/Makefile` (standard cocotb `Makefile.sim` include; `VERILOG_SOURCES` → the
   module's unchanged `rtl/*.sv` + a `py/tb/tb_top.sv` flattening wrapper if the DUT has
   array-of-struct ports cocotb/Verilator can't index element-by-element — see the note below).
5. Create `py/tb/` — env/scoreboard/virtual-sequencer-equivalent Python, built on
   `vip_axi4_agent`/`vip_axi4s_agent`.
6. Create `py/tc/` — one file per SV testcase listed below, full parity.
7. `refuse cocotb -t <test>` green for every ported testcase.
8. Update the module's `README.md` (if present) to mention both flows (pattern:
   `submodules/VIP/examples/vip_axi4_agent/README.md`).
9. **Commit this module's changes** (sv move + `.core` update + RTL review fixes + py/ port),
   but do **not** `git add` the module's `REVIEW.md` — it's a scratch working doc, not meant
   to be committed. One commit per module, only after 3 and 7 are both green.

**cocotb TESTCASE naming (established while porting Wave 1):** when a module needs a real
pyuvm `uvm_test` subclass (i.e., anything beyond the trivial `examples` module), give the
`@cocotb.test()` entry function a `tb_` prefix (not `tc_`) to avoid colliding with the
pyuvm test class name in the same file/module namespace — e.g. SV `tc_arb_simple_test.sv`
becomes a Python `tc_arb_simple_test` uvm_test class **and** a `tb_arb_simple_test`
`@cocotb.test()` function in `py/tc/tc_arb_simple_test.py`. `refuse cocotb -t <test>` then
takes the `tb_` name, not the `tc_` name. This mirrors the convention already established in
`submodules/VIP/examples/vip_axi4_agent/py/axi4_tc_top.py` (`tc_axi4_basic` class ↔
`tb_basic` test function). Only `examples/tc_display.py` is exempt (no uvm_test involved, so
the bare SV name is used directly as both the class-free test function name and the
`refuse cocotb -t` argument).

**Array-port flattening wrapper (established while porting Wave 1):** several arbiter/fifo
modules have `NR_OF_MASTERS_P`-style packed array ports (`mst_tvalid[N-1:0]`,
`mst_tdata[N-1:0][W-1:0]`, …). cocotb/Verilator can't address a packed array port
element-by-element the way `vip_axi4s_agent`'s `Axi4sBus`/`Axi4Bus` need (one flat scalar
signal group per agent). Add a small `py/tb/tb_top.sv` that instantiates the real DUT and
flattens each array index into its own named scalar signal group (`mst0_tvalid`,
`mst1_tvalid`, …, matching the SV testbench's own per-master `vip_axi4s_if` instances) —
`Axi4sBus(dut, prefix="mst0_")` etc. then binds directly. `rtl/` itself is never touched.

---

## Wave 0 — bring-up (no protocol VIP; prove the mechanics first)

### `modules/examples` — DONE, COMMITTED

- Protocol: none (vip_bool/vip_report_server only)
- SV testcases to port: `tc_display`
- [x] 1. Move `tb/`→`sv/tb`, `tc/`→`sv/tc`
- [x] 2. Update `examples.core` tb fileset paths (also added the missing `tools: vcs:`
      block to the `uvm` target, matching the fix already applied elsewhere in this repo)
- [x] 3. `refuse vcs && refuse simv -t tc_display` green
- [x] 4. `py/Makefile` (+ `py/tb/tb_top.sv`: `dummy` is a fully empty module and Verilator's
      VPI can't find a root handle for it with zero ports/signals, so a thin `clk`/`rst_n`
      wrapper instantiates `dummy` inside it)
- [x] 5. `py/tb/` — N/A, the SV TB has no env/scoreboard (just `run_test()`)
- [x] 6. `py/tc/tc_display.py`
- [x] 7. `refuse cocotb -t tc_display` green (Verilator 5.050, built this session --
      cocotb 2.0.1 requires >=5.036, only 5.034/5.020 were present before)
- [ ] 8. README update — no README.md exists for this module; skipped (not worth adding
      one just for this)

## Wave 1 — AXI4-Stream, single clock (prove `vip_axi4s_agent` py reuse)

### `modules/axi4s_m2s_arbiter` — DONE, COMMITTED

- Protocol: vip_axi4s_agent
- SV testcases to port: `tc_arb_simple_test`
- [x] 1. Move tb/tc → sv/
- [x] 2. Update `.core` tb fileset paths
- [x] 3. `refuse vcs && refuse simv -t tc_arb_simple_test` green (also had to set
      `uvm_root::get().set_timeout(...)` programmatically in `arb_tb_top.sv` -- `refuse
      simv` invokes the compiled binary directly, bypassing the `.core` file's
      `run_options`, so `+UVM_TIMEOUT` there has no effect; the test's 1024 bursts
      legitimately need more than UVM's 9200-time-unit default)
- [x] 3b. REVIEW.md findings fixed in `rtl/axi4s_m2s_arbiter.sv`: added
      `` `default_nettype none ``, removed the redundant/self-assigning `!output_enable`
      MUX branch, decoupled the FSM's rotate/select from `slv_tready`, added an
      `NR_OF_MASTERS_P < 2` elaboration guard, and cast `LAST_MST_IDX_C` explicitly
      (`MST_SEL_WIDTH_C'(NR_OF_MASTERS_P - 1)`) to clear the width-truncation lint
      warning. "Add fairness/backpressure tests" finding deferred (see REVIEW.md).
- [x] 4. `py/Makefile` (+ `py/tb/tb_top.sv` flattening wrapper — 3 packed master ports
      flattened to `mst0_*`/`mst1_*`/`mst2_*`; `AXI_USER_WIDTH_P` bumped 0→1, see the
      wrapper's header comment)
- [x] 5. `py/tb/` (`arb_env.py`, `arb_scoreboard.py`)
- [x] 6. `py/tc/arb_base_test.py` + `py/tc/tc_arb_simple_test.py`
      (cocotb-visible test name: `tb_arb_simple_test`, per the naming note above)
- [x] 7. `refuse cocotb -t tb_arb_simple_test` green — PASS, 3072/3072 transfers, 0
      failures
- [x] 8. README update

**Found (blocking, out of scope to fix here — no write access to `submodules/VIP`,
owned by a different Unix user):** `vip_axi4s_agent/sv/vip_axi4s_item.sv`'s
`con_tdata_val`/`con_tid`/`con_tdest`/`con_tuser_val` constraints compare an unbounded
running counter directly against a narrower rand field with no wraparound -- once the
counter exceeds the field's max value the constraint is unsatisfiable ("inconsistent
constraints" from VCS's solver). This module's 1024-burst test sits almost exactly at
the 16-bit tdata field's overflow point (statistically a coin-flip per RNG seed whether
a given run trips it) -- confirmed via `git stash` that this is 100% pre-existing and
unrelated to any RTL/TB change made here. **Exact fix** (same idiom as the width-cast
fixes above): `tdata[i] == TDATA_WIDTH_C'(_cfg.tdata_counter + i);` (and the equivalent
cast for `con_tid`/`con_tdest`/`con_tuser_val`). Whoever has write access to
`submodules/VIP` should apply this — it'll affect every module here with a
long-running COUNTER-type test (this one, `axi4s_s2m_arbiter`, and likely others in
later waves).

### `modules/axi4s_s2m_arbiter`
- Protocol: vip_axi4s_agent
- SV testcases to port: `tc_arb_simple_test`
- [x] 1. Move tb/tc → sv/
- [x] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green — NOT YET RUN (Verilator/permission
      blocker, see `examples` above)
- [x] 3b. REVIEW.md findings fixed in `rtl/axi4s_s2m_arbiter.sv`: added a
      `slv_tdest < NR_OF_MASTERS_P` range check before latching `mux_address`/entering
      `WAIT_SLV_TLAST_E` (stall + `$error` on an out-of-range destination instead of
      aliasing onto a valid master), explicit `MST_SEL_WIDTH_C'(slv_tdest)` cast to clear
      the width-truncation lint warning, and a comment documenting why capturing on
      `slv_tvalid` alone (not `slv_tvalid && slv_tready`) is protocol-correct as-is.
      "Add destination-backpressure tests" finding deferred (see REVIEW.md).
- [x] 4. `py/Makefile` (+ `py/tb/tb_top.sv` flattening wrapper for the 3 packed
      `mst_tvalid`/`mst_tready` bits → `mst0_*`/`mst1_*`/`mst2_*`; the payload signals
      are already flat/shared on this DUT, so they're just wired straight through)
- [x] 5. `py/tb/` (`arb_env.py`, `arb_scoreboard.py` — includes the per-master expected-
      tdest check the SV scoreboard has, in addition to the FIFO-order compare)
- [x] 6. `py/tc/arb_base_test.py` + `py/tc/tc_arb_simple_test.py`
      (cocotb-visible test name: `tb_arb_simple_test`)
- [ ] 7. `refuse cocotb -t tb_arb_simple_test` green — WRITTEN, NOT YET RUN (Verilator
      blocker)
- [ ] 8. README update

### `modules/axi4s_fifo`
- Protocol: vip_axi4s_agent
- SV testcases to port: `tc_fi_basic`, `eetc_fi_fill_up_read_out` (note nonstandard filename
  prefix — verify it isn't a typo for `tc_` before assuming it's intentional)
- [ ] 1. Move tb/tc → sv/
- [ ] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green
- [ ] 4. `py/Makefile`
- [ ] 5. `py/tb/` (fi_env equivalent)
- [ ] 6. `py/tc/tc_fi_basic.py`
- [ ] 6b. `py/tc/` port for the fill-up/read-out testcase
- [ ] 7. `refuse cocotb -t <test>` green for both
- [ ] 8. README update

## Wave 2 — AXI4, single clock (prove `vip_axi4_agent` py reuse)

### `modules/axi4_read_arbiter`
- Protocol: vip_axi4_agent
- SV testcases to port: `tc_ara_basic_read`
- [ ] 1. Move tb/tc → sv/
- [ ] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green
- [ ] 4. `py/Makefile`
- [ ] 5. `py/tb/` (ara_env equivalent)
- [ ] 6. `py/tc/tc_ara_basic_read.py`
- [ ] 7. `refuse cocotb -t tc_ara_basic_read` green
- [ ] 8. README update

### `modules/axi4_write_arbiter`
- Protocol: vip_axi4_agent
- SV testcases to port: `tc_awa_basic_write`
- [ ] 1. Move tb/tc → sv/
- [ ] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green
- [ ] 4. `py/Makefile`
- [ ] 5. `py/tb/` (awa_env equivalent)
- [ ] 6. `py/tc/tc_awa_basic_write.py`
- [ ] 7. `refuse cocotb -t tc_awa_basic_write` green
- [ ] 8. README update

## Wave 3 — AXI4-Stream + numeric scoreboard (first need for fixed_point/math ref model)

### `modules/math/cordic`
- Protocol: vip_axi4s_agent
- SV testcases to port: `tc_negative_radian_spin`, `tc_positive_radian_spin`
- [ ] 1. Move tb/tc → sv/
- [ ] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green
- [ ] 4. `py/Makefile`
- [ ] 5. `py/tb/` (cor_env equivalent) + Python reference model for cordic rotation
- [ ] 6. `py/tc/tc_negative_radian_spin.py`
- [ ] 6b. `py/tc/tc_positive_radian_spin.py`
- [ ] 7. `refuse cocotb -t <test>` green for both
- [ ] 8. README update

### `modules/math/long_division`
- Protocol: vip_axi4s_agent; extra deps: vip_fixed_point, vip_math
- SV testcases to port: `tc_negative_divisions`, `tc_overflow_divisions`,
  `tc_positive_divisions`, `tc_random_divisions`
- [ ] 1. Move tb/tc → sv/
- [ ] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green
- [ ] 4. `py/Makefile`
- [ ] 5. `py/tb/` (div_env equivalent) + Python fixed-point division reference model
- [ ] 6. `py/tc/tc_negative_divisions.py`
- [ ] 6b. `py/tc/tc_overflow_divisions.py`
- [ ] 6c. `py/tc/tc_positive_divisions.py`
- [ ] 6d. `py/tc/tc_random_divisions.py`
- [ ] 7. `refuse cocotb -t <test>` green for all four
- [ ] 8. README update

### `modules/math/multiplication`
- Protocol: vip_axi4s_agent; extra deps: vip_fixed_point, vip_math
- SV testcases to port: `tc_corner_multiplications`, `tc_positive_multiplications`,
  `tc_random_multiplications`
- [ ] 1. Move tb/tc → sv/
- [ ] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green
- [ ] 4. `py/Makefile`
- [ ] 5. `py/tb/` (mul_env equivalent), reuse the long_division fixed-point reference model
      where applicable
- [ ] 6. `py/tc/tc_corner_multiplications.py`
- [ ] 6b. `py/tc/tc_positive_multiplications.py`
- [ ] 6c. `py/tc/tc_random_multiplications.py`
- [ ] 7. `refuse cocotb -t <test>` green for all three
- [ ] 8. README update

## Wave 4 — audio fixed-point scoreboard

### `modules/mixer`
- Protocol: vip_axi4s_agent; extra deps: vip_fixed_point, vip_math
- SV testcases to port: `tc_positive_signals`, `tc_random_signals`
- [x] 1. Move tb/tc → sv/
- [x] 2. Update `.core` tb fileset paths
- [x] 3. `refuse vcs && refuse simv --all` green
- [x] 4. `py/Makefile`
- [x] 5. `py/tb/` (mix_env equivalent) + Python gain/mix reference model
- [x] 6. `py/tc/tc_positive_signals.py`
- [x] 6b. `py/tc/tc_random_signals.py`
- [x] 7. `refuse cocotb -t <test>` green for both
- [x] 8. README update

## Wave 5 — clock-domain crossing (first need for multi-clock cocotb pattern)

### `modules/afifo`
- Protocol: vip_axi4s_agent; 2 clock domains (write/read)
- SV testcases to port: `tc_fi_basic`, `tc_fi_fast_to_slow`, `tc_fi_slow_to_fast`
- [x] 1. Move tb/tc → sv/
- [x] 2. Update `.core` tb fileset paths
- [x] 3. `refuse vcs && refuse simv --all` green
- [x] 4. `py/Makefile`
- [x] 5. `py/tb/` (fi_env equivalent) with two independent `cocotb.clock.Clock` drivers
- [x] 6. `py/tc/tc_fi_basic.py`
- [x] 6b. `py/tc/tc_fi_fast_to_slow.py`
- [x] 6c. `py/tc/tc_fi_slow_to_fast.py`
- [x] 7. `refuse cocotb -t <test>` green for all three
- [x] 8. README update

### `modules/synchronizers/cdc_vector_sync`
- Protocol: vip_axi4s_agent; 2 clock domains
- SV testcases to port: `tc_vec_fast_to_slow`, `tc_vec_slow_to_fast`
- [x] 1. Move tb/tc → sv/
- [x] 2. Update `.core` tb fileset paths
- [x] 3. `refuse vcs && refuse simv --all` green
- [x] 4. `py/Makefile`
- [x] 5. `py/tb/` (vec_env equivalent), reuse afifo's multi-clock pattern
- [x] 6. `py/tc/tc_vec_fast_to_slow.py`
- [x] 6b. `py/tc/tc_vec_slow_to_fast.py`
- [x] 7. `refuse cocotb -t <test>` green for both
- [x] 8. README update

## Wave 6 — register-based (most complex; reuse the RAL port pattern)

### `modules/oscillator`
- Protocol: vip_axi4_agent; uvm_reg (RAL)
- SV testcases to port: `tc_osc_duty_cycle_sweep`, `tc_osc_frequency_test`
- [ ] 1. Move tb/tc → sv/ (include `tb/uvm_reg/`)
- [ ] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green
- [ ] 4. `py/Makefile`
- [ ] 5. `py/tb/` (osc_env equivalent) + `py/tb/uvm_reg/` RAL, reusing the pyuvm reg pattern
      from `submodules/VIP/examples/vip_axi4_agent/py/tb/uvm_reg/{axi4_block,register_model}.py`
      and `vip_axi4_adapter.py`
- [ ] 6. `py/tc/tc_osc_duty_cycle_sweep.py`
- [ ] 6b. `py/tc/tc_osc_frequency_test.py`
- [ ] 7. `refuse cocotb -t <test>` green for both
- [ ] 8. README update

### `modules/dsp/iir_biquad_filter`
- Protocol: vip_axi4_agent + vip_axi4s_agent; uvm_reg (RAL); extra deps: vip_fixed_point,
  vip_math, vip_dsp
- SV testcases to port: `tc_iir_basic_configuration`, `tc_iir_coefficient_check`,
  `tc_iir_reconfiguration`
- [ ] 1. Move tb/tc → sv/ (include `tb/uvm_reg/`)
- [ ] 2. Update `.core` tb fileset paths
- [ ] 3. `refuse vcs && refuse simv --all` green
- [ ] 4. `py/Makefile`
- [ ] 5. `py/tb/` (iir_env equivalent) + RAL (reuse oscillator's port) + Python biquad
      reference model (vip_dsp equivalent)
- [ ] 6. `py/tc/tc_iir_basic_configuration.py`
- [ ] 6b. `py/tc/tc_iir_coefficient_check.py`
- [ ] 6c. `py/tc/tc_iir_reconfiguration.py`
- [ ] 7. `refuse cocotb -t <test>` green for all three
- [ ] 8. README update

---

## Out of scope (flagged for a later decision)

No UVM TB exists to move for these — decide later whether they get a UVM TB, a cocotb-only
TB, or stay as-is:
- `modules/clock_enablers/clock_enable`
- `modules/clock_enablers/clock_enable_scaler`
- `modules/clock_enablers/delay_enable`
- `modules/interfaces/axi4`
- `modules/math/lfsr`
- `modules/mechanics/button`
- `modules/mechanics/encoder`
- `modules/mechanics/switch`
- `modules/memory/ram`
- `modules/memory/reg`
- `modules/synchronizers/cdc_bit_sync`
- `modules/synchronizers/io`
- `modules/synchronizers/reset`
- `modules/fifo` (has an SVA/formal flow via `scripts/fca.tcl`/`scripts/fpv.tcl`, no sim TB)
