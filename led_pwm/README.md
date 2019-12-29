# RLT
Working on a module that can control RGB LEDs.
The goal is no use HSL setting for color, i.e.,
Hue, Saturation and Light which shall be converted into
RGB values for the timers that generates the PWM waveforms.

## Scripts
Contains a Python script which converts HSL into RGB.
It was used to hardcode values into the test bench.

## Testbench
Just runs three different HSL values and compares the output with
values generated from the Python script.

## Synthesis
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
