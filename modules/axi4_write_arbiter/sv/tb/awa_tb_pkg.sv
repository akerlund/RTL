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

package awa_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4_types_pkg::*;
  import vip_axi4_agent_pkg::*;

  localparam int NR_OF_ARBITERS_C = 4;
  localparam int NR_OF_SLAVES_C   = 4;
  localparam int NR_OF_MASTERS_C  = NR_OF_SLAVES_C*4;

  // Configuration of the VIP
  localparam vip_axi4_cfg_t VIP_AXI4_CFG_C = '{
    AWID_WIDTH_P   : 16,
    ARID_WIDTH_P   : 16,
    ADDR_WIDTH_P   : 13,
    WDATA_BYTES_P  : (32)/8,
    RDATA_BYTES_P  : (32)/8,
    AWUSER_WIDTH_P : 1,
    WUSER_WIDTH_P  : 1,
    BUSER_WIDTH_P  : 1,
    ARUSER_WIDTH_P : 1,
    RUSER_WIDTH_P  : 1
  };

  `include "awa_scoreboard.sv"
  `include "awa_virtual_sequencer.sv"
  `include "awa_env.sv"

endpackage
