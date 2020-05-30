# IIR Bi-Quad Filter

![Test  Status](https://img.shields.io/badge/test-N/A-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

This IIR filter's test case *tc_iir_reconfiguration* will give this waveform

![sim](https://github.com/akerlund/rtl_common_design/blob/master/.pictures/dsp/bq_filter_sim.JPG)

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
