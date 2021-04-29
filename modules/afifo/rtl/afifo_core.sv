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

module afifo_core #(
    parameter int DATA_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P = -1
  )(
    input  wire                       wclk,
    input  wire                       rst_w_n,
    input  wire                       wclk_wr_en,
    input  wire  [DATA_WIDTH_P-1 : 0] wclk_data,
    output logic                      wclk_full,

    input  wire                       rclk,
    input  wire                       rst_r_n,
    input  wire                       rclk_rd_en,
    output logic [DATA_WIDTH_P-1 : 0] rclk_data,
    output logic                      rclk_empty
  );

  logic                      wp_rp_under_reset_n;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_bin;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_bin_next;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_gray;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_gray_next;
  logic [ADDR_WIDTH_P-1 : 0] wclk_wr_addr;
  logic                      wclk_full_next;
  logic   [ADDR_WIDTH_P : 0] wclk_rd_gray0;
  logic   [ADDR_WIDTH_P : 0] wclk_rd_gray1;

  logic                      rp_wp_under_reset_n;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_bin;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_bin_next;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_gray;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_gray_next;
  logic [ADDR_WIDTH_P-1 : 0] rclk_rd_addr;
  logic                      rclk_empty_next;
  logic   [ADDR_WIDTH_P : 0] rclk_wr_gray0;
  logic   [ADDR_WIDTH_P : 0] rclk_wr_gray1;

  logic                      wclk_mem_wr_en;

  // ---------------------------------------------------------------------------
  // Write logic
  // ---------------------------------------------------------------------------

  // Calculate the next write address, and the next graycode pointer.
  assign wclk_wr_bin_next  = wclk_wr_bin + {{ADDR_WIDTH_P{1'b0}}, wclk_wr_en && !wclk_full};
  assign wclk_wr_gray_next = (wclk_wr_bin_next >> 1) ^ wclk_wr_bin_next;
  assign wclk_wr_addr      = wclk_wr_bin[ADDR_WIDTH_P-1 : 0];
  assign wclk_full_next    = (wclk_wr_gray_next == { ~wclk_rd_gray1[ADDR_WIDTH_P : ADDR_WIDTH_P-1], wclk_rd_gray1[ADDR_WIDTH_P-2:0] });

  // Read pointer CDC, RCLK -> WCLK
  always_ff @(posedge wclk or negedge rst_w_n) begin
    if (!rst_w_n) begin
      {wclk_rd_gray1, wclk_rd_gray0} <= 0;
    end else begin
      {wclk_rd_gray1, wclk_rd_gray0} <= {wclk_rd_gray0, rclk_rd_gray};
    end
  end

  // Register these two values--the address and its Gray code representation
  always_ff @(posedge wclk or negedge rst_w_n) begin
    if (!rst_w_n) begin
      {wclk_wr_bin, wclk_wr_gray} <= 0;
    end else begin
      {wclk_wr_bin, wclk_wr_gray} <= {wclk_wr_bin_next, wclk_wr_gray_next};
    end
  end

  // Calculate whether or not the register will be full on the next clock.
  always_ff @(posedge wclk or negedge rst_w_n) begin
    if (!rst_w_n) begin
      wclk_full <= 1'b0;
    end else begin
      wclk_full <= wclk_full_next;
    end
  end

  assign wclk_mem_wr_en = wclk_wr_en && !wclk_full;


  // ---------------------------------------------------------------------------
  // Read logic
  // ---------------------------------------------------------------------------

  assign rclk_rd_bin_next  = rclk_rd_bin + {{ADDR_WIDTH_P{1'b0}}, rclk_rd_en && !rclk_empty};
  assign rclk_rd_gray_next = (rclk_rd_bin_next >> 1) ^ rclk_rd_bin_next;
  assign rclk_rd_addr      = rclk_rd_bin[ADDR_WIDTH_P-1 : 0];
  assign rclk_empty_next   = (rclk_rd_gray_next == rclk_wr_gray1);

  always_ff @(posedge rclk or negedge rst_r_n) begin
    if (!rst_r_n) begin
      {rclk_wr_gray1, rclk_wr_gray0} <= 0;
    end else begin
      {rclk_wr_gray1, rclk_wr_gray0} <= {rclk_wr_gray0, wclk_wr_gray};
    end
  end

  always_ff @(posedge rclk or negedge rst_r_n) begin
    if (!rst_r_n) begin
      {rclk_rd_bin, rclk_rd_gray} <= 0;
    end else begin
      {rclk_rd_bin, rclk_rd_gray} <= {rclk_rd_bin_next, rclk_rd_gray_next};
    end
  end

  always_ff @(posedge rclk or negedge rst_r_n) begin
    if (!rst_r_n) begin
      rclk_empty <= 1'b1;
    end else begin
      rclk_empty <= rclk_empty_next;
    end
  end






  // Write port signals
  logic wp_wp_under_reset_n;
  logic sr_wp_fifo_active;

  // // Write process
  // always_ff @ (posedge wclk or negedge rst_wp_n) begin
  //   if (!rst_wp_n) begin
  //     wp_wp_under_reset_n     <= '0;
  //     sr_wp_fifo_active       <= '0;
  //   end
  //   else begin

  //     wp_wp_under_reset_n <= 1;

  //     // Synchronized reset
  //     if (wp_wp_under_reset_n && wp_rp_under_reset_n) begin

  //       sr_wp_fifo_active <= '1;

  //     end
  //   end
  // end


  // Read process
  logic rp_rp_under_reset_n;
  logic sr_rp_fifo_active;
  // always_ff @ (posedge rclk or negedge rst_r_n) begin
    // if (!rst_r_n) begin
      // rp_rp_under_reset_n    <= '0;
      // sr_rp_fifo_active      <= '0;
    // end
    // else begin
//
      // rp_rp_under_reset_n <= 1;
//
      // if (rp_rp_under_reset_n && rp_wp_under_reset_n) begin // Synchronized reset
//
        // sr_rp_fifo_active <= 1;
//
      // end
    // end
  // end

  ram_sdp2c #(
    .DATA_WIDTH_P        ( DATA_WIDTH_P      ),
    .ADDR_WIDTH_P        ( ADDR_WIDTH_P      )
  ) ram_sdp2c_i0 (
    .clk_a               ( wclk             ),
    .port_a_enable       ( '1                ),
    .port_a_write_enable ( wclk_mem_wr_en    ),
    .port_a_address      ( wclk_wr_addr      ),
    .port_a_data_ing     ( wclk_data         ),
    .clk_b               ( rclk              ),
    .port_b_enable       ( '1                ),
    .port_b_address      ( rclk_rd_addr      ),
    .port_b_data_egr     ( rclk_data         )
  );

/*
  cdc_bit_sync cdc_bit_sync_i0 (
    .clk_src   ( wclk               ),
    .rst_src_n ( rst_w_n            ),
    .clk_dst   ( rclk                ),
    .rst_dst_n ( rst_r_n            ),
    .src_bit   ( wp_wp_under_reset_n ),
    .dst_bit   ( rp_wp_under_reset_n )
  );


  cdc_bit_sync cdc_bit_sync_i1 (
    .clk_src   ( rclk                ),
    .rst_src_n ( rst_r_n            ),
    .clk_dst   ( wclk               ),
    .rst_dst_n ( rst_w_n            ),
    .src_bit   ( rp_rp_under_reset_n ),
    .dst_bit   ( wp_rp_under_reset_n )
  );*/
/*

  // Read pointer, rclk   to wclk
  genvar i;
  generate
    for (i = 0; i <= ADDR_WIDTH_P; i++) begin
      cdc_bit_sync cdc_bit_sync_i (
        .clk_src   ( rclk                    ),
        .rst_src_n ( rst_rp_n                ),
        .clk_dst   ( wclk                   ),
        .rst_dst_n ( rst_wp_n                ),
        .src_bit   ( rp_read_pointer_gray[i] ),
        .dst_bit   ( wp_read_pointer_gray[i] )
      );
    end
  endgenerate

  // Write pointer, wclk  to rclk
  generate
    for (i = 0; i <= ADDR_WIDTH_P; i++) begin
      cdc_bit_sync cdc_bit_sync_i (
        .clk_src   ( wclk                    ),
        .rst_src_n ( rst_wp_n                 ),
        .clk_dst   ( rclk                     ),
        .rst_dst_n ( rst_rp_n                 ),
        .src_bit   ( wp_write_pointer_gray[i] ),
        .dst_bit   ( rp_write_pointer_gray[i] )
      );
    end
  endgenerate
*/
endmodule

`default_nettype wire
