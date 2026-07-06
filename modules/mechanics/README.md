# Mechanics RTL

RTL modules for mechanical inputs.

## Table of Contents

- [Overview](#overview)
- [button\_core](#button_core)
- [rotary\_encoder](#rotary_encoder)
- [switch\_core](#switch_core)
- [License](#license)

## Overview

A collection of synchronizer-debounced drivers for common mechanical I/O: push buttons, rotary encoders, and toggle switches. All modules route their physical pin inputs through `io_synchronizer` before debouncing or decoding, making them safe to use in any clock domain.

---

## button_core

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA Status](https://img.shields.io/badge/fpga-verified-green)

FuseSoC core: `akerlund::button:0`

Debounces a mechanical push button and outputs a one-clock pulse per stable
press. The pin is first synchronized via `io_synchronizer`, then held for
`NR_OF_DEBOUNCE_CLKS_P` clock cycles before `button_press_toggle` is asserted.
Release is debounced with the same counter before another press can be accepted.
Both normally-open and normally-closed wiring configurations are supported.

**Parameters**

| Parameter | Description |
|---|---|
| `NR_OF_DEBOUNCE_CLKS_P` | Number of stable clock cycles required to register a press |
| `CONNECTION_TYPE_P` | `"OPEN"` (active-high pin) or `"CLOSED"` (active-low pin) |

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low reset |
| `button_in_pin` | input | Raw pin from FPGA I/O |
| `button_press_toggle` | output | One-clock pulse on each debounced press |

**Instantiation example**

```systemverilog
button_core #(
  .NR_OF_DEBOUNCE_CLKS_P ( 1_000_000 ), // 10 ms @ 100 MHz
  .CONNECTION_TYPE_P     ( "OPEN"    )
) u_btn (
  .clk                 ( clk        ),
  .rst_n               ( rst_n      ),
  .button_in_pin       ( btn_pin    ),
  .button_press_toggle ( btn_toggle )
);
```

---

## rotary_encoder

![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

FuseSoC core: `akerlund::encoder:0`

Decodes a quadrature rotary encoder. Both `encoder_pin_a` and `encoder_pin_b` are synchronized via `io_synchronizer`, then fed into an FSM (`rotary_encoder_fsm`) that detects transitions and determines direction. `rotation_direction == 1` means clockwise/right in the supported wiring convention, and `0` means counter-clockwise/left. Inputs are synchronized but not debounced; add external filtering if the encoder bounces enough to produce invalid intermediate states.

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low reset |
| `encoder_pin_a` | input | Encoder channel A (raw pin) |
| `encoder_pin_b` | input | Encoder channel B (raw pin) |
| `rotation_valid` | output | Pulse on each detected rotation step |
| `rotation_direction` | output | `1` = clockwise, `0` = counter-clockwise |

---

## switch_core

![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

FuseSoC core: `akerlund::switch:0`

Debounces a mechanical toggle switch. The pin is synchronized via `io_synchronizer` and the output only changes state after the input has been stable for `NR_OF_DEBOUNCE_CLKS_P` consecutive clock cycles.

**Parameters**

| Parameter | Description |
|---|---|
| `NR_OF_DEBOUNCE_CLKS_P` | Number of stable cycles required before updating output |

**Ports**

| Port | Direction | Description |
|---|---|---|
| `clk` | input | System clock |
| `rst_n` | input | Active-low reset |
| `switch_in_pin` | input | Raw pin from FPGA I/O |
| `switch_out` | output | Debounced switch state |

---

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../LICENSE).
