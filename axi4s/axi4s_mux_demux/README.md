# AXI4S
This is work in progress

## Preliminary Synthesis Results

Synthesized *axi4s_mux_rr_demux* with the following paramters

```systemverilog
    parameter int nr_of_streams_p = 4,
    parameter int tdata_width_p   = 3,
```

Vivado report_utilization:

### axi4s_mux_rr
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

### axi4s_demux
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