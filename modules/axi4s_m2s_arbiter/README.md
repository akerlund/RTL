# AXI4-S Arbiter | Masters to Slave

![Build Status](https://img.shields.io/badge/build-N/A-lightgrey)
![Test Status](https://img.shields.io/badge/test-N/A-lightgrey)
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

A round-robin AXI4-Stream arbiter that merges `NR_OF_MASTERS_P` AXI4-S master streams into a single slave stream. A rotating pointer scans master `tvalid` signals; when a valid master is found, the arbiter locks onto it until `tlast` is asserted, then advances to the next master. This guarantees burst atomicity — a packet is never interleaved with another.

FuseSoC core name: `akerlund::axi4s_m2s_arbiter:0`

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `NR_OF_MASTERS_P` | 3 | Number of AXI4-S master ports |
| `AXI_DATA_WIDTH_P` | 32 | Width of `tdata` |
| `AXI_STRB_WIDTH_P` | 4 | Width of `tstrb` |
| `AXI_KEEP_WIDTH_P` | 4 | Width of `tkeep` |
| `AXI_ID_WIDTH_P` | 4 | Width of `tid` |
| `AXI_DEST_WIDTH_P` | 4 | Width of `tdest` |
| `AXI_USER_WIDTH_P` | 4 | Width of `tuser` |

## Ports

### Clock and reset

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low synchronous reset |

### Masters (inputs)

| Port | Width | Description |
|---|---|---|
| `mst_tvalid` | `[NR_OF_MASTERS_P-1:0]` | Valid per master |
| `mst_tready` | `[NR_OF_MASTERS_P-1:0]` | Ready per master (output) |
| `mst_tdata` | `[NR_OF_MASTERS_P-1:0][AXI_DATA_WIDTH_P-1:0]` | Data per master |
| `mst_tstrb` | `[NR_OF_MASTERS_P-1:0][AXI_STRB_WIDTH_P-1:0]` | Strobe per master |
| `mst_tkeep` | `[NR_OF_MASTERS_P-1:0][AXI_KEEP_WIDTH_P-1:0]` | Keep per master |
| `mst_tlast` | `[NR_OF_MASTERS_P-1:0]` | Last beat per master |
| `mst_tid` | `[NR_OF_MASTERS_P-1:0][AXI_ID_WIDTH_P-1:0]` | ID per master |
| `mst_tdest` | `[NR_OF_MASTERS_P-1:0][AXI_DEST_WIDTH_P-1:0]` | Dest per master |
| `mst_tuser` | `[NR_OF_MASTERS_P-1:0][AXI_USER_WIDTH_P-1:0]` | User per master |

### Slave (output)

| Port | Width | Description |
|---|---|---|
| `slv_tvalid` | 1 | Valid (output) |
| `slv_tready` | 1 | Ready |
| `slv_tdata` | `[AXI_DATA_WIDTH_P-1:0]` | Data (output) |
| `slv_tstrb` | `[AXI_STRB_WIDTH_P-1:0]` | Strobe (output) |
| `slv_tkeep` | `[AXI_KEEP_WIDTH_P-1:0]` | Keep (output) |
| `slv_tlast` | 1 | Last beat (output) |
| `slv_tid` | `[AXI_ID_WIDTH_P-1:0]` | ID (output) |
| `slv_tdest` | `[AXI_DEST_WIDTH_P-1:0]` | Dest (output) |
| `slv_tuser` | `[AXI_USER_WIDTH_P-1:0]` | User (output) |

## FuseSoC

Core name: `akerlund::axi4s_m2s_arbiter:0`

## Simulation / Verification

Two testbench flavors, same coverage:

- **UVM (SystemVerilog)** — `sv/`, uses the AXI4-S VIP (`akerlund::vip_axi4s_agent`).
  Run with `refuse vcs && refuse simv -t tc_arb_simple_test`.
- **cocotb (Python/pyUVM)** — `py/`, reuses the same VIP's cocotb port
  (`submodules/VIP/vip_axi4s_agent/py`). Run with `refuse cocotb -t tb_arb_simple_test`.

| Test case (SV) | cocotb test | Description |
|---|---|---|
| `tc_arb_simple_test` | `tb_arb_simple_test` | 3 masters each send 1024 bursts (1-128 beats) of COUNTER data concurrently; scoreboard checks strict FIFO ordering into the single slave stream |

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
