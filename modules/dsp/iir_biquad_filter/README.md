# IIR Bi-Quad Filter

![Test Status](https://img.shields.io/badge/test-passes-green)
![Synth Status](https://img.shields.io/badge/synthesis-passes-green)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

## Table of Contents

- [Overview](#overview)
- [Implementation](#implementation)
- [Synthesis](#synthesis)
- [Theory](#theory)
- [License](#license)

## Overview

A second-order IIR biquad filter in Direct-Form I with AXI4 register control. Filter coefficients (b0, b1, b2, a1, a2) are calculated on-chip from the cut-off frequency and Q-factor using the CORDIC and long-division peripherals, so the filter can be reconfigured at runtime by writing new values to the control registers.

Fixed-point N.Q arithmetic is used throughout. N32Q11 is recommended as a minimum; N32Q7 was found to give insufficient accuracy for the ω₀ and α calculations.

FuseSoC core name: `akerlund::iir_biquad_filter:0`

**Parameters**

| Parameter | Default | Description |
|---|---|---|
| `AXI_DATA_WIDTH_P` | 32 | AXI4-S data width for CORDIC and divider interfaces |
| `AXI_ID_WIDTH_P` | 4 | AXI4-S ID width |
| `AXI4S_ID_P` | — | ID value used on external AXI4-S interfaces |
| `N_BITS_P` | 32 | Fixed-point total bits |
| `Q_BITS_P` | 11 | Fixed-point fractional bits |

## Simulation / Verification

The legacy SystemVerilog/UVM testbench lives under `sv/`. A cocotb testbench lives
under `py/`; it drives a small Python register model onto the plain configuration
inputs, checks coefficient/status updates, and verifies the bypass output path with
a signed sample.

Run the flows from this module directory:

```sh
bash /home/shared/github/RTL/scripts/refuse.sh vcs
bash /home/shared/github/RTL/scripts/refuse.sh simv --all
bash /home/shared/github/RTL/scripts/refuse.sh cocotb -t tc_iir_basic_configuration
bash /home/shared/github/RTL/scripts/refuse.sh cocotb -t tc_iir_coefficient_check
bash /home/shared/github/RTL/scripts/refuse.sh cocotb -t tc_iir_reconfiguration
```


The input is a triangle wave with a frequency of **1kHz** and the cut-off frequency starts at **3kHz** and is decreased with steps of **200Hz**. Every time the cut-off frequency is changed the IIR top module's state machine will use the CORDIC and the long divider to calculate the new coefficients for the filter and then also normalize them to unity gain by dividing them all with **a0**. This particular simulation is using N32Q11 fixed point. It was found that N32Q7 provided insufficient accuracy of the calculating of w0 and alfa.


# Implementation

The system (*iir_dut_biquad_system*) is used for testing and contains:

```
- iir_biquad_top         // IIR filter
- iir_biquad_apb_slave   // IIR registers
- frequency_enable       // Makes the IIR sample its input
- cordic_axi4s_if        // Sine/Cosine for the IIR
- long_division_axi4s_if // Division for the IIR
- oscillator_top         // Input signal for the IIR, a triangle wave
```

## Synthesis

Out of context synthesis for a "7z020clg484-1" FPGA yields the following

```
parameter int AXI_DATA_WIDTH_P = 32
parameter int AXI_ID_WIDTH_P   = 2
parameter int AXI4S_ID_P       = 0
parameter int APB_DATA_WIDTH_P = 32
parameter int N_BITS_P         = 32
parameter int Q_BITS_P         = 11

+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs*             |  814 |     0 |     53200 |  1.53 |
|   LUT as Logic          |  814 |     0 |     53200 |  1.53 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |  647 |     0 |    106400 |  0.61 |
|   Register as Flip Flop |  647 |     0 |    106400 |  0.61 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |   32 |     0 |     26600 |  0.12 |
| F8 Muxes                |    0 |     0 |     13300 |  0.00 |
+-------------------------+------+-------+-----------+-------+

+----------------+------+-------+-----------+-------+
|    Site Type   | Used | Fixed | Available | Util% |
+----------------+------+-------+-----------+-------+
| DSPs           |    5 |     0 |       220 |  2.27 |
|   DSP48E1 only |    5 |       |           |       |
+----------------+------+-------+-----------+-------+
```

# Theory

Digital bi-quad filter, containing two poles and two zeros [1]. "Bi-Quad" is an abbreviation of "biquadratic", which refers to the fact that in the Z domain, its transfer function is the ratio of two quadratic functions:

```
       b0 + b1 * z^-1 + b2 * z^-2
H(z) = --------------------------
       a0 + a1 * z^-1 + a2 * z^-2
```

Normalized output (a0 = 0) for a second order IIR filter in Direct-Form I:

```
y[n] = b0*x[n] + b1*x[n-1] + b2*[x-2] - a1*y[n-1] - a2*y[n-2]
```

The **b** coefficients determine zeros and the **a** coefficients determine the
position of the poles.

## Direct-Form I

```
H(z) = (b0 + b1 * z^-1 + b2 * z^-2) / (a1 * z^-1 + a2 * z^-2)

w0   = 2 * pi * f0 /Fs

alfa = sin(w0) / 2Q
```

### Low-Pass Filter

```
b0 = (1 - cos(w0)) / 2

b1 = 1 - cos(w0)

b2 = (1 - cos(w0)) / 2

a0 = 1 + alfa

a1 = -2*cos(w0)

a2 = 1 - alfa
```

### High-Pass Filter

```
b0 = (1 + cos(w0)) / 2

b1 = -(1 + cos(w0))

b2 = (1 + cos(w0)) / 2

a0 = 1 + alfa

a1 = -2*cos(w0)

a2 = 1 - alfa
```

### Band-Pass Filter

```
b0 = sin(w0) / 2 = Q * alfa

b1 = 0

b2 = -sin(w0) / 2 = -Q * alfa

a0 = 1 + alfa

a1 = -2*cos(w0)

a2 = 1 - alfa
```


# References

[1] https://www.w3.org/2011/audio/audio-eq-cookbook.html

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../../LICENSE).
