# Synchronizers

## IO
### io_synchronizer

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA  Status](https://img.shields.io/badge/fpga-verified-green)

Synchronizes an input signal from an I/O pin to the system clock, i.e., meta-stabilizing the signal.

```tcl
# Constraint all 'io_synchronizer_core_i0'
set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*io_synchronizer_core_i0/bit_egress.*]
````

## Reset
### reset_synchronizer

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA  Status](https://img.shields.io/badge/fpga-verified-green)

Synchronizes an asynchronous reset signal to a clock, essentially an **io_synchronizer** with a naming convention that allows for easy TCL constraints:

```tcl
# Constraint all 'reset_synchronizer_core_i0'
set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*reset_synchronizer_core_i0/reset_origin_n.*]
set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*io_synchronizer_core_i0/bit_egress.*]
````


## CDC
### cdc_bit_sync

![Synth Status](https://img.shields.io/badge/synthesis-N/A-orange)
![FPGA  Status](https://img.shields.io/badge/fpga-N/A-orange)

Synchronizes an signal from another clock domain to the system clock, i.e., meta-stabilizing the signal.