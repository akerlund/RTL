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

`ifndef MIX_TB_PKG
`define MIX_TB_PKG

package mix_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import bool_pkg::*;
  import vip_axi4s_types_pkg::*;
  import vip_axi4s_agent_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_fixed_point_pkg::*;

  localparam int                         AUDIO_WIDTH_C    = 24;
  localparam int                         GAIN_WIDTH_C     = 24;
  localparam int                         NR_OF_CHANNELS_C = 4;
  localparam int                         Q_BITS_C         = 7;
  localparam logic [AUDIO_WIDTH_C-1 : 0] ONE_C            = 1 << Q_BITS_C;

  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t VIP_AXI4S_CFG_C = '{
    VIP_AXI4S_TDATA_BYTES_P : AUDIO_WIDTH_C/8,
    VIP_AXI4S_TID_WIDTH_P   : 2,
    VIP_AXI4S_TDEST_WIDTH_P : 0,
    VIP_AXI4S_TUSER_WIDTH_P : 1
  };

  typedef vip_axi4s_seq #(VIP_AXI4S_CFG_C) vip_axi4s_seq_t;

  `include "mix_scoreboard.sv"
  `include "mix_virtual_sequencer.sv"
  `include "mix_env.sv"
  `include "mix_seq_lib.sv"

endpackage

`endif
