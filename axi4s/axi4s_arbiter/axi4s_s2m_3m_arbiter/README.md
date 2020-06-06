# AXI4-S Arbiter | Slave to Master | 2 Masters

![Build Status](https://img.shields.io/badge/test-passing-green)
![Build Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![Build Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Arbiter which lets one AXI4-S slave connect to two AXI4-S Masters.
The **tid** is used to route.


## Testbench

The testbench is written in UVM and use the AXI4-S agents located in the **vip** directory.

### tc_arb_simple_test

The AXI4-S slave agent sends random transactions.
