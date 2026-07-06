# RTL

Reusable SystemVerilog RTL modules, interfaces, and verification collateral for
FPGA-oriented designs.

The repository is organized as FuseSoC cores under `modules/`. Each module is
intended to be reusable on its own, with local RTL, testbench files, and tool
targets kept beside the core description.

## Current Status

The RTL module port is complete for the modules that have historical
SystemVerilog/UVM testbenches. Those modules now use the repository-standard
split verification layout:

- `sv/` keeps the original SystemVerilog/UVM testbench and testcases.
- `py/` contains the cocotb/pyUVM port, driven through a FuseSoC `sim` target.
- `rtl/` remains the shared DUT source used by both flows.

All FuseSoC cores under `modules/` are Verilator-clean through their `rtl`
target. The ported verification modules listed below have also been verified
through both simulation flows:

- SystemVerilog/UVM with VCS: `refuse vcs` and `refuse simv --all`
- cocotb with Verilator through FuseSoC: `refuse cocotb -t <test>`

| Module | VCS/UVM compile + tests | cocotb/Verilator compile + tests |
| --- | --- | --- |
| `modules/examples` | yes | yes |
| `modules/axi4_read_arbiter` | yes | yes |
| `modules/axi4_write_arbiter` | yes | yes |
| `modules/axi4s_fifo` | yes | yes |
| `modules/axi4s_m2s_arbiter` | yes | yes |
| `modules/axi4s_s2m_arbiter` | yes | yes |
| `modules/math/cordic` | yes | yes |
| `modules/math/long_division` | yes | yes |
| `modules/math/multiplication` | yes | yes |
| `modules/mixer` | yes | yes |
| `modules/afifo` | yes | yes |
| `modules/synchronizers/cdc_vector_sync` | yes | yes |
| `modules/oscillator` | yes | yes |
| `modules/dsp/iir_biquad_filter` | yes | yes |

The remaining module cores are RTL-only or dependency cores in this repository;
they do not currently carry a legacy UVM testbench to port.

From any module directory that contains a single `.core` file:

```sh
source /home/shared/github/RTL/scripts/refuse.sh
refuse verilator
```

`refuse verilator` resolves the RTL repository roots, selects the module core,
and runs:

```sh
fusesoc --cores-root modules \
        --cores-root submodules/VIP \
        --cores-root submodules/PYRG \
        run --target rtl --tool verilator --setup --build <core>
```

Generated FuseSoC, VCS, Verilator, and cocotb work directories are ignored via
`.gitignore` (`rundir*`, `sim_build`, `results.xml`, and Python bytecode).

## Verification Helpers

Source the helper once per shell:

```sh
source /home/shared/github/RTL/scripts/refuse.sh
```

Common commands:

```sh
refuse verilator          # Build the current module's rtl target with Verilator
refuse vcs                # Build the current module's UVM target with VCS
refuse simv -t <test>     # Run one UVM test from sv/tc/
refuse simv --all         # Run all tc_*.sv tests from sv/tc/
refuse cocotb -t <test>   # Run a module-local cocotb FuseSoC sim target
```

## Module Catalogue

### AXI4

| Module | Core | Description |
| --- | --- | --- |
| `modules/interfaces/axi4` | `akerlund::axi4_if:0` | AXI4 interface definition |
| `modules/axi4_read_arbiter` | `akerlund::axi4_read_arbiter:0` | AXI4 read arbiter, multiple masters to multiple slaves |
| `modules/axi4_write_arbiter` | `akerlund::axi4_write_arbiter:0` | AXI4 write arbiter, multiple masters to multiple slaves |

### AXI4-Stream

| Module | Core | Description |
| --- | --- | --- |
| `modules/axi4s_fifo` | `akerlund::axi4s_fifo:0` | AXI4-Stream FIFO |
| `modules/axi4s_m2s_arbiter` | `akerlund::axi4s_m2s_arbiter:0` | AXI4-Stream many-to-single arbiter |
| `modules/axi4s_s2m_arbiter` | `akerlund::axi4s_s2m_arbiter:0` | AXI4-Stream single-to-many arbiter |

### FIFOs

| Module | Core | Description |
| --- | --- | --- |
| `modules/afifo` | `akerlund::afifo:0` | Asynchronous FIFO with gray-code pointer synchronization |
| `modules/fifo` | `akerlund::fifo:0` | RAM-backed synchronous FIFO; `fifo_register` is available for explicit register-backed use |

### Clock Enables

| Module | Core | Description |
| --- | --- | --- |
| `modules/clock_enablers/clock_enable` | `akerlund::clock_enable:0` | Clock enable generator |
| `modules/clock_enablers/clock_enable_scaler` | `akerlund::clock_enable_scaler:0` | Clock enable scaler |
| `modules/clock_enablers/delay_enable` | `akerlund::delay_enable:0` | Delay-based clock enable generator |
| `modules/clock_enablers/frequency_enable` | `akerlund::frequency_enable:0` | Frequency-based clock enable generator with AXI4-Stream interface |

### DSP And Audio

| Module | Core | Description |
| --- | --- | --- |
| `modules/dsp/iir_biquad_filter` | `akerlund::iir_biquad_filter:0` | IIR biquad filter with AXI4 control and AXI4-Stream data interfaces |
| `modules/mixer` | `akerlund::mixer:0` | Multi-channel audio mixer |
| `modules/oscillator` | `akerlund::oscillator:0` | Multi-waveform oscillator with AXI4 control interface |

### Math

| Module | Core | Description |
| --- | --- | --- |
| `modules/math/cordic` | `akerlund::cordic:0` | CORDIC algorithm core with AXI4-Stream interface |
| `modules/math/lfsr` | `akerlund::lfsr:0` | Parameterized Linear Feedback Shift Register |
| `modules/math/long_division` | `akerlund::long_division:0` | Long division core with AXI4-Stream interface |
| `modules/math/multiplication` | `akerlund::multiplication:0` | N.Q fixed-point multiplier with AXI4-Stream interface |

### Memory

| Module | Core | Description |
| --- | --- | --- |
| `modules/memory/ram` | `akerlund::memory_ram:0` | Single-port and dual-port synchronous RAM primitives |
| `modules/memory/reg` | `akerlund::memory_reg:0` | Single-port register file |

### Mechanics

| Module | Core | Description |
| --- | --- | --- |
| `modules/mechanics/button` | `akerlund::button:0` | Debounced button core |
| `modules/mechanics/encoder` | `akerlund::encoder:0` | Rotary encoder top |
| `modules/mechanics/switch` | `akerlund::switch:0` | Debounced switch core |

### Synchronizers

| Module | Core | Description |
| --- | --- | --- |
| `modules/synchronizers/cdc_bit_sync` | `akerlund::cdc_bit_sync:0` | Clock domain crossing bit synchronizer |
| `modules/synchronizers/cdc_vector_sync` | `akerlund::cdc_vector_sync:0` | Clock domain crossing vector synchronizer |
| `modules/synchronizers/io` | `akerlund::io_synchronizer:0` | I/O input synchronizer |
| `modules/synchronizers/reset` | `akerlund::reset_synchronizer:0` | Reset synchronizer |

### Examples

| Module | Core | Description |
| --- | --- | --- |
| `modules/examples` | `akerlund::examples:0` | Example/template module for UVM testbench development |

## Repository Layout

```text
modules/             Reusable RTL FuseSoC cores
scripts/refuse.sh    Local build/test helper for module workflows
submodules/VIP       Verification IP dependencies
submodules/PYRG      Register-generation dependencies
```
