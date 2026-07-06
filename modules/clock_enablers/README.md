# Clock Enablers

## Table of Contents

- [Overview](#overview)
- [clock\_enable](#clock_enable)
- [clock\_enable\_scaler](#clock_enable_scaler)
- [delay\_enable](#delay_enable)
- [frequency\_enable](#frequency_enable)
- [License](#license)

## Overview

A collection of clock-enable generation modules. All share the same design pattern: a counter fires a single-cycle `enable` pulse at a programmed interval. The modules differ in how the interval is specified and what triggers the count.

---

## clock_enable

![Test Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

FuseSoC core: `akerlund::clock_enable:0`

Asserts `enable` for one clock cycle every `cr_enable_period` clock cycles. The counter can be reset externally via `reset_counter_n`.
`cr_enable_period == 0` disables pulses and holds the internal counter at zero.
`cr_enable_period == 1` pulses every clock. Runtime period updates take effect
immediately and can shorten or stretch the current interval.

**Parameters**

| Parameter | Description |
|---|---|
| `COUNTER_WIDTH_P` | Bit width of the period counter |

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low reset |
| `reset_counter_n` | input | Active-low counter reset (does not reset module) |
| `enable` | output | Single-cycle enable pulse |
| `cr_enable_period` | input | Period in clock cycles |

---

## clock_enable_scaler

![Test Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

FuseSoC core: `akerlund::clock_enable_scaler:0`

A clock-enable divider: counts `ing_enable` pulses and asserts `egr_enable` every `cr_enable_period` input pulses. Useful for sub-dividing an existing enable signal rather than free-running clock cycles.
`cr_enable_period == 0` disables output pulses and clears the counter. Sparse
`ing_enable` pulses are counted as events; gaps do not advance the counter.
Runtime period updates take effect on the current in-flight count.

**Parameters**

| Parameter | Description |
|---|---|
| `COUNTER_WIDTH_P` | Bit width of the period counter |

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low reset |
| `reset_counter_n` | input | Active-low counter reset |
| `ing_enable` | input | Incoming enable to divide |
| `egr_enable` | output | Divided enable output |
| `cr_enable_period` | input | Divider ratio |

---

## delay_enable

![Test Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

FuseSoC core: `akerlund::delay_enable:0`

Asserts `delay_out` for one clock cycle exactly `cr_delay_period` clock cycles after a `start` pulse. Only one delay can be in flight at a time; a new `start` while delaying is ignored. `cr_delay_period == 0` turns a `start` pulse into an immediate `delay_out` pulse. Deasserting `reset_counter_n` cancels any in-flight delay.

**Parameters**

| Parameter | Description |
|---|---|
| `COUNTER_WIDTH_P` | Bit width of the delay counter |

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low reset |
| `reset_counter_n` | input | Active-low counter reset |
| `start` | input | Begin the delay |
| `delay_out` | output | Single-cycle pulse after `cr_delay_period` clocks |
| `cr_delay_period` | input | Delay duration in clock cycles |

---

## frequency_enable

![Test Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

FuseSoC core: `akerlund::frequency_enable:0`

Asserts `enable` at a programmable frequency specified in Hz by `cr_enable_frequency`. On startup or whenever the frequency changes, the module uses the external long-division AXI4-S interface to compute the counter period (`SYS_CLK_FREQUENCY / cr_enable_frequency`) and then drives `enable` at that rate.
`cr_enable_frequency == 0` disables output pulses and prevents divider requests.
If the divider reports overflow, the module drops back to the disabled state
until a nonzero frequency is presented again. If the fixed-point quotient rounds
to zero, the period is clamped to one system clock.

**Parameters**

| Parameter | Description |
|---|---|
| `SYS_CLK_FREQUENCY_P` | System clock frequency in Hz (used as dividend) |
| `AXI_DATA_WIDTH_P` | AXI4-S data width to the divider |
| `AXI_ID_WIDTH_P` | AXI4-S ID width |
| `Q_BITS_P` | Number of fractional bits in the fixed-point divider; `Q_BITS_P + $clog2(SYS_CLK_FREQUENCY_P+1)` must fit in `AXI_DATA_WIDTH_P` |
| `AXI4S_ID_P` | ID value used on the AXI4-S divider interface |

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low reset |
| `enable` | output | Single-cycle enable pulse at the configured frequency |
| `cr_enable_frequency` | input | Target frequency in Hz |
| `div_egr_t*` | output | AXI4-S egress to long-division module |
| `div_ing_t*` | input | AXI4-S ingress from long-division module (quotient + overflow) |

**Instantiation example**

```systemverilog
frequency_enable #(
  .SYS_CLK_FREQUENCY_P ( 100_000_000 ),
  .AXI_DATA_WIDTH_P    ( 32          ),
  .AXI_ID_WIDTH_P      ( 2           ),
  .Q_BITS_P            ( 4           ),
  .AXI4S_ID_P          ( 1           )
) u_freq_en (
  .clk                 ( clk                 ),
  .rst_n               ( rst_n               ),
  .enable              ( enable              ),
  .cr_enable_frequency ( 20_000_000          ), // 20 MHz
  .div_egr_tvalid      ( div_egr_tvalid      ),
  .div_egr_tready      ( div_egr_tready      ),
  .div_egr_tdata       ( div_egr_tdata       ),
  .div_egr_tlast       ( div_egr_tlast       ),
  .div_egr_tid         ( div_egr_tid         ),
  .div_ing_tvalid      ( div_ing_tvalid      ),
  .div_ing_tready      ( div_ing_tready      ),
  .div_ing_tdata       ( div_ing_tdata       ),
  .div_ing_tlast       ( div_ing_tlast       ),
  .div_ing_tid         ( div_ing_tid         ),
  .div_ing_tuser       ( div_ing_tuser       )
);
```

---

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).

### Instantiation Template

```verilog
// Used as a dividend to calculate the timer
localparam int SYS_CLK_FREQUENCY_C = 100000000;
// Data width to the divider (or an arbiter between them)
localparam int AXI_DATA_WIDTH_C    = 32;
// Depends on how many connections there are to an arbiter
localparam int AXI_ID_WIDTH_C      = 2;
// The divider is fixed point and the number of Q-bits is need for correct conversions
localparam int Q_BITS_C            = 4;
// Unique ID used by an arbiter
localparam int AXI4S_ID_C          = 1;

// Desired frequency out is a normal integer, e.g., 20MHz
localparam logic [$clog2(SYS_CLK_FREQUENCY_C)-1 : 0] cr_enable_frequency = 20000000;

frequency_enable #(
  .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_C ),
  .AXI_DATA_WIDTH_P    ( AXI_DATA_WIDTH_C    ),
  .AXI_ID_WIDTH_P      ( AXI_ID_WIDTH_C      ),
  .Q_BITS_P            ( Q_BITS_C            ),
  .AXI4S_ID_P          ( AXI4S_ID_C          )
) frequency_enable_i0 (
  .clk                 ( clk                 ),
  .rst_n               ( rst_n               ),
  .enable              ( enable              ),
  .cr_enable_frequency ( cr_enable_frequency ),
  .div_egr_tvalid      ( div_egr_tvalid      ),
  .div_egr_tready      ( div_egr_tready      ),
  .div_egr_tdata       ( div_egr_tdata       ),
  .div_egr_tlast       ( div_egr_tlast       ),
  .div_egr_tid         ( div_egr_tid         ),
  .div_ing_tvalid      ( div_ing_tvalid      ),
  .div_ing_tready      ( div_ing_tready      ),
  .div_ing_tdata       ( div_ing_tdata       ),
  .div_ing_tlast       ( div_ing_tlast       ),
  .div_ing_tid         ( div_ing_tid         ),
  .div_ing_tuser       ( div_ing_tuser       )
);
```

### Verification

The module has merely been verified by eye to see that the desired period out (on the **enable** port) was correct. The simple test bench in **tb_clock_enable** was used. A resulting waveform is shown in Figure 1 below. The first desired frequency is **10Mhz** and is changed to **20Mhz** some time into the simulation. One can verify that the period of the *enable* port is indeed **100ns** at first configuration and then changes to **50ns**.

![Figure 1](https://github.com/akerlund/rtl_common_design/blob/master/.pictures/clock_enable/frequency_enable_simulation.JPG)

*Figure 1. Waveforms from a simulation of the Frequency Enable module.*

## Clock Enable

![Test  Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)


## Delay Enable

![Test  Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)
