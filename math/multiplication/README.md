# Multiplication with Fixed Point

![Test  Status](https://img.shields.io/badge/test-passes-green)
![Synth Status](https://img.shields.io/badge/synthesis-passes-green)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Parameterizable fixed-point multiplier

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