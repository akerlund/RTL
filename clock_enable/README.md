# Enable modules

## Clock Enable

![Build Status](https://img.shields.io/badge/build-N/A-lightgrey)
![Test  Status](https://img.shields.io/badge/test-N/A-lightgrey)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Given the parameters **CLK_FREQUENCY_P** and **ENA_FREQUENCY_P**, the output port *enable* will be asserted one clock cycle per enable frequency.

## Delay Enable

![Build Status](https://img.shields.io/badge/build-N/A-lightgrey)
![Test  Status](https://img.shields.io/badge/test-N/A-lightgrey)
![Synth Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Given the parameters **CLK_PERIOD_P** and **DELAY_NS_P**, the output port *delay_out* will be asserted after some nano seconds after **start** has been asserted.
