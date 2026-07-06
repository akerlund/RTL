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

`ifndef ARB_TB_PKG
`define ARB_TB_PKG

package arb_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4s_types_pkg::*;
  import vip_axi4s_agent_pkg::*;

  localparam int NR_OF_MASTERS_C = 3;

  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t VIP_AXI4S_CFG_C = '{
    VIP_AXI4S_TDATA_BYTES_P : 2,
    VIP_AXI4S_TID_WIDTH_P   : 2,
    VIP_AXI4S_TDEST_WIDTH_P : 2,
    VIP_AXI4S_TUSER_WIDTH_P : 0
  };

  typedef vip_axi4s_seq #(VIP_AXI4S_CFG_C) vip_axi4s_seq_t;

  `include "arb_scoreboard.sv"
  `include "arb_virtual_sequencer.sv"
  `include "arb_env.sv"

endpackage

`endif
