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

`default_nettype none

module tb_top;

  localparam int N_BITS_C         = 32;
  localparam int Q_BITS_C         = 11;
  localparam int AXI_DATA_WIDTH_C = N_BITS_C;
  localparam int AXI_ID_WIDTH_C   = 4;

  logic                          clk;
  logic                          rst_n;
  logic                          ing_tvalid;
  logic                          ing_tready;
  logic [AXI_DATA_WIDTH_C-1 : 0] ing_tdata;
  logic                          ing_tlast;
  logic [AXI_ID_WIDTH_C-1 : 0]   ing_tid;
  logic                          egr_tvalid;
  logic [AXI_DATA_WIDTH_C-1 : 0] egr_tdata;
  logic                          egr_tlast;
  logic [AXI_ID_WIDTH_C-1 : 0]   egr_tid;
  logic                          egr_tuser;

  nq_multiplier_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .N_BITS_P         ( N_BITS_C         ),
    .Q_BITS_P         ( Q_BITS_C         )
  ) dut (
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .ing_tvalid  ( ing_tvalid  ),
    .ing_tready  ( ing_tready  ),
    .ing_tdata   ( ing_tdata   ),
    .ing_tlast   ( ing_tlast   ),
    .ing_tid     ( ing_tid     ),
    .egr_tvalid  ( egr_tvalid  ),
    .egr_tdata   ( egr_tdata   ),
    .egr_tlast   ( egr_tlast   ),
    .egr_tid     ( egr_tid     ),
    .egr_tuser   ( egr_tuser   )
  );

endmodule

`default_nettype wire
