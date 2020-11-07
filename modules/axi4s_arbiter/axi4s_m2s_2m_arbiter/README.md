# AXI4-S Arbiter | Master to Slave | 2 Masters

![Build Status](https://img.shields.io/badge/build-passing-green)
![Build Status](https://img.shields.io/badge/test-passing-green)
![Build Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![Build Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Arbiter which lets two AXI4-S Masters connect to one AXI4-S slave.

## Testbench

The testbench is written in UVM and use the AXI4-S agents located in the **vip** directory.

### tc_arb_simple_test

Stimulates the DUT with 10 AXI4-S transaction per each Master, i.e., 20 in total

## Vivado 2019.2 Synthesis

