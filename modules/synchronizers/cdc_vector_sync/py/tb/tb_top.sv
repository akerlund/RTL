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

  localparam int DATA_WIDTH_C = 25;

  logic                      clk0;
  logic                      rst0_n;
  logic                      clk1;
  logic                      rst1_n;

  logic [DATA_WIDTH_C-1 : 0] src_vector;
  logic                      src_valid;
  logic                      src_ready;
  logic [DATA_WIDTH_C-1 : 0] mid_vector;
  logic                      mid_valid;
  logic                      mid_ready;
  logic [DATA_WIDTH_C-1 : 0] dst_vector;
  logic                      dst_valid;
  logic                      dst_ready;

  cdc_vector_sync #(
    .DATA_WIDTH_P ( DATA_WIDTH_C )
  ) cdc_vector_sync_i0 (
    .clk_src    ( clk0       ),
    .rst_src_n  ( rst0_n     ),
    .clk_dst    ( clk1       ),
    .rst_dst_n  ( rst1_n     ),
    .ing_vector ( src_vector ),
    .ing_valid  ( src_valid  ),
    .ing_ready  ( src_ready  ),
    .egr_vector ( mid_vector ),
    .egr_valid  ( mid_valid  ),
    .egr_ready  ( mid_ready  )
  );

  cdc_vector_sync #(
    .DATA_WIDTH_P ( DATA_WIDTH_C )
  ) cdc_vector_sync_i1 (
    .clk_src    ( clk1       ),
    .rst_src_n  ( rst1_n     ),
    .clk_dst    ( clk0       ),
    .rst_dst_n  ( rst0_n     ),
    .ing_vector ( mid_vector ),
    .ing_valid  ( mid_valid  ),
    .ing_ready  ( mid_ready  ),
    .egr_vector ( dst_vector ),
    .egr_valid  ( dst_valid  ),
    .egr_ready  ( dst_ready  )
  );

endmodule

`default_nettype wire
