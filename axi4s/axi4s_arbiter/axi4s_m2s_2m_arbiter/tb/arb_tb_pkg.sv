`ifndef ARB_TB_PKG
`define ARB_TB_PKG

package arb_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;

  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t vip_axi4s_cfg = '{
    AXI_DATA_WIDTH_P : 16,
    AXI_STRB_WIDTH_P : 0,
    AXI_KEEP_WIDTH_P : 2,
    AXI_ID_WIDTH_P   : 1,
    AXI_DEST_WIDTH_P : 1,
    AXI_USER_WIDTH_P : 0
  };

  `include "arb_config.sv"
  `include "arb_scoreboard.sv"
  `include "arb_virtual_sequencer.sv"
  `include "arb_env.sv"
  `include "arb_vseq_lib.sv"

endpackage

`endif
