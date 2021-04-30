////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
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

  // AFIFO
  logic                        wclk_wr_en_c0;
  logic                        rclk_rd_en_c0;
  logic                        rclk_rd_en_d0;
  logic   [DATA_WIDTH_P-1 : 0] rclk_data;
  logic                        rclk_empty;
  logic     [ADDR_WIDTH_P : 0] sr_rclk_fill_level;

  // FIFO
  logic                        rp_read_en_c0;
  logic [REG_ADDR_WIDTH_C : 0] rp_sr_fill_level;

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
      sr_rp_fill_level = sr_rclk_fill_level + rp_sr_fill_level;
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
