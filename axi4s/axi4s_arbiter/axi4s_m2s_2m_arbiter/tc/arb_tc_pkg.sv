package arb_tc_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;

  // Import testbench and agent packages here
  import arb_tb_pkg::*;

  // Include testcase files here
  `include "arb_base_test.sv"
  `include "tc_arb_simple_test.sv"

endpackage