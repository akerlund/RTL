# AXI4-S Synchronous FIFO

![Test Status](https://img.shields.io/badge/test-passing-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

## Table of Contents

- [Overview](#overview)
- [Parameters](#parameters)
- [Ports](#ports)
- [Instantiation](#instantiation)
- [FuseSoC](#fusesoc)
- [Simulation / Verification](#simulation--verification)
- [License](#license)

## Overview

A single-clock AXI4-Stream FIFO. The intended use is to concatenate all AXI4-S sideband signals (`tdata`, `tlast`, etc.) into the `tuser` vector on ingress, and split them back out on egress. This keeps the FIFO generic — only `tuser` width and depth need to be configured.

The underlying storage is provided by `akerlund::fifo`, which automatically selects between a register-based or RAM-based backend depending on total bit capacity vs. `MAX_REG_BYTES_P`.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `TUSER_WIDTH_P` | 32 | Width of the `tuser` data vector (concatenation of all AXI4-S signals to buffer) |
| `ADDR_WIDTH_P` | 7 | Address width; FIFO depth = 2^`ADDR_WIDTH_P` entries |
| `MAX_REG_BYTES_P` | 256 | Threshold in bytes below which registers are used instead of a RAM |

## Ports

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low synchronous reset |
| `ing_tready` | output | 1 | Ingress ready (back-pressure to upstream) |
| `ing_tuser` | input | `TUSER_WIDTH_P` | Ingress data (concatenated AXI4-S signals) |
| `ing_tvalid` | input | 1 | Ingress valid |
| `egr_tready` | input | 1 | Egress ready (back-pressure from downstream) |
| `egr_tuser` | output | `TUSER_WIDTH_P` | Egress data |
| `egr_tvalid` | output | 1 | Egress valid |
| `sr_fill_level` | output | `ADDR_WIDTH_P+1` | Current fill level |
| `sr_max_fill_level` | output | `ADDR_WIDTH_P+1` | Watermark: maximum fill level since reset |
| `sr_almost_full` | output | 1 | Asserted when `sr_fill_level >= cr_almost_full_level` |
| `cr_almost_full_level` | input | `ADDR_WIDTH_P+1` | Programmable almost-full threshold |

## Instantiation

```systemverilog
// Concatenation example: pack tdata + tlast into tuser
assign ing_tuser = {ing_tlast, ing_tdata};
assign {egr_tlast, egr_tdata} = egr_tuser;

axi4s_fifo #(
  .TUSER_WIDTH_P        ( TUSER_WIDTH_C        ),
  .ADDR_WIDTH_P         ( ADDR_WIDTH_C         ),
  .MAX_REG_BYTES_P      ( 256                  )
) u_axi4s_fifo (
  .clk                  ( clk                  ),
  .rst_n                ( rst_n                ),
  .ing_tready           ( ing_tready           ),
  .ing_tuser            ( ing_tuser            ),
  .ing_tvalid           ( ing_tvalid           ),
  .egr_tready           ( egr_tready           ),
  .egr_tuser            ( egr_tuser            ),
  .egr_tvalid           ( egr_tvalid           ),
  .sr_fill_level        ( sr_fill_level        ),
  .sr_max_fill_level    ( sr_max_fill_level    ),
  .sr_almost_full       ( sr_almost_full       ),
  .cr_almost_full_level ( cr_almost_full_level )
);
```

## FuseSoC

Core name: `akerlund::axi4s_fifo:0`

Dependencies: `akerlund::memory_reg:0`, `akerlund::memory_ram:0`, `akerlund::fifo:0`

## Simulation / Verification

Two testbench flavors, same coverage:

- **UVM (SystemVerilog)** — `sv/`, uses the AXI4-S VIP (`akerlund::vip_axi4s_agent`) with
  back-pressure enabled on the egress side. Run with `refuse vcs && refuse simv -t tc_fi_basic`.
- **cocotb (Python/pyUVM)** — `py/`, reuses the same VIP's cocotb port
  (`submodules/VIP/vip_axi4s_agent/py`). Run with `refuse cocotb -t tb_fi_basic`.

| Test case (SV) | cocotb test | Description |
|---|---|---|
| `tc_fi_basic` | `tb_fi_basic` | Master sends 2^16 bursts (1-128 beats) of COUNTER data; scoreboard verifies FIFO-order tdata equality on the egress side |

`sv/tc/eetc_fi_fill_up_read_out.sv` is present but **not compiled** — it is not included by
`fi_tc_pkg.sv` and calls VIP sequence APIs (`axi4s_single_transaction_seq`,
`axi4s_slave_sequential_tready_seq`, `tready_back_pressure_enabled`, `vip_axi4s_config_slv`) that
do not exist anywhere in `vip_axi4s_agent`. It predates the current VIP API and has likely never
compiled; not ported to cocotb for that reason.

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
