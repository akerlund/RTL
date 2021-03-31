# AXI4-S Synchronous FIFO

![Test  Status](https://img.shields.io/badge/test-passing-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Synchronous FIFO, i.e., one clock domain, with parameters for the data width (tuser) and FIFO depth, i.e., address width. Tested in an UVM test bench with back pressure on the egress side. It is intended to concatenate all ingress data into the **tuser** vector.

## Simulation Waveform

![Figure 1](https://github.com/akerlund/rtl_common_design/blob/master/.pictures/fifo/axi_fifo.JPG)

## Instantiation

```verilog

  // Concatenation example
  assign ing_tuser = {ing_tlast, ing_tdata};
  assign {egr_tlast, egr_tdata} = egr_tuser;

  axi4s_sync_fifo #(
    .TUSER_WIDTH_P        ( FIFO_USER_WIDTH_C    ),
    .ADDRESS_WIDTH_P      ( FIFO_ADDR_WIDTH_C    )
  ) axi4s_sync_fifo_i0 (
    .clk                  ( clk                  ), // input
    .rst_n                ( rst_n                ), // input
    .ing_tready           ( tready               ), // output
    .ing_tuser            ( ing_tuser            ), // input
    .ing_tvalid           ( tvalid               ), // input
    .egr_tready           ( tready               ), // input
    .egr_tuser            ( egr_tuser            ), // output
    .egr_tvalid           ( tvalid               ), // output
    .sr_fill_level        ( sr_fill_level        ), // output
    .sr_max_fill_level    ( sr_max_fill_level    ), // output
    .cr_almost_full_level ( cr_almost_full_level )  // input
  );
```
