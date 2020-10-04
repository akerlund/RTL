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

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA  Status](https://img.shields.io/badge/fpga-verified-green)

Synchronizes a single bit between two clock domains, i.e., meta-stabilizing the signal.

### cdc_vector_sync

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA  Status](https://img.shields.io/badge/fpga-verified-green)

Synchronizes a vector between two clock domains, i.e., meta-stabilizing the vector. Two 'cdc_bit_sync' are used to pass a valid signal from the Source to Destination clock domain and an acknowledge signal from the Destination to Source clock domain. Another pair of 'cdc_bit_sync' are used to synchronize the clock domains reset signals between.