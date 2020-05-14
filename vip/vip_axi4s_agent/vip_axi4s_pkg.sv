`ifndef VIP_AXI4S_PKG
`define VIP_AXI4S_PKG

package vip_axi4s_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_axi4s_types_pkg::*;

  // Unoffical bit boundary (total burst size)
  localparam AXI4S_MAX_BURST_LENGTH_C = 4096;


  `include "vip_axi4s_item.sv"
  `include "vip_axi4s_config.sv"
  `include "vip_axi4s_monitor.sv"
  `include "vip_axi4s_sequencer.sv"
  `include "vip_axi4s_driver.sv"
  `include "vip_axi4s_agent.sv"
  `include "vip_axi4s_seq_lib.sv"

endpackage

`endif
