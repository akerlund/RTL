# Mechanics RTL

RTL modules for mechanical inputs.

## Button Core

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA  Status](https://img.shields.io/badge/fpga-verified-green)

A module for mechanical buttons with an adjustable debounce time (in clock periods)
and configuration for both normally open or closed buttons.

```verilog
button_core #(
  .NR_OF_DEBOUNCE_CLKS_P ( NR_OF_DEBOUNCE_CLKS_C ), // Clock counter's max value before asserting "button_press_toggle"
  .CONNECTION_TYPE_P     ( CONNECTION_TYPE_C     )  // "OPEN" or "CLOSED"
) button_core_i0 (
  .clk                   ( clk                   ), // input
  .rst_n                 ( rst_n                 ), // input
  .button_in_pin         ( btn_0                 ), // input
  .button_press_toggle   ( btn_0_tgl             )  // output
);
```

## Rotary Encoder

![Synth Status](https://img.shields.io/badge/synthesis-N/A-green)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-green)

## Switch Core

![Synth Status](https://img.shields.io/badge/synthesis-N/A-green)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-green)
