# AXI4 Read Channel Arbiter

![Build Status](https://img.shields.io/badge/build-passing-green)
![Build Status](https://img.shields.io/badge/test-passing-green)
![Build Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![Build Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

Arbiter with parameterized number of AXI4 Masters (NR_OF_MASTERS_P) which connects to one AXI4 Slave.
The read address channel and the read data channel are separated in the arbiter.
The arbiter routes requests and responses using the ARID and RID.
