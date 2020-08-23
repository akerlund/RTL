# Enable modules

## Frequency Enable

![Test  Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

The Frequency Enable module will assert its **enable** port with the period of a provided frequency to its configuration register **cr_enable_frequency**. A divider module is therefore needed which is connected through the AXI4-S interface. When a new frequency is detected the module will use the divider and calculate the new counter value needed to produce the correct period on the **enable** port.

### Instantiation Template

```verilog
// Used as a dividend to calculate the timer
localparam int SYS_CLK_FREQUENCY_C = 100000000;
// Data width to the divider (or an arbiter between them)
localparam int AXI_DATA_WIDTH_C    = 32;
// Depends on how many connections there are to an arbiter
localparam int AXI_ID_WIDTH_C      = 2;
// The divider is fixed point and the number of Q-bits is need for correct conversions
localparam int Q_BITS_C            = 4;
// Unique ID used by an arbiter
localparam int AXI4S_ID_C          = 1;

// Desired frequency out is a normal integer, e.g., 20MHz
localparam logic [$clog2(SYS_CLK_FREQUENCY_C)-1 : 0] cr_enable_frequency = 20000000;

frequency_enable #(
  .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_C ),
  .AXI_DATA_WIDTH_P    ( AXI_DATA_WIDTH_C    ),
  .AXI_ID_WIDTH_P      ( AXI_ID_WIDTH_C      ),
  .Q_BITS_P            ( Q_BITS_C            ),
  .AXI4S_ID_P          ( AXI4S_ID_C          )
) frequency_enable_i0 (
  .clk                 ( clk                 ),
  .rst_n               ( rst_n               ),
  .enable              ( enable              ),
  .cr_enable_frequency ( cr_enable_frequency ),
  .div_egr_tvalid      ( div_egr_tvalid      ),
  .div_egr_tready      ( div_egr_tready      ),
  .div_egr_tdata       ( div_egr_tdata       ),
  .div_egr_tlast       ( div_egr_tlast       ),
  .div_egr_tid         ( div_egr_tid         ),
  .div_ing_tvalid      ( div_ing_tvalid      ),
  .div_ing_tready      ( div_ing_tready      ),
  .div_ing_tdata       ( div_ing_tdata       ),
  .div_ing_tlast       ( div_ing_tlast       ),
  .div_ing_tid         ( div_ing_tid         ),
  .div_ing_tuser       ( div_ing_tuser       )
);
```

### Verification

The module has merely been verified by eye to see that the desired period out (on the **enable** port) was correct. The simple test bench in **tb_clock_enable** was used. A resulting waveform is shown in Figure 1 below. The first desired frequency is **10Mhz** and is changed to **20Mhz** some time into the simulation. One can verify that the period of the *enable* port is indeed **100ns** at first configuration and then changes to **50ns**.

![Figure 1](https://github.com/akerlund/rtl_common_design/blob/master/.pictures/clock_enable/frequency_enable_simulation.JPG)

*Figure 1. Waveforms from a simulation of the Frequency Enable module.*

## Clock Enable

![Test  Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)


## Delay Enable

![Test  Status](https://img.shields.io/badge/testbench-pass-green)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

