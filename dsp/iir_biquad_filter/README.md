# IIR Bi-Quad Filter

![Build Status](https://img.shields.io/badge/build-N/A-lightgrey)
![Test  Status](https://img.shields.io/badge/test-N/A-lightgrey)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

## Implementation

Probably need 16 bits to cover all desired cut-off frequencies.

```python
>>> 2**16-1
65535
```


# Theory

Digital bi-quad filter, containing two poles and two zeros. "Biquad" is an abbreviation of "biquadratic", which refers to the fact that in the Z domain, its transfer function is the ratio of two quadratic functions:

```
       b0 + b1 * z^-1 + b2 * z^-2
H(z) = --------------------------
       a0 + a1 * z^-1 + a2 * z^-2
```

Normalized output (a0 = 0) for a second order IIR filter in Direct-Form I:

```
y[n] = b0*x[n] + b1*x[n-1] + b2*[x-2] - a1*y[n-1] - a2*y[n-2]
```

The b coefficients determine zeros and the a coefficients determine the
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

a1 = -2cos(w0)

a2 = 1 - alfa
```

### High-Pass Filter

```
b0 = (1 + cos(w0)) / 2

b1 = -(1 + cos(w0))

b2 = (1 + cos(w0)) / 2

a0 = 1 + alfa

a1 = -2cos(w0)

a2 = 1 - alfa
```

### Band-Pass Filter

```
b0 = sin(w0) / 2

b1 = 0

b2 = -sin(w0) / 2

a0 = 1 + alfa

a1 = -2cos(w0)

a2 = 1 - alfa
```




