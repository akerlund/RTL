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

  localparam int DATA_WIDTH_C = 33;
  localparam int ADDR_WIDTH_C = 6;

  logic                      clk_wp;
  logic                      rst_wp_n;
  logic                      clk_rp;
  logic                      rst_rp_n;
  logic                      wp_write_en;
  logic [DATA_WIDTH_C-1 : 0] wp_data_in;
  logic                      wp_fifo_full;
  logic                      rp_read_en;
  logic [DATA_WIDTH_C-1 : 0] rp_data_out;
  logic                      rp_fifo_empty;
  logic   [ADDR_WIDTH_C : 0] sr_wp_fill_level;
  logic   [ADDR_WIDTH_C : 0] sr_wp_max_fill_level;
  logic   [ADDR_WIDTH_C : 0] sr_rp_fill_level;

  afifo #(
    .DATA_WIDTH_P ( DATA_WIDTH_C ),
    .ADDR_WIDTH_P ( ADDR_WIDTH_C )
  ) dut (
    .clk_wp               ( clk_wp               ),
    .rst_wp_n             ( rst_wp_n             ),
    .clk_rp               ( clk_rp               ),
    .rst_rp_n             ( rst_rp_n             ),
    .wp_write_en          ( wp_write_en          ),
    .wp_data_in           ( wp_data_in           ),
    .wp_fifo_full         ( wp_fifo_full         ),
    .rp_read_en           ( rp_read_en           ),
    .rp_data_out          ( rp_data_out          ),
    .rp_fifo_empty        ( rp_fifo_empty        ),
    .sr_wp_fill_level     ( sr_wp_fill_level     ),
    .sr_wp_max_fill_level ( sr_wp_max_fill_level ),
    .sr_rp_fill_level     ( sr_rp_fill_level     )
  );

endmodule

`default_nettype wire
