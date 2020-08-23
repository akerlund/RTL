# Synchronous FIFO

![Test  Status](https://img.shields.io/badge/test-passing-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Syncronous FIFO, i.e., one clock domain, with parameters for the data width and FIFO depth, i.e., address width. Tested in the AXI4-S wrapper, as a submodule of the AXI4-S interface.

## Simulation Waveform

![Figure 1](https://github.com/akerlund/rtl_common_design/blob/master/.pictures/fifo/reg_fifo.JPG)

## Instantiation

```verilog
synchronous_fifo #(
  .DATA_WIDTH_P         ( DATA_WIDTH_P         ),
  .ADDRESS_WIDTH_P      ( ADDRESS_WIDTH_P      )
) synchronous_fifo_i0 (
  .clk                  ( clk                  ), // input
  .rst_n                ( rst_n                ), // input
  .ing_enable           ( ing_transaction      ), // input
  .ing_data             ( ing_tuser            ), // input
  .ing_full             ( wp_fifo_full         ), // output
  .ing_almost_full      (                      ), // output
  .egr_enable           ( egr_transaction      ), // input
  .egr_data             ( egr_tuser            ), // output
  .egr_empty            ( rp_fifo_empty        ), // output
  .sr_fill_level        ( sr_fill_level        ), // output
  .sr_max_fill_level    ( sr_max_fill_level    ), // output
  .cr_almost_full_level ( cr_almost_full_level )  // input
);
```
