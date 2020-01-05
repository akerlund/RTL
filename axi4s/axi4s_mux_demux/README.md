# AXI4S Multiplexer and De-multiplexer

This folder contains one round robin AXI4-S multiplexer **(axi4s_mux_rr.sv)**\
and one de-multiplexer **(axi4s_demux.sv)**.

Another block (**axi4s_mux_rr_demux.sv**) contains one instance of each.


## axi4s_mux_rr
The multiplexer has no **tid** signal to the master side but have one to the slave\
and the value is determined from the round robin counter, i.e., in what order\
the master is connected to the multiplexer.

### Vivado report_utilization
Preliminary numbers as this is done before validation has been completed.\
Synthesized with the following parameters:

```systemverilog
  parameter int nr_of_streams_p = 4
  parameter int tdata_width_p   = 3
```
```
+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs*             |   32 |     0 |     53200 |  0.06 |
|   LUT as Logic          |   32 |     0 |     53200 |  0.06 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |   35 |     0 |    106400 |  0.03 |
|   Register as Flip Flop |   35 |     0 |    106400 |  0.03 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |    0 |     0 |     26600 |  0.00 |
| F8 Muxes                |    0 |     0 |     13300 |  0.00 |
+-------------------------+------+-------+-----------+-------+
```

## axi4s_demux
The de-multiplexer has no **tid** signal to the slave side but have one to the master which is used to terminate the AXI4S connection to either connected slave interface.

### Vivado report_utilization
Preliminary numbers  as this is done before validation has been completed.\
Synthesized with the following parameters:

```systemverilog
  parameter int nr_of_streams_p = 4
  parameter int tdata_width_p   = 3
```
```
+-------------------------+------+-------+-----------+-------+
|        Site Type        | Used | Fixed | Available | Util% |
+-------------------------+------+-------+-----------+-------+
| Slice LUTs*             |   24 |     0 |     53200 |  0.05 |
|   LUT as Logic          |   24 |     0 |     53200 |  0.05 |
|   LUT as Memory         |    0 |     0 |     17400 |  0.00 |
| Slice Registers         |  105 |     0 |    106400 |  0.10 |
|   Register as Flip Flop |  105 |     0 |    106400 |  0.10 |
|   Register as Latch     |    0 |     0 |    106400 |  0.00 |
| F7 Muxes                |    0 |     0 |     26600 |  0.00 |
| F8 Muxes                |    0 |     0 |     13300 |  0.00 |
+-------------------------+------+-------+-----------+-------+
```