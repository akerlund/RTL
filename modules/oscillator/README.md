# Oscillator

![Test Status](https://img.shields.io/badge/test-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-pass-green)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Parameters](#parameters)
- [Ports](#ports)
- [FuseSoC](#fusesoc)
- [Simulation / Verification](#simulation--verification)
- [Synthesis](#synthesis)
- [License](#license)

## Overview

A multi-waveform digital oscillator with AXI4 register control. Four waveform types are supported:

- **Square** — duty-cycle configurable
- **Triangle**
- **Sawtooth**
- **Sine** — computed via the CORDIC module

The output frequency is set by a configuration register (`cr_frequency`) and is derived by dividing the system clock frequency using the external long-division interface. The oscillator connects to external CORDIC and long-division AXI4-S peripherals for sine computation and period calculation respectively.

FuseSoC core name: `akerlund::oscillator:0`

## Architecture

| File | Description |
|---|---|
| `oscillator_top.sv` | Top-level: instantiates the core and waveform generators |
| `oscillator_core.sv` | FSM: handles frequency changes, drives CORDIC and divider |
| `osc_square_top/core.sv` | Square wave generator with duty-cycle control |
| `osc_triangle_top/core.sv` | Triangle wave generator |
| `osc_saw_top/core.sv` | Sawtooth wave generator |
| `osc_sin_top.sv` | Sine output multiplexer |
| `osc_axi_slave.sv` | AXI4 register slave (frequency, duty cycle, waveform select) |
| `oscillator_system.sv` | System wrapper used by the testbench |

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `SYS_CLK_FREQUENCY_P` | — | System clock frequency in Hz |
| `PRIME_FREQUENCY_P` | — | Minimum supported output frequency in Hz |
| `WAVE_WIDTH_P` | — | Output waveform bit width |
| `DUTY_CYCLE_DIVIDER_P` | — | Duty-cycle resolution divider |
| `N_BITS_P` | — | Fixed-point total bits |
| `Q_BITS_P` | — | Fixed-point fractional bits |
| `AXI_DATA_WIDTH_P` | — | AXI4-S data width (for divider/CORDIC interfaces) |
| `AXI_ID_WIDTH_P` | — | AXI4-S ID width |
| `AXI_ID_P` | — | AXI4-S ID value used by this module |

## Ports

### Clock and reset

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low reset |

### Waveform output

| Port | Direction | Width | Description |
|---|---|---|---|
| `waveform` | output | `WAVE_WIDTH_P` | Selected waveform output (signed) |

### Long-division interface (AXI4-S)

| Port | Direction | Description |
|---|---|---|
| `div_egr_t*` | output | Requests to the long-division module |
| `div_ing_t*` | input | Quotient responses from the long-division module |

### CORDIC interface (AXI4-S)

| Port | Direction | Description |
|---|---|---|
| `egr_cor_t*` | output | Angle requests to the CORDIC module |
| `cor_ing_t*` | input | Sine/cosine responses from the CORDIC module |

### Configuration registers

| Port | Direction | Width | Description |
|---|---|---|---|
| `cr_waveform_select` | input | 2 | Waveform selection: `00`=square, `01`=triangle, `10`=sawtooth, `11`=sine |
| `cr_frequency` | input | `N_BITS_P` | Output frequency in Hz (fixed-point) |
| `cr_duty_cycle` | input | `N_BITS_P` | Duty cycle for square wave |

## FuseSoC

Core name: `akerlund::oscillator:0`

Dependencies: `akerlund::long_division:0`, `akerlund::cordic:0`, `akerlund::multiplication:0`, `akerlund::clock_enable:0`, `akerlund::clock_enable_scaler:0`, `akerlund::delay_enable:0`, `akerlund::frequency_enable:0`, `akerlund::mixer:0`

## Simulation / Verification

The legacy SystemVerilog/UVM testbench lives under `sv/` and uses AXI4 register access.
A cocotb testbench lives under `py/`; it drives a small Python register model onto the
plain configuration inputs of `oscillator_system` and performs self-checking waveform
activity/duty-cycle checks.

| Test case | Description |
|---|---|
| `tc_osc_frequency_test` | Configures several output frequencies and checks the waveform period |
| `tc_osc_duty_cycle_sweep` | Sweeps the duty cycle of the square wave output |

Run the flows from this module directory:

```sh
bash /home/shared/github/RTL/scripts/refuse.sh vcs
bash /home/shared/github/RTL/scripts/refuse.sh simv --all
bash /home/shared/github/RTL/scripts/refuse.sh cocotb -t tc_osc_frequency_test
bash /home/shared/github/RTL/scripts/refuse.sh cocotb -t tc_osc_duty_cycle_sweep
```

## Synthesis

Out of context synthesis for a Xilinx `7z020clg484-1` FPGA with the following parameters:

```
SYS_CLK_FREQUENCY_P  = 200_000_000
PRIME_FREQUENCY_P    = 1_000_000
WAVE_WIDTH_P         = 24
DUTY_CYCLE_DIVIDER_P = 1000
N_BITS_P             = 32
Q_BITS_P             = 22
AXI_DATA_WIDTH_P     = 32
AXI_ID_WIDTH_P       = 4
```

| Resource | Used | Available | Util% |
|---|---|---|---|
| Slice LUTs | 687 | 53200 | 1.29% |
| Slice Registers | 609 | 106400 | 0.57% |
| DSP48E1 | 10 | 220 | 4.55% |

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).

![Build Status](https://img.shields.io/badge/Square-Simulated-green)
![Build Status](https://img.shields.io/badge/Triangle-Simulated-green)
![Build Status](https://img.shields.io/badge/Saw-Simulated-green)
![Build Status](https://img.shields.io/badge/Sine-Simulated-green)


## Testbench

The test bench is written in UVM and use the APB3 agent located in the **vip** directory.
There will be no scoreboard written as far of as today, instead the waveforms will be verified by eye.

## Synthesis

Out of context synthesis for a "7z020clg484-1" FPGA yields the following

```
parameter int SYS_CLK_FREQUENCY_P  = 200000000
parameter int PRIME_FREQUENCY_P    = 1000000
parameter int WAVE_WIDTH_P         = 24
parameter int DUTY_CYCLE_DIVIDER_P = 1000
parameter int N_BITS_P             = 32
parameter int Q_BITS_P             = 22
parameter int AXI_DATA_WIDTH_P     = 32
parameter int AXI_ID_WIDTH_P       = 4
parameter int AXI_ID_P             = 0
parameter int APB_BASE_ADDR_P      = 0
parameter int APB_ADDR_WIDTH_P     = 32
parameter int APB_DATA_WIDTH_P     = 32

+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs*             |  687 |     0 |     53200 |  1.29 |
|   LUT as Logic          |  687 |     0 |     53200 |  1.29 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |  609 |     0 |    106400 |  0.57 |
|   Register as Flip Flop |  609 |     0 |    106400 |  0.57 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |    0 |     0 |     26600 |  0.00 |
| F8 Muxes                |    0 |     0 |     13300 |  0.00 |
+-------------------------+------+-------+-----------+-------+

+----------------+------+-------+-----------+-------+
|    Site Type   | Used | Fixed | Available | Util% |
+----------------+------+-------+-----------+-------+
| DSPs           |   10 |     0 |       220 |  4.55 |
|   DSP48E1 only |   10 |       |           |       |
+----------------+------+-------+-----------+-------+
```
