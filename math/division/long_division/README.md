# Long Division with Fixed Point

![Build Status](https://img.shields.io/badge/build-passes-green)
![Test  Status](https://img.shields.io/badge/test-passes-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Parameterizable fixed-point divider

```verilog
module long_division_core #(
    parameter int N_BITS_P = -1,
    parameter int Q_BITS_P = -1
  )(
    input  wire                          clk,
    input  wire                          rst_n,

    input  wire                          ing_valid,
    output logic                         ing_ready,
    input  wire  signed [N_BITS_P-1 : 0] ing_dividend,
    input  wire  signed [N_BITS_P-1 : 0] ing_divisor,

    output logic                         egr_valid,
    output logic signed [N_BITS_P-1 : 0] egr_quotient,
    output logic signed [N_BITS_P-1 : 0] egr_remainder,
    output logic                         egr_overflow
  );
```

with an AXI4-S interface

```verilog
module long_division_axi4s_if #(
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
    output logic [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,  // Quotient
    output logic                          egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] egr_tid,
    output logic                          egr_tuser   // Overflow
 );
```

and an UVM test bench with these tests:

- tc_positive_divisions
- tc_negative_divisions
- tc_random_divisions


## Performed Tests

The Scoreboard allows an error margin of

```verilog
real max_difference = 1.0/(Q_BITS_C+1);
```

when comparing its prediction to the data from the Monitor. This is because I cannot get the **float_to_fixed_point()** to do it right, as my Python version does. The Scoreboard does not test the remainder.

| NxQy   | Test name           | #divisions | Result  | #overflows |
| :-     | :-                  | -:         | :-      | -:         |
| N32Q15 | All                 | N/A        | Passing | N/A        |
| N16Q0  | tc_random_divisions | 100000     | Passing | 0          |
| N16Q1  | tc_random_divisions | 100000     | Passing | 0          |
| N16Q2  | tc_random_divisions | 100000     | Passing | 2          |
| N16Q3  | tc_random_divisions | 100000     | Passing | 6          |
| N16Q14 | tc_random_divisions | 100000     | Passing | 24830      |
| N3Q1   | tc_random_divisions | 512        | Passing | 0          |
| N24Q15 | tc_random_divisions | 100000     | Passing | 210        |

*Table 1. Tests performed with various vector widths.*

## Future Work

 - Fix the rounding issue in the Scoreboard, i.e., fixed point to real and vice versa. The Scoreboard is predicting wrong because of the conversion in the VIP package does not round the value down.
 - Scoreboard also checks the remainder.
