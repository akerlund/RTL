# Multiplication with Fixed Point

![Test Status](https://img.shields.io/badge/test-passes-green)
![Synth Status](https://img.shields.io/badge/synthesis-passes-green)
![FPGA Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

## Table of Contents

- [Overview](#overview)
- [Parameters and Ports](#parameters-and-ports)
- [Simulation / Verification](#simulation--verification)
- [Synthesis](#synthesis)
- [License](#license)

## Overview

A parameterizable fixed-point multiplier in N.Q format (N total bits, Q fractional bits). Both a bare-core module (`nq_multiplier`) and an AXI4-Stream wrapper (`nq_multiplier_axi4s_if`) are provided. A DSP48-mapped variant (`dsp48_nq_multiplier`) is also included for Xilinx targets.

The AXI4-S interface expects two consecutive transfers per multiply: the first `tdata` word is the multiplicand and the second is the multiplier. The result is returned on the egress port; `tuser` signals arithmetic overflow.
The wrapper is fixed-latency AXI4-Stream style: it has ingress `tready`, but no egress `tready` backpressure.

FuseSoC core name: `akerlund::multiplication:0`

## Parameters and Ports

```verilog
module nq_multiplier_axi4s_if #(
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int N_BITS_P         = -1,
    parameter int Q_BITS_P         = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // AXI4-S master side
    input  wire                           ing_tvalid,
    output logic                          ing_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] ing_tdata,
    input  wire                           ing_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] ing_tid,

    // AXI4-S slave side
    output logic                          egr_tvalid,
    output logic [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
    output logic                          egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] egr_tid,
    output logic                          egr_tuser
 );
```

with an AXI4-S interface

```verilog
module nq_multiplier_axi4s_if #(
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int N_BITS_P         = -1,
    parameter int Q_BITS_P         = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // AXI4-S master side
    input  wire                           ing_tvalid,
    output logic                          ing_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] ing_tdata,
    input  wire                           ing_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] ing_tid,

    // AXI4-S slave side
    output logic                          egr_tvalid,
    output logic [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
    output logic                          egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] egr_tid,
    output logic                          egr_tuser
 );
```

and an UVM test bench with these tests:

- tc_positive_multiplications
- tc_random_multiplications

## Simulation / Verification

The legacy UVM test bench lives under `sv/` and the cocotb port lives under `py/`.
The cocotb tests drive the two-beat AXI4-Stream request protocol and compare the
registered product/overflow response against a Python N.Q fixed-point multiplication
reference model, including signed corner cases and overflow clearing.

```bash
refuse vcs && refuse simv --all
refuse cocotb -t tc_corner_multiplications
refuse cocotb -t tc_positive_multiplications
refuse cocotb -t tc_random_multiplications
```

## Performed Tests

The Scoreboard allows an error margin of

```verilog
real max_difference = 1.0/(Q_BITS_C+1);
```

## Future Work

 - Test overflow more

## Synthesis

Out of context synthesis for a "7z020clg484-1" FPGA yields the following


```
parameter int AXI_DATA_WIDTH_P = 32
parameter int AXI_ID_WIDTH_P   = 1
parameter int N_BITS_P         = 32
parameter int Q_BITS_P         = 15

+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs*             |  126 |     0 |     53200 |  0.24 |
|   LUT as Logic          |  126 |     0 |     53200 |  0.24 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |  267 |     0 |    106400 |  0.25 |
|   Register as Flip Flop |  235 |     0 |    106400 |  0.22 |
|   Register as Latch     |   32 |     0 |    106400 |  0.03 |
| F7 Muxes                |    4 |     0 |     26600 |  0.02 |
| F8 Muxes                |    2 |     0 |     13300 |  0.02 |
+-------------------------+------+-------+-----------+-------+
```

## License

Copyright (C) 2020 Fredrik Åkerlund — released under the GNU General Public License v3 or later. See [LICENSE](../../../LICENSE).
