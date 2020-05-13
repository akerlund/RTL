package vip_axi4s_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Unoffical bit boundary (total burst size)
  localparam AXI4S_BURST_BIT_BOUNDARY_C = 4096;

  typedef enum {
    VIP_AXI4S_MASTER_AGENT_E,
    VIP_AXI4S_SLAVE_AGENT_E
  } vip_axi4s_agent_type_t;

  typedef struct packed {
    int AXI_DATA_WIDTH_P;
    int AXI_STRB_WIDTH_P;
    int AXI_KEEP_WIDTH_P;
    int AXI_ID_WIDTH_P;
    int AXI_DEST_WIDTH_P;
    int AXI_USER_WIDTH_P;
  } vip_axi4s_cfg_t;

  `include "vip_axi4s_item.sv"
  `include "vip_axi4s_config.sv"
  `include "vip_axi4s_monitor.sv"
  `include "vip_axi4s_sequencer.sv"
  `include "vip_axi4s_driver.sv"
  `include "vip_axi4s_agent.sv"
  `include "vip_axi4s_seq_lib.sv"

endpackage