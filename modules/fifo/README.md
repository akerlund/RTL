# Synchronous FIFO

![Test Status](https://img.shields.io/badge/test-passing-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Parameters](#parameters)
- [Ports](#ports)
- [Instantiation](#instantiation)
- [FuseSoC](#fusesoc)
- [License](#license)

## Overview

A single-clock synchronous FIFO with parameterizable data width and depth. The top-level `fifo` module is RAM-backed with a small register staging FIFO. Use `fifo_register` directly when a purely register-backed FIFO is desired.

FuseSoC core name: `akerlund::fifo:0`

## Architecture

| File | Description |
|---|---|
| `rtl/fifo.sv` | RAM-backed FIFO wrapper with a small register staging FIFO |
| `rtl/fifo_register.sv` | Register-based FIFO implementation for explicit small-FIFO use |

`fifo_register` uses a circular buffer of flip-flops with separate read and write address pointers. The top-level `fifo` module uses `akerlund::memory_ram`.

An almost-full threshold is supported via `cr_almost_full_level` to allow upstream flow control before the FIFO is completely full.
Both FIFO implementations accept a simultaneous read and write while full: the
read frees one entry and the write stores the incoming word in the same cycle,
so no ingress word is dropped. `sr_max_fill_level` tracks the highest observed
fill level in both implementations.

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `DATA_WIDTH_P` | 32 | Width of each data entry in bits |
| `ADDR_WIDTH_P` | 3 | Address width; FIFO depth = 2^`ADDR_WIDTH_P` entries |

## Ports

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk` | input | 1 | System clock |
| `rst_n` | input | 1 | Active-low synchronous reset |
| `ing_enable` | input | 1 | Write enable |
| `ing_data` | input | `DATA_WIDTH_P` | Write data |
| `ing_full` | output | 1 | Full flag |
| `ing_almost_full` | output | 1 | Almost-full flag (asserted when fill level ≥ `cr_almost_full_level`) |
| `egr_enable` | input | 1 | Read enable |
| `egr_data` | output | `DATA_WIDTH_P` | Read data |
| `egr_empty` | output | 1 | Empty flag |
| `sr_fill_level` | output | `ADDR_WIDTH_P+1` | Current fill level |
| `sr_max_fill_level` | output | `ADDR_WIDTH_P+1` | Watermark: maximum fill level since reset |
| `cr_almost_full_level` | input | `ADDR_WIDTH_P+1` | Programmable almost-full threshold |

## Instantiation

```systemverilog
fifo #(
  .DATA_WIDTH_P         ( 32  ),
  .ADDR_WIDTH_P         ( 4   )   // depth = 16
) u_fifo (
  .clk                  ( clk                  ),
  .rst_n                ( rst_n                ),
  .ing_enable           ( wr_en                ),
  .ing_data             ( wr_data              ),
  .ing_full             ( full                 ),
  .ing_almost_full      ( almost_full          ),
  .egr_enable           ( rd_en                ),
  .egr_data             ( rd_data              ),
  .egr_empty            ( empty                ),
  .sr_fill_level        ( fill_level           ),
  .sr_max_fill_level    ( max_fill_level       ),
  .cr_almost_full_level ( almost_full_thresh   )
);
```

## FuseSoC

Core name: `akerlund::fifo:0`

Dependencies: `akerlund::memory_reg:0`, `akerlund::memory_ram:0`

SVA assertions are included in the `sva/` directory and bound to `fifo_register` automatically.

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
