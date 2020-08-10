# Synchronizers

## cdc_bit_sync

![Synth Status](https://img.shields.io/badge/synthesis-passing-gray)
![FPGA  Status](https://img.shields.io/badge/fpga-passing-gray)

Synchronizes an signal from another clock domain to the system clock, i.e., meta-stabilizing the signal.


## io_synchronizer

![Synth Status](https://img.shields.io/badge/synthesis-passing-green)
![FPGA  Status](https://img.shields.io/badge/fpga-verified-green)

Synchronizes an input signal from an I/O pin to the system clock, i.e., meta-stabilizing the signal.

## reset_synchronizer

![Synth Status](https://img.shields.io/badge/synthesis-passing-gray)
![FPGA  Status](https://img.shields.io/badge/fpga-verified-gray)

Essentially an **io_synchronizer** with a naming convention that allows for easy TCL scripting.
