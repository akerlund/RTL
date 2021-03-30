# AXI4 Write Channel Arbiter

![Build Status](https://img.shields.io/badge/BUILD-PASSING-green)
![Build Status](https://img.shields.io/badge/TEST-PASSING-green)
![Build Status](https://img.shields.io/badge/SYNTHESIS-PASSING-green)
![Build Status](https://img.shields.io/badge/FPGA-PASSING-green)

If the parameter "NR_OF_MASTERS_P" is equal to one then an
"axi4_write_arbiter_mst_2_slvs" will be instantiated, i.e., one master
connected to (NR_OF_SLAVES_P) slaves.

If the parameter "NR_OF_MASTERS_P" is NOT equal to one then a
"axi4_write_arbiter_msts_2_slv" will be instantiated, i.e.,
(NR_OF_MASTERS_P) masters is connected to one slave.
