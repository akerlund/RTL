# Color HSL 12-bit

This module takes HSL color values, i.e.,Hue, Saturation and Light and outputs
the corresponding RGB values which can be used by timers that generates 
PWM waveforms for RGB LEDs.

## Scripts
Contains a Python script which converts HSL into RGB.
It was used to hardcode values into the test bench.

## Testbench
Just runs three different HSL values and compares the output with
values generated from the Python script.

## Vivado 2019.2 Synthesis
These are the results after an out of context synthesis in Vivado.
The FPGA used is 7z020clg484-1.

```
+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs*             | 2156 |     0 |     53200 |  4.05 |
|   LUT as Logic          | 2156 |     0 |     53200 |  4.05 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |  259 |     0 |    106400 |  0.24 |
|   Register as Flip Flop |  259 |     0 |    106400 |  0.24 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |  648 |     0 |     26600 |  2.44 |
| F8 Muxes                |  309 |     0 |     13300 |  2.32 |
| DSP48E1                 |    5 |     0 |       220 |  2.27 |
+-------------------------+------+-------+-----------+-------+
```
