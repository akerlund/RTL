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

`ifndef OSC_TB_PKG
`define OSC_TB_PKG

package osc_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import oscillator_types_pkg::*;
  import osc_address_pkg::*;

  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4_types_pkg::*;
  import vip_axi4_agent_pkg::*;

  // DUT constants
  localparam int SYS_CLK_FREQUENCY_C  = 125000000;
  localparam int PRIME_FREQUENCY_C    = 1000000;
  localparam int SAMPLING_FREQUENCY_C = 44100;
  localparam int WAVE_WIDTH_C         = 24;
  localparam int DUTY_CYCLE_DIVIDER_C = 1000;
  localparam int N_BITS_C             = 32;
  localparam int Q_BITS_C             = 11;
  localparam int AXI_DATA_WIDTH_C     = 32;
  localparam int AXI_ID_WIDTH_C       = 32;
  localparam int AXI_ID_C             = 32'hDEADBEA7;
  localparam int NR_OF_CHANNELS_C     = 2;
  localparam int COUNTER_WIDTH_C      = $clog2(SYS_CLK_FREQUENCY_C / SAMPLING_FREQUENCY_C);

  // Configuration of the VIP (Registers)
  localparam vip_axi4_cfg_t VIP_REG_CFG_C = '{
    AWID_WIDTH_P   : 2,
    ARID_WIDTH_P   : 2,
    ADDR_WIDTH_P   : 16,
    WDATA_BYTES_P  : (64)/8,
    RDATA_BYTES_P  : (64)/8,
    AWUSER_WIDTH_P : 1,
    WUSER_WIDTH_P  : 1,
    BUSER_WIDTH_P  : 1,
    ARUSER_WIDTH_P : 1,
    RUSER_WIDTH_P  : 1
  };

  // Register model
  `include "osc_reg.sv"
  `include "osc_block.sv"
  `include "register_model.sv"
  `include "vip_axi4_adapter.sv"

  `include "osc_virtual_sequencer.sv"
  `include "osc_env.sv"

endpackage

`endif
