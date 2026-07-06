////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

`ifndef SYiir_TB_PKG
`define SYiir_TB_PKG

package iir_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import iir_biquad_types_pkg::*;
  import iir_address_pkg::*;

  import vip_fixed_point_pkg::*;
  import vip_iir_pkg::*;

  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4s_types_pkg::*;
  import vip_axi4s_agent_pkg::*;
  import vip_axi4_types_pkg::*;
  import vip_axi4_agent_pkg::*;

  localparam int VIP_AXI4S_TDATA_WIDTH_C = 32;
  localparam int VIP_AXI4S_TSTRB_WIDTH_C = VIP_AXI4S_TDATA_WIDTH_C/8;
  localparam int VIP_AXI4S_TKEEP_WIDTH_C = 0;
  localparam int VIP_AXI4S_TID_WIDTH_C   = 11;
  localparam int VIP_AXI4S_TDEST_WIDTH_C = 0;
  localparam int VIP_AXI4S_TUSER_WIDTH_C = 0;


  localparam int N_BITS_C         = 32;
  localparam int Q_BITS_C         = 11;
  localparam int AXI_ID_WIDTH_C   = 3;
  localparam int CFG_DATA_WIDTH_C = 64;

  // Configuration of the VIP (Data)
  localparam vip_axi4s_cfg_t VIP_AXI4S_CFG_C = '{
    VIP_AXI4S_TDATA_BYTES_P : VIP_AXI4S_TDATA_WIDTH_C/8,
    VIP_AXI4S_TID_WIDTH_P   : 0,
    VIP_AXI4S_TDEST_WIDTH_P : 0,
    VIP_AXI4S_TUSER_WIDTH_P : 0
  };

  typedef vip_axi4s_seq #(VIP_AXI4S_CFG_C) vip_axi4s_seq_t;

  // Configuration of the VIP (Registers)
  localparam vip_axi4_cfg_t VIP_REG_CFG_C = '{
    AWID_WIDTH_P   : 2,
    ARID_WIDTH_P   : 2,
    ADDR_WIDTH_P   : 16,
    WDATA_BYTES_P  : (CFG_DATA_WIDTH_C)/8,
    RDATA_BYTES_P  : (CFG_DATA_WIDTH_C)/8,
    AWUSER_WIDTH_P : 1,
    WUSER_WIDTH_P  : 1,
    BUSER_WIDTH_P  : 1,
    ARUSER_WIDTH_P : 1,
    RUSER_WIDTH_P  : 1
  };

  `include "iir_reg.sv"
  `include "iir_block.sv"
  `include "register_model.sv"
  `include "vip_axi4_adapter.sv"

  `include "iir_scoreboard.sv"
  `include "iir_virtual_sequencer.sv"
  `include "iir_env.sv"

endpackage

`endif
