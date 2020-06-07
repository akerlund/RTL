# Oscillator

![Build Status](https://img.shields.io/badge/test-pass-green)
![Build Status](https://img.shields.io/badge/synthesis-pass-green)
![Build Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

And oscillator module which will have the following waveforms:

- Square
- Triangle
- Saw
- Sine

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

