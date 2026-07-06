# AXI4 Write Channel Arbiter

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

A parameterizable AXI4 write-channel arbiter that supports either one master to many slaves or many masters to one slave. Unsupported many-master to many-slave topologies fail at elaboration. The correct internal topology is selected automatically at elaboration time based on the `NR_OF_MASTERS_P` parameter.

FuseSoC core name: `akerlund::axi4_write_arbiter:0`

## Submodules

| Module | Condition | Description |
|---|---|---|
| `axi4_write_arbiter_mst_2_slvs` | `NR_OF_MASTERS_P == 1` | One master to N slaves. Uses `awregion` (4-bit, up to 16 values) to select the target slave. If `awregion` is outside `NR_OF_SLAVES_P`, the address is accepted locally, write data is drained, and a `DECERR` write response is returned |
| `axi4_write_arbiter_msts_2_slv` | `NR_OF_MASTERS_P > 1` | N masters to one slave. A rotating counter scans `mst_awvalid` and grants access to the first asserted master; the selected master's write data is routed until `wlast`, and the connection is released on the write-response (`bvalid`/`bready`) handshake |

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `AXI_ID_WIDTH_P` | 4 | Width of AXI ID fields |
| `AXI_ADDR_WIDTH_P` | 32 | Width of address bus |
| `AXI_DATA_WIDTH_P` | 32 | Width of data bus |
| `AXI_STRB_WIDTH_P` | 2 | Width of write strobe |
| `NR_OF_MASTERS_P` | 1 | Number of AXI masters |
| `NR_OF_SLAVES_P` | 2 | Number of AXI slaves |

## Ports

### Clock and reset

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low synchronous reset |

### AXI4 master-side (write address channel)

| Port | Width | Description |
|---|---|---|
| `mst_awid` | `[NR_OF_MASTERS_P-1:0][AXI_ID_WIDTH_P-1:0]` | Write address IDs |
| `mst_awaddr` | `[NR_OF_MASTERS_P-1:0][AXI_ADDR_WIDTH_P-1:0]` | Write addresses |
| `mst_awlen` | `[NR_OF_MASTERS_P-1:0][7:0]` | Burst lengths |
| `mst_awsize` | `[NR_OF_MASTERS_P-1:0][2:0]` | Burst sizes |
| `mst_awburst` | `[NR_OF_MASTERS_P-1:0][1:0]` | Burst types |
| `mst_awregion` | `[NR_OF_MASTERS_P-1:0][3:0]` | Region (used for slave select) |
| `mst_awvalid` | `[NR_OF_MASTERS_P-1:0]` | Address valid |
| `mst_awready` | `[NR_OF_MASTERS_P-1:0]` | Address ready (output) |

### AXI4 master-side (write data channel)

| Port | Width | Description |
|---|---|---|
| `mst_wdata` | `[NR_OF_MASTERS_P-1:0][AXI_DATA_WIDTH_P-1:0]` | Write data |
| `mst_wstrb` | `[NR_OF_MASTERS_P-1:0][AXI_STRB_WIDTH_P-1:0]` | Write strobes |
| `mst_wlast` | `[NR_OF_MASTERS_P-1:0]` | Last beat |
| `mst_wvalid` | `[NR_OF_MASTERS_P-1:0]` | Data valid |
| `mst_wready` | `[NR_OF_MASTERS_P-1:0]` | Data ready (output) |

### AXI4 master-side (write response channel)

| Port | Width | Description |
|---|---|---|
| `mst_bid` | `[AXI_ID_WIDTH_P-1:0]` | Response ID (output) |
| `mst_bresp` | `[1:0]` | Write response (output) |
| `mst_bvalid` | `[NR_OF_MASTERS_P-1:0]` | Response valid (output) |
| `mst_bready` | `[NR_OF_MASTERS_P-1:0]` | Response ready |

### AXI4 slave-side

All slave-side signals mirror the master-side but are sized for `NR_OF_SLAVES_P` connections. `slv_aw*` and `slv_w*` are outputs to the slave; `slv_b*` are inputs from the slave.

## FuseSoC

Core name: `akerlund::axi4_write_arbiter:0`

## Simulation / Verification

The legacy UVM testbench lives under `sv/` and uses the AXI4 VIP (`akerlund::vip_axi4_agent`). The cocotb port lives under `py/` and directly drives the arbiter's flattened AXI4 channels, including delayed `AWREADY`, delayed `WVALID`, and `BREADY` backpressure.

| Test case | Description |
|---|---|
| `tc_awa_basic_write` | Basic write transactions across all configured masters and slaves |
| `tc_awa_invalid_region` | One-master/many-slave invalid `AWREGION` returns `DECERR` without forwarding to any slave |

```bash
refuse vcs && refuse simv --all
refuse cocotb -t tc_awa_basic_write
refuse cocotb -t tc_awa_invalid_region
```

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
