# AXI4-S Arbiter | Slave to Masters

![Test Status](https://img.shields.io/badge/test-passing-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

## Table of Contents

- [Overview](#overview)
- [Parameters](#parameters)
- [Ports](#ports)
- [FuseSoC](#fusesoc)
- [Simulation / Verification](#simulation--verification)
- [License](#license)

## Overview

An AXI4-Stream demultiplexer (one slave to N masters). A single incoming stream is routed to one of `NR_OF_MASTERS_P` output ports based on the `tdest` field of each incoming transaction. The arbiter asserts only the selected master's `tvalid` and holds the connection until `tlast`, ensuring burst atomicity.

FuseSoC core name: `akerlund::axi4s_s2m_arbiter:0`

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `NR_OF_MASTERS_P` | 3 | Number of AXI4-S output ports |
| `AXI_DATA_WIDTH_P` | 32 | Width of `tdata` |
| `AXI_STRB_WIDTH_P` | 4 | Width of `tstrb` |
| `AXI_KEEP_WIDTH_P` | 4 | Width of `tkeep` |
| `AXI_ID_WIDTH_P` | 4 | Width of `tid` |
| `AXI_DEST_WIDTH_P` | 4 | Width of `tdest` (must be wide enough to address `NR_OF_MASTERS_P` outputs) |
| `AXI_USER_WIDTH_P` | 4 | Width of `tuser` |

## Ports

### Clock and reset

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low synchronous reset |

### Slave (input)

| Port | Width | Description |
|---|---|---|
| `slv_tvalid` | 1 | Valid |
| `slv_tready` | 1 | Ready (output) |
| `slv_tdata` | `[AXI_DATA_WIDTH_P-1:0]` | Data |
| `slv_tstrb` | `[AXI_STRB_WIDTH_P-1:0]` | Strobe |
| `slv_tkeep` | `[AXI_KEEP_WIDTH_P-1:0]` | Keep |
| `slv_tlast` | 1 | Last beat |
| `slv_tid` | `[AXI_ID_WIDTH_P-1:0]` | ID |
| `slv_tdest` | `[AXI_DEST_WIDTH_P-1:0]` | Destination (selects output port) |
| `slv_tuser` | `[AXI_USER_WIDTH_P-1:0]` | User |

### Masters (outputs)

| Port | Width | Description |
|---|---|---|
| `mst_tvalid` | `[NR_OF_MASTERS_P-1:0]` | Valid per output (only selected bit asserted) |
| `mst_tready` | `[NR_OF_MASTERS_P-1:0]` | Ready per output |
| `mst_tdata` | `[AXI_DATA_WIDTH_P-1:0]` | Data (broadcast, gated by `tvalid`) |
| `mst_tstrb` | `[AXI_STRB_WIDTH_P-1:0]` | Strobe |
| `mst_tkeep` | `[AXI_KEEP_WIDTH_P-1:0]` | Keep |
| `mst_tlast` | 1 | Last beat |
| `mst_tid` | `[AXI_ID_WIDTH_P-1:0]` | ID |
| `mst_tdest` | `[AXI_DEST_WIDTH_P-1:0]` | Dest |
| `mst_tuser` | `[AXI_USER_WIDTH_P-1:0]` | User |

## FuseSoC

Core name: `akerlund::axi4s_s2m_arbiter:0`

## Simulation / Verification

Two testbench flavors, same coverage:

- **UVM (SystemVerilog)** — `sv/`, uses the AXI4-S VIP (`akerlund::vip_axi4s_agent`).
  Run with `refuse vcs && refuse simv -t tc_arb_simple_test`.
- **cocotb (Python/pyUVM)** — `py/`, reuses the same VIP's cocotb port
  (`submodules/VIP/vip_axi4s_agent/py`). Run with `refuse cocotb -t tb_arb_simple_test`.

| Test case (SV) | cocotb test | Description |
|---|---|---|
| `tc_arb_simple_test` | `tb_arb_simple_test` | Slave agent sends 1024 bursts (1-128 beats) with `tdest` randomized across all output ports; scoreboard verifies correct routing to each and strict FIFO ordering |

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
