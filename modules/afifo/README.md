# Asynchronous FIFO

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Parameters](#parameters)
- [Ports](#ports)
- [Usage](#usage)
- [Dependencies](#dependencies-fusesoc)
- [Simulation / Verification](#simulation--verification)
- [VCS Quickstart](#vcs-quickstart)
- [License](#license)

## Overview

An asynchronous (dual-clock) FIFO implemented in SystemVerilog. It is intended for clock-domain crossing (CDC) between two unrelated clocks, with no requirement for any frequency relationship between them.

Pointer synchronization is done with gray-code counters and two-stage flip-flop chains, following the well-known technique from Clifford E. Cummings' *Simulation and Synthesis Techniques for Asynchronous FIFO Design* (SNUG 2002). This guarantees that only one bit changes per clock edge as a pointer crosses domains, making metastability the only failure mode — and the two-stage synchronizer reduces that probability to negligible levels.

A small output register FIFO is placed after the core on the read side. This decouples the CDC logic from the consumer and improves read-side throughput by keeping data pre-fetched and ready.

## Architecture

The module is composed of three RTL files:

| File | Description |
|---|---|
| `rtl/afifo_core.sv` | Core async FIFO: dual-port RAM with gray-coded write/read pointers, two-stage synchronizer chains crossing each pointer into the opposite clock domain |
| `rtl/afifo.sv` | Top-level wrapper: instantiates `afifo_core` and a small output register FIFO (`fifo_register`) on the read side; the register FIFO is auto-filled from the core when space is available, decoupling the CDC logic from the consumer |
| `rtl/gray_to_bin.sv` | Combinational gray-to-binary converter used for fill-level status signals |

The write-side fill level is derived from the gray-coded pointers inside `afifo_core` and reported back in the write-clock domain. The read-side fill level sums the core's read-domain count with the register FIFO's depth.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `DATA_WIDTH_P` | 128 | Width of the data bus in bits |
| `ADDR_WIDTH_P` | 2 | Address width; FIFO depth = 2^`ADDR_WIDTH_P` entries |

## Ports

### Write clock domain

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk_wp` | input | 1 | Write clock |
| `rst_wp_n` | input | 1 | Active-low reset (write domain) |
| `wp_write_en` | input | 1 | Write enable |
| `wp_data_in` | input | `DATA_WIDTH_P` | Write data |
| `wp_fifo_full` | output | 1 | FIFO full flag (write domain) |

### Read clock domain

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk_rp` | input | 1 | Read clock |
| `rst_rp_n` | input | 1 | Active-low reset (read domain) |
| `rp_read_en` | input | 1 | Read enable |
| `rp_data_out` | output | `DATA_WIDTH_P` | Read data |
| `rp_fifo_empty` | output | 1 | FIFO empty flag (read domain) |

### Status / observability

| Port | Direction | Width | Description |
|---|---|---|---|
| `sr_wp_fill_level` | output | `ADDR_WIDTH_P+1` | Current fill level (write domain) |
| `sr_wp_max_fill_level` | output | `ADDR_WIDTH_P+1` | Watermark: maximum fill level seen since reset (write domain) |
| `sr_rp_fill_level` | output | `ADDR_WIDTH_P+1` | Current fill level (read domain) |

## Usage

```systemverilog
afifo #(
  .DATA_WIDTH_P         ( 32          ),
  .ADDR_WIDTH_P         ( 4           )  // depth = 16
) u_afifo (
  .clk_wp               ( wr_clk      ),
  .rst_wp_n             ( wr_rst_n    ),
  .clk_rp               ( rd_clk      ),
  .rst_rp_n             ( rd_rst_n    ),
  .wp_write_en          ( wr_en       ),
  .wp_data_in           ( wr_data     ),
  .wp_fifo_full         ( wr_full     ),
  .rp_read_en           ( rd_en       ),
  .rp_data_out          ( rd_data     ),
  .rp_fifo_empty        ( rd_empty    ),
  .sr_wp_fill_level     ( wr_fill     ),
  .sr_wp_max_fill_level ( wr_fill_max ),
  .sr_rp_fill_level     ( rd_fill     )
);
```

## Dependencies (FuseSoC)

| Core | Purpose |
|---|---|
| `akerlund::cdc_bit_sync:0` | Two-stage synchronizer used for pointer crossing |
| `akerlund::memory_reg:0` | Register-based memory primitive |
| `akerlund::memory_ram:0` | RAM primitive for the FIFO storage |
| `akerlund::fifo:0` | Output register FIFO on the read side |

FuseSoC core name: `akerlund::afifo:0`

## Simulation / Verification

The legacy testbench uses UVM and is driven by an AXI4-Stream VIP. It lives
under `sv/`. A cocotb port lives under `py/` and drives the write/read FIFO
interfaces directly with independent write/read clocks.

Three test cases are provided in both flows:

| Test case | Description |
|---|---|
| `tc_fi_basic` | Basic write/read at equal clock frequencies |
| `tc_fi_fast_to_slow` | Write at ~113 MHz, read at 5 MHz (fast-to-slow CDC) |
| `tc_fi_slow_to_fast` | Write at 5 MHz, read at ~113 MHz (slow-to-fast CDC) |

Run the cocotb tests:

```sh
source /home/shared/github/RTL/scripts/refuse.sh
refuse cocotb -t tc_fi_basic
refuse cocotb -t tc_fi_fast_to_slow
refuse cocotb -t tc_fi_slow_to_fast
```

## VCS Quickstart

From the RTL repository root, build and run the default UVM test with VCS:

```sh
cd /home/shared/github/RTL
source ./scripts/refuse.sh
cd modules/afifo
refuse vcs
refuse simv -t tc_fi_basic
```

To make `refuse` available in every shell, source it from your shell startup:

```sh
source /home/shared/github/RTL/scripts/refuse.sh
```

The wrapper compiles `fi_tb_top` into `rundir/vcs` with FuseSoC/VCS and runs:

```sh
+UVM_TESTNAME=tc_fi_basic
```

Each test writes a log named after the test case in `rundir/vcs`.

Run one specific test:

```sh
refuse simv -t fi_fast_to_slow
```

Run all AFIFO `tc_*.sv` tests:

```sh
refuse simv --all
```

## License

Copyright (C) 2021 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
