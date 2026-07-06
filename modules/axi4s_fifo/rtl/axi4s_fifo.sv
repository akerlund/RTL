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

module axi4s_fifo #(
    parameter int TUSER_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P  = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,

    output logic                       ing_tready,
    input  wire  [TUSER_WIDTH_P-1 : 0] ing_tuser,
    input  wire                        ing_tvalid,

    input  wire                        egr_tready,
    output logic [TUSER_WIDTH_P-1 : 0] egr_tuser,
    output logic                       egr_tvalid,

    output logic    [ADDR_WIDTH_P : 0] sr_fill_level,
    output logic    [ADDR_WIDTH_P : 0] sr_max_fill_level,
    output logic                       sr_almost_full,
    input  wire     [ADDR_WIDTH_P : 0] cr_almost_full_level
  );

  logic wp_fifo_full;
  logic rp_fifo_empty;
  logic ing_transaction;
  logic egr_transaction;

  assign ing_tready      = !wp_fifo_full;
  assign egr_tvalid      = !rp_fifo_empty;

  assign ing_transaction = ing_tready && ing_tvalid;
  assign egr_transaction = egr_tready && egr_tvalid;

  fifo #(
    .DATA_WIDTH_P         ( TUSER_WIDTH_P        ),
    .ADDR_WIDTH_P         ( ADDR_WIDTH_P         )
  ) fifo_i0 (
    .clk                  ( clk                  ), // input
    .rst_n                ( rst_n                ), // input
    .ing_enable           ( ing_transaction      ), // input
    .ing_data             ( ing_tuser            ), // input
    .ing_full             ( wp_fifo_full         ), // output
    .ing_almost_full      ( sr_almost_full       ), // output
    .egr_enable           ( egr_transaction      ), // input
    .egr_data             ( egr_tuser            ), // output
    .egr_empty            ( rp_fifo_empty        ), // output
    .sr_fill_level        ( sr_fill_level        ), // output
    .sr_max_fill_level    ( sr_max_fill_level    ), // output
    .cr_almost_full_level ( cr_almost_full_level )  // input
  );

endmodule

`default_nettype wire
