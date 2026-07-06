# Linear Feedback Shift Register

![Test Status](https://img.shields.io/badge/test-N/A-lightgrey)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

## Table of Contents

- [Overview](#overview)
- [Parameters and Ports](#parameters-and-ports)
- [Tap Mask Reference](#tap-mask-reference)
- [How an LFSR Works](#how-an-lfsr-works)
- [License](#license)

## Overview

A parameterized Fibonacci LFSR (Linear Feedback Shift Register) in SystemVerilog. The register width, tap polynomial mask, and reset seed are all configurable via parameters. The default configuration is a maximal-length 32-bit LFSR with polynomial $x^{32} + x^7 + x^5 + x^3 + x^2 + x + 1$.

FuseSoC core name: `akerlund::lfsr:0`

## Parameters and Ports

```verilog
module lfsr #(
    parameter int                   WIDTH_P = 32,
    parameter logic [WIDTH_P-1 : 0] TAPS_P  = 32'h8000_0057,
    parameter logic [WIDTH_P-1 : 0] SEED_P  = 32'h0000_0001
  )(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   advance,
    input  wire                   cmd_load_seed,
    input  wire  [WIDTH_P-1 : 0]  cr_seed,
    output logic [WIDTH_P-1 : 0]  value,
    output logic                  bit_out
  );
```

`TAPS_P` defines which state bits are XORed to generate the feedback bit. In
this module's convention, bit `n-1` in `TAPS_P` corresponds to the `x^n` term in
the polynomial, while the `+ 1` term is implicit in the XOR feedback path.

## Tap Mask Reference

Suggested maximal-length polynomials and masks:

| Width | `TAPS_P`     | Polynomial |
| --- | --- | --- |
| 8  | `8'hB8`       | `x^8 + x^6 + x^5 + x^4 + 1` |
| 16 | `16'hB400`    | `x^16 + x^14 + x^13 + x^11 + 1` |
| 24 | `24'hE1_0000` | `x^24 + x^23 + x^22 + x^17 + 1` |
| 32 | `32'h8000_0057` | `x^32 + x^7 + x^5 + x^3 + x^2 + x^1 + 1` |
| 48 | `48'h8000_0000_005B` | `x^48 + x^7 + x^5 + x^4 + x^2 + x^1 + 1` |
| 64 | `64'h8000_0000_0000_000D` | `x^64 + x^4 + x^3 + x^1 + 1` |

These are good default choices when you want a maximal-length sequence for the
given register width.

`value` is the current LFSR register contents. `bit_out` is the bit shifted out
on the current cycle, which is useful when the LFSR is used as a serial
pseudo-random bit source rather than only as a parallel state generator.
The shift direction is toward the MSB: `next_state = {value[WIDTH_P-2:0],
feedback}` and `bit_out` is the pre-shift MSB. If either `SEED_P` or a runtime
`cr_seed` is zero, the module substitutes a valid nonzero seed so the LFSR does
not lock in the all-zero state. The default 32-bit tap mask is intended for
`WIDTH_P == 32`; choose an explicit tap mask from the table, or another known
primitive polynomial, for other widths.

## How an LFSR works

An LFSR is not truly random. It is a deterministic state machine that shifts its
register and computes one new feedback bit from a small XOR network. The output
looks random enough for many hardware tasks because the bit pattern has good
statistical spread, changes every cycle, and is cheap to generate in logic.

An LFSR is always cyclic. After some number of steps it returns to an earlier
state and then repeats the same sequence again. If the tap polynomial is
primitive and the seed is non-zero, the LFSR is maximal-length and visits every
non-zero state exactly once before repeating. That gives a period of
`2^WIDTH_P - 1` cycles. The all-zero state is special because it feeds back to
itself, so it is normally avoided as a seed.

Here, primitive means the feedback polynomial generates the longest possible
cycle for that register width. In practice, that means a primitive polynomial
does not fall into a shorter repeating subset of states. Instead, it walks
through all possible non-zero states before returning to the starting point.
The polynomials listed above for 8, 16, 24, 32, 48, and 64 bits are suggested
because they are primitive choices for those widths, so they give the maximal
period when used with a non-zero seed.

Wider registers are better when you want a longer repeat period or a larger set
of pseudo-random states. For example, an 8-bit maximal LFSR repeats after 255
cycles, while a 16-bit one repeats after 65,535 cycles, and a 32-bit one after
4,294,967,295 cycles. Wider LFSRs do not make the sequence more truly random,
but they do make repetition much less frequent and usually improve usefulness in
test pattern generation, scrambling, counters, and simple noise-like sources.

## License

Copyright (C) 2021 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../../LICENSE).
