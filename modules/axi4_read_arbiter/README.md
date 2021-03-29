# AXI4 Read Channel Arbiter

![Build Status](https://img.shields.io/badge/BUILD-PASSING-green)
![Build Status](https://img.shields.io/badge/TEST-PASSING-green)
![Build Status](https://img.shields.io/badge/SYNTHESIS-PASSING-green)
![Build Status](https://img.shields.io/badge/FPGA-PASSING-green)

Instantiate this arbiter and either one of the two submodules will be created:

If one Master (NR_OF_MASTERS_P == 1):

## axi4_read_arbiter_mst_2_slvs

This arbiter uses the value of "arregion" to decide which slave is requested
by a master and thus this module supports up to 16 connections.

## axi4_read_arbiter_msts_2_slv

If one Slave (NR_OF_SLAVES_P == 1):

With the value of a counter labeled "read_rotating_mst" this arbiter checks
the corresponding "mst_arvalid" port and allows a connection if the port is
found high. The connection is closed when the handshake on the Read Data
Channel is detected with "rlast" and the counter will continue to
increase until the next asserted "mst_arvalid" is found.