# Synchronizers

## Table of Contents

- [Overview](#overview)
- [io\_synchronizer](#io_synchronizer)
- [reset\_synchronizer](#reset_synchronizer)
- [cdc\_bit\_sync](#cdc_bit_sync)
- [cdc\_vector\_sync](#cdc_vector_sync)
- [License](#license)

## Overview

A collection of CDC (clock-domain crossing) and I/O synchronizer primitives. All modules use a wrapper-around-core pattern so that synthesis constraints can be applied uniformly with a single Tcl regexp targeting the inner `*_core_i0` instance name.

---

## IO

### io_synchronizer

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA Status](https://img.shields.io/badge/fpga-verified-green)

FuseSoC core: `akerlund::io_synchronizer:0`

Synchronizes a single-bit input from an I/O pin to the system clock domain using a two-stage flip-flop chain, reducing metastability probability to negligible levels. The output resets low. This primitive is for one bit only; multi-bit buses need a handshake, Gray code, or another CDC-safe structure.

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | Destination clock |
| `rst_n` | input | Active-low reset |
| `bit_ingress` | input | Asynchronous input bit |
| `bit_egress` | output | Synchronized output bit |

**Constraint (Vivado)**

```tcl
set_property -quiet ASYNC_REG TRUE \
  [get_cells -hier -regexp .*io_synchronizer_core_i0/bit_egress.*]
```

---

## Reset

### reset_synchronizer

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA Status](https://img.shields.io/badge/fpga-verified-green)

FuseSoC core: `akerlund::reset_synchronizer:0`

Synchronizes an asynchronous reset to a clock domain (async assert, synchronous deassert). The release path is the two-stage `io_synchronizer` plus one final register, so reset deassertion appears after three destination-clock rising edges.

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | Destination clock |
| `rst_async_n` | input | Asynchronous active-low reset input |
| `rst_sync_n` | output | Synchronously deasserted reset output |

**Constraint (Vivado)**

```tcl
set_property -quiet ASYNC_REG TRUE \
  [get_cells -hier -regexp .*reset_synchronizer_core_i0/reset_origin_n.*]
set_property -quiet ASYNC_REG TRUE \
  [get_cells -hier -regexp .*io_synchronizer_core_i0/bit_egress.*]
```

---

## CDC

### cdc_bit_sync

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA Status](https://img.shields.io/badge/fpga-verified-green)

FuseSoC core: `akerlund::cdc_bit_sync:0`

Synchronizes a single bit between two unrelated clock domains using a source-domain staging flop followed by a two-stage destination synchronizer chain. This is a level synchronizer, not an event/pulse synchronizer; the source value must be held long enough for the destination clock domain to sample it. Pulse-style events need a toggle or handshake synchronizer.

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk_src` | input | Source clock |
| `rst_src_n` | input | Active-low reset (source domain) |
| `clk_dst` | input | Destination clock |
| `rst_dst_n` | input | Active-low reset (destination domain) |
| `src_bit` | input | Input bit (source domain) |
| `dst_bit` | output | Synchronized bit (destination domain) |

**Constraint (Vivado)**

```tcl
set_property -quiet ASYNC_REG TRUE \
  [get_cells -hier -regexp .*cdc_bit_sync_core_i0/dst_bit.*]
```

---

### cdc_vector_sync

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA Status](https://img.shields.io/badge/fpga-verified-green)

FuseSoC core: `akerlund::cdc_vector_sync:0`

Synchronizes a multi-bit vector between two clock domains using a four-handshake protocol: a `valid` flag is synchronized source→destination via `cdc_bit_sync`, and an `ack` flag is returned destination→source via a second `cdc_bit_sync`. The vector itself is only sampled in the destination domain after the synchronized `valid` arrives, so the data is stable during capture.

The legacy UVM testbench for `cdc_vector_sync` lives under
`cdc_vector_sync/sv/`. The cocotb port lives under `cdc_vector_sync/py/` and
uses two independent `cocotb.clock.Clock` drivers with a direct handshake
scoreboard.

**Parameters**

| Parameter | Description |
|---|---|
| `DATA_WIDTH_P` | Width of the vector to transfer |

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk_src` / `rst_src_n` | input | Source clock and reset |
| `clk_dst` / `rst_dst_n` | input | Destination clock and reset |
| `ing_vector` | input | Vector to transfer (source domain) |
| `ing_valid` | input | Initiate transfer |
| `ing_ready` | output | Source ready for next transfer |
| `egr_vector` | output | Transferred vector (destination domain) |
| `egr_valid` | output | Transfer complete pulse (destination domain) |
| `egr_ready` | input | Destination consumed the data |

**Verification**

```sh
cd /home/shared/github/RTL/modules/synchronizers/cdc_vector_sync
source /home/shared/github/RTL/scripts/refuse.sh
refuse cocotb -t tc_vec_fast_to_slow
refuse cocotb -t tc_vec_slow_to_fast
```

---

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
