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

  localparam int AXI_DATA_WIDTH_C = 16;
  localparam int AXI_ID_WIDTH_C   = 4;
  localparam int NR_OF_STAGES_C   = 16;

  logic                             clk;
  logic                             rst_n;
  logic                             ing_tvalid;
  logic [AXI_DATA_WIDTH_C-1 : 0]    ing_tdata;
  logic [AXI_ID_WIDTH_C-1 : 0]      ing_tid;
  logic                             ing_tuser;
  logic                             egr_tvalid;
  logic [2*AXI_DATA_WIDTH_C-1 : 0]  egr_tdata;
  logic [AXI_ID_WIDTH_C-1 : 0]      egr_tid;

  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .NR_OF_STAGES_P   ( NR_OF_STAGES_C   )
  ) dut (
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .ing_tvalid  ( ing_tvalid  ),
    .ing_tdata   ( ing_tdata   ),
    .ing_tid     ( ing_tid     ),
    .ing_tuser   ( ing_tuser   ),
    .egr_tvalid  ( egr_tvalid  ),
    .egr_tdata   ( egr_tdata   ),
    .egr_tid     ( egr_tid     )
  );

endmodule

`default_nettype wire
