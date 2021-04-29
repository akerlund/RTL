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
    output logic                      rp_valid,
    output logic                      rp_fifo_empty,

    output logic                      sr_wp_fifo_active,
    output logic   [ADDR_WIDTH_P : 0] sr_wp_fill_level,
    output logic   [ADDR_WIDTH_P : 0] sr_wp_max_fill_level,

    output logic                      sr_rp_fifo_active,
    output logic   [ADDR_WIDTH_P : 0] sr_rp_fill_level
  );

  // FPGA will use RAM if the memory is larger than 2048 bits
  localparam int SYNC_ADDR_WIDTH_C = 4;

  logic                         wp_async_write_en;
  logic                         afifo_rd_en;
  logic                         rp_async_valid;
  logic      [ADDR_WIDTH_P : 0] rp_async_fill_level;
  logic    [DATA_WIDTH_P-1 : 0] rp_async_data_out;

  logic                         sync_rp_read_en;
  logic [SYNC_ADDR_WIDTH_C : 0] rp_sync_fill_level;

  assign wp_async_write_en = wp_write_en && !wp_fifo_full;
  assign sync_rp_read_en   = rp_read_en  && !rp_fifo_empty;


  assign afifo_rd_en = !rp_async_valid && (rp_sync_fill_level + {{SYNC_ADDR_WIDTH_C-1{1'b0}}, rp_async_valid} < SYNC_ADDR_WIDTH_C);

  afifo_core #(
    .DATA_WIDTH_P         ( DATA_WIDTH_P         ),
    .ADDR_WIDTH_P         ( ADDR_WIDTH_P         )
  ) afifo_core_i0 (
    .wclk                 ( clk_wp               ),
    .rst_w_n              ( rst_wp_n             ),
    .rclk                 ( clk_rp               ),
    .rst_r_n              ( rst_rp_n             ),
    .wclk_wr_en           ( wp_async_write_en    ),
    .wclk_data            ( wp_data_in           ),
    .wclk_full            ( wp_fifo_full         ),
    .rclk_rd_en           ( afifo_rd_en     ),
    .rclk_data            ( rp_async_data_out    ),
    .rclk_empty           ( rp_async_valid       )
    //.sr_wp_fifo_active    ( sr_wp_fifo_active    ),
    //.sr_wp_fill_level     ( sr_wp_fill_level     ),
    //.sr_wp_max_fill_level ( sr_wp_max_fill_level ),
    //.sr_rp_fifo_active    ( sr_rp_fifo_active    ),
    //.sr_rp_fill_level     ( rp_async_fill_level  )
  );

  fifo_register #(
    .DATA_WIDTH_P    ( DATA_WIDTH_P       ),
    .ADDR_WIDTH_P    ( SYNC_ADDR_WIDTH_C  )
  ) fifo_register_i0 (
    .clk             ( clk_rp             ),
    .rst_n           ( rst_rp_n           ),
    .ing_enable      ( afifo_rd_en     ),
    .ing_data        ( rp_async_data_out  ),
    .ing_full        (                    ),
    .egr_enable      ( sync_rp_read_en    ),
    .egr_data        ( rp_data_out        ),
    .egr_empty       ( rp_fifo_empty      ),
    .sr_fill_level   ( rp_sync_fill_level )
  );

  always_comb begin
    if (rp_fifo_empty) begin
      sr_rp_fill_level <= '0;
    end
    else begin
      sr_rp_fill_level <= rp_async_fill_level + rp_sync_fill_level + rp_async_valid;
    end
  end

  // Valid process
  always_ff @ (posedge clk_rp or negedge rst_rp_n) begin
    if (!rst_rp_n) begin
      rp_valid <= '0;
    end
    else begin
      if (!rp_fifo_empty && sync_rp_read_en) begin
        rp_valid <= '1;
      end
      else begin
        rp_valid <= '0;
      end
    end
  end

endmodule

`default_nettype wire
