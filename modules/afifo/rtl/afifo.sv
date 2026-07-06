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

module afifo #(
    parameter int DATA_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P = -1
  )(
    input  wire                       clk_wp,
    input  wire                       rst_wp_n,
    input  wire                       clk_rp,
    input  wire                       rst_rp_n,

    input  wire                       wp_write_en,
    input  wire  [DATA_WIDTH_P-1 : 0] wp_data_in,
    output logic                      wp_fifo_full,

    input  wire                       rp_read_en,
    output logic [DATA_WIDTH_P-1 : 0] rp_data_out,
    output logic                      rp_fifo_empty,

    output logic   [ADDR_WIDTH_P : 0] sr_wp_fill_level,
    output logic   [ADDR_WIDTH_P : 0] sr_wp_max_fill_level,

    output logic   [ADDR_WIDTH_P : 0] sr_rp_fill_level
  );

  localparam int REG_ADDR_WIDTH_C = 2;
  localparam int RP_FILL_PAD_C    = (ADDR_WIDTH_P > REG_ADDR_WIDTH_C) ? ADDR_WIDTH_P - REG_ADDR_WIDTH_C : 0;

  // AFIFO
  logic                        wclk_wr_en_c0;
  logic                        rclk_rd_en_c0;
  logic                        rclk_rd_en_d0;
  logic   [DATA_WIDTH_P-1 : 0] rclk_data;
  logic                        rclk_empty;
  logic     [ADDR_WIDTH_P : 0] sr_rclk_fill_level;
  logic     [ADDR_WIDTH_P : 0] rp_sr_fill_level_w;

  // FIFO
  logic                        rp_read_en_c0;
  logic [REG_ADDR_WIDTH_C : 0] rp_sr_fill_level;

  generate
    if (ADDR_WIDTH_P > REG_ADDR_WIDTH_C) begin : gen_pad_rp_fill
      assign rp_sr_fill_level_w = {{RP_FILL_PAD_C{1'b0}}, rp_sr_fill_level};
    end else begin : gen_trim_rp_fill
      assign rp_sr_fill_level_w = rp_sr_fill_level[ADDR_WIDTH_P : 0];
    end
  endgenerate

  // AFIFO
  assign wclk_wr_en_c0 = wp_write_en && !wp_fifo_full;
  assign rclk_rd_en_c0 = !rclk_empty && (rp_sr_fill_level <= 2);

  // FIFO
  assign rp_read_en_c0 = rp_read_en  && !rp_fifo_empty;


  afifo_core #(
    .DATA_WIDTH_P       ( DATA_WIDTH_P       ),
    .ADDR_WIDTH_P       ( ADDR_WIDTH_P       )
  ) afifo_core_i0 (
    // Write
    .wclk               ( clk_wp             ), // input
    .rst_w_n            ( rst_wp_n           ), // input
    .wclk_wr_en         ( wclk_wr_en_c0      ), // input
    .wclk_data          ( wp_data_in         ), // input
    .wclk_full          ( wp_fifo_full       ), // output
    // Read
    .rclk               ( clk_rp             ), // input
    .rst_r_n            ( rst_rp_n           ), // input
    .rclk_rd_en         ( rclk_rd_en_c0      ), // input
    .rclk_data          ( rclk_data          ), // output
    .rclk_empty         ( rclk_empty         ), // output
    .sr_wclk_fill_level ( sr_wp_fill_level   ), // output
    .sr_rclk_fill_level ( sr_rclk_fill_level )  // output
  );


  fifo_register #(
    .DATA_WIDTH_P    ( DATA_WIDTH_P     ),
    .ADDR_WIDTH_P    ( REG_ADDR_WIDTH_C )
  ) fifo_register_i0 (
    .clk             ( clk_rp           ), // input
    .rst_n           ( rst_rp_n         ), // input
    .ing_enable      ( rclk_rd_en_d0    ), // input
    .ing_data        ( rclk_data        ), // input
    .ing_full        (                  ), // output
    .egr_enable      ( rp_read_en_c0    ), // input
    .egr_data        ( rp_data_out      ), // output
    .egr_empty       ( rp_fifo_empty    ), // output
    .sr_fill_level   ( rp_sr_fill_level )  // output
  );


  always_ff @ (posedge clk_wp or negedge rst_wp_n) begin
    if (!rst_wp_n) begin
      sr_wp_max_fill_level <= '0;
    end else begin
      if (sr_wp_fill_level > sr_wp_max_fill_level) begin
        sr_wp_max_fill_level <= sr_wp_fill_level;
      end
    end
  end


  always_comb begin
    if (rp_fifo_empty) begin
      sr_rp_fill_level = '0;
    end else begin
      sr_rp_fill_level = sr_rclk_fill_level + rp_sr_fill_level_w;
    end
  end


  always_ff @ (posedge clk_rp or negedge rst_rp_n) begin
    if (!rst_rp_n) begin
      rclk_rd_en_d0 <= '0;
    end else begin
      rclk_rd_en_d0 <= rclk_rd_en_c0;
    end
  end

endmodule

`default_nettype wire
