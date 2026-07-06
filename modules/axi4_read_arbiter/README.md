# AXI4 Read Channel Arbiter

![Build Status](https://img.shields.io/badge/BUILD-PASSING-green)
![Test Status](https://img.shields.io/badge/TEST-PASSING-green)
![Synth Status](https://img.shields.io/badge/SYNTHESIS-PASSING-green)
![FPGA Status](https://img.shields.io/badge/FPGA-PASSING-green)

## Table of Contents

- [Overview](#overview)
- [Submodules](#submodules)
- [Parameters](#parameters)
- [Ports](#ports)
- [FuseSoC](#fusesoc)
- [Simulation / Verification](#simulation--verification)
- [License](#license)

## Overview

A parameterizable AXI4 read-channel arbiter that supports either one master to many slaves or many masters to one slave. Unsupported many-master to many-slave topologies fail at elaboration. The correct internal topology is selected automatically at elaboration time based on the `NR_OF_MASTERS_P` parameter.

FuseSoC core name: `akerlund::axi4_read_arbiter:0`

## Submodules

| Module | Condition | Description |
|---|---|---|
| `axi4_read_arbiter_mst_2_slvs` | `NR_OF_MASTERS_P == 1` | One master to N slaves. Uses `arregion` (4-bit, up to 16 values) to select the target slave. If `arregion` is outside `NR_OF_SLAVES_P`, the address is accepted locally and a single-beat `DECERR` read response is returned |
| `axi4_read_arbiter_msts_2_slv` | `NR_OF_MASTERS_P > 1` | N masters to one slave. A rotating counter scans `mst_arvalid` and grants access to the first asserted master; one read burst is outstanding and the connection is released on the `rlast` handshake |

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `AXI_ID_WIDTH_P` | 4 | Width of AXI ID fields |
| `AXI_ADDR_WIDTH_P` | 32 | Width of address bus |
| `AXI_DATA_WIDTH_P` | 16 | Width of data bus |
| `NR_OF_MASTERS_P` | 1 | Number of AXI masters |
| `NR_OF_SLAVES_P` | 2 | Number of AXI slaves |

## Ports

### Clock and reset

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low synchronous reset |

### AXI4 master-side (read address channel)

| Port | Width | Description |
|---|---|---|
| `mst_arid` | `[NR_OF_MASTERS_P-1:0][AXI_ID_WIDTH_P-1:0]` | Read address IDs |
| `mst_araddr` | `[NR_OF_MASTERS_P-1:0][AXI_ADDR_WIDTH_P-1:0]` | Read addresses |
| `mst_arlen` | `[NR_OF_MASTERS_P-1:0][7:0]` | Burst lengths |
| `mst_arsize` | `[NR_OF_MASTERS_P-1:0][2:0]` | Burst sizes |
| `mst_arburst` | `[NR_OF_MASTERS_P-1:0][1:0]` | Burst types |
| `mst_arregion` | `[NR_OF_MASTERS_P-1:0][3:0]` | Region (used for slave select) |
| `mst_arvalid` | `[NR_OF_MASTERS_P-1:0]` | Address valid |
| `mst_arready` | `[NR_OF_MASTERS_P-1:0]` | Address ready (output) |

### AXI4 master-side (read data channel)

| Port | Width | Description |
|---|---|---|
| `mst_rid` | `[AXI_ID_WIDTH_P-1:0]` | Read ID (output) |
| `mst_rresp` | `[1:0]` | Response (output) |
| `mst_rdata` | `[AXI_DATA_WIDTH_P-1:0]` | Read data (output) |
| `mst_rlast` | 1 | Last beat (output) |
| `mst_rvalid` | `[NR_OF_MASTERS_P-1:0]` | Data valid (output) |
| `mst_rready` | `[NR_OF_MASTERS_P-1:0]` | Data ready |

### AXI4 slave-side (read address channel)

| Port | Width | Description |
|---|---|---|
| `slv_arid` | `[AXI_ID_WIDTH_P-1:0]` | Read address ID (output) |
| `slv_araddr` | `[AXI_ADDR_WIDTH_P-1:0]` | Read address (output) |
| `slv_arvalid` | `[NR_OF_SLAVES_P-1:0]` | Address valid (output) |
| `slv_arready` | `[NR_OF_SLAVES_P-1:0]` | Address ready |

### AXI4 slave-side (read data channel)

| Port | Width | Description |
|---|---|---|
| `slv_rid` | `[NR_OF_SLAVES_P-1:0][AXI_ID_WIDTH_P-1:0]` | Read IDs |
| `slv_rdata` | `[NR_OF_SLAVES_P-1:0][AXI_DATA_WIDTH_P-1:0]` | Read data |
| `slv_rlast` | `[NR_OF_SLAVES_P-1:0]` | Last beat |
| `slv_rvalid` | `[NR_OF_SLAVES_P-1:0]` | Data valid |
| `slv_rready` | `[NR_OF_SLAVES_P-1:0]` | Data ready (output) |

## FuseSoC

Core name: `akerlund::axi4_read_arbiter:0`

## Simulation / Verification

The legacy UVM testbench lives under `sv/` and uses the AXI4 VIP (`akerlund::vip_axi4_agent`). The cocotb port lives under `py/` and directly drives the arbiter's flattened AXI4 channels, including delayed `ARREADY` and `RREADY` backpressure.

| Test case | Description |
|---|---|
| `tc_ara_basic_read` | Basic read transactions across all configured masters and slaves |
| `tc_ara_invalid_region` | One-master/many-slave invalid `ARREGION` returns a single-beat `DECERR` without forwarding to any slave |

```bash
refuse vcs && refuse simv --all
refuse cocotb -t tc_ara_basic_read
refuse cocotb -t tc_ara_invalid_region
```

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
