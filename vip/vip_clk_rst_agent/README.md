# Clock and Reset Agent

![Test  Status](https://img.shields.io/badge/test-passing-green)

An agent which generates a clock and a reset signal. The interface consists of:

```verilog
interface clk_rst_if;
  logic clk;
  logic rst;
  logic rst_n;
endinterface
```

## Agent Configuration

### Clock

The clock period is set inside the Agent's configuration object:

```verilog
class clk_rst_config extends uvm_object;
  realtime clock_period = 10.0;
endclass
```

## Clock and Reset Item

The **clk_rst_item** holds two variables which are used by the driver. The driver can set the reset value (**reset_value**) on different clock flanks (**reset_edge**).


The clock period is set inside the Agent's configuration object:

```verilog
class clk_rst_item extends uvm_sequence_item;
  reset_edge_t  reset_edge  = RESET_AT_CLK_RISING_EDGE_E;
  reset_value_t reset_value = RESET_INACTIVE_E;
endclass
```

The custom types inside the **clk_rst_item** are found inside the **clk_rst_types_pkg**:

```verilog
package clk_rst_types_pkg;

  typedef enum {
    RESET_ASYNCHRONOUSLY_E,
    RESET_AT_CLK_RISING_EDGE_E,
    RESET_AT_CLK_FALLING_EDGE_E
  } reset_edge_t;

  typedef enum bit {
    RESET_INACTIVE_E,
    RESET_ACTIVE_E
  } reset_value_t;

endpackage
```

## Reset Sequence

The **reset_sequence** creates two **clk_rst_item** items and sends them to the driver sequentially. The variable **reset_duration** is set before starting the sequence.

```verilog
virtual task body();

  clk_rst_item0 = new("item");

  clk_rst_item0.reset_edge  = RESET_ASYNCHRONOUSLY_E;
  clk_rst_item0.reset_value = RESET_ACTIVE_E;

  req = clk_rst_item0;
  start_item(req);
  finish_item(req);

  #reset_duration;

  clk_rst_item0.reset_edge  = RESET_AT_CLK_RISING_EDGE_E;
  clk_rst_item0.reset_value = RESET_INACTIVE_E;

  req = clk_rst_item0;
  start_item(req);
  finish_item(req);

endtask
```

### Using RESET_ASYNCHRONOUSLY_E

If the **reset_edge** variable is set to **RESET_ASYNCHRONOUSLY_E** the driver will wait for 3 quarters of one clock period, i.e.,

```verilog
#(3*cfg.clock_period/4);
```

## Monitor

The monitor will report how many clock periods a reset lasted. When the reset signal is asserted the monitor will put an *uvm_event* on its *uvm_analysis_port* for other agents to use.

```
clk_rst_monitor.sv(78) @ 12000: uvm_test_top.tb_env.clk_rst_agent0.monitor [clk_rst_monitor] Reset asserted
clk_rst_monitor.sv(94) @ 125000: uvm_test_top.tb_env.clk_rst_agent0.monitor [clk_rst_monitor] Reset de-asserted
clk_rst_monitor.sv(101) @ 125000: uvm_test_top.tb_env.clk_rst_agent0.monitor [clk_rst_monitor] Reset (rst/rst_n) was active for (11.33) clock periods
```