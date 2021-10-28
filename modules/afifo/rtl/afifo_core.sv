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
// Simulation and Synthesis Techniques for Asynchronous FIFO Design
// http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf
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
    output logic                      rclk_empty,

    output logic   [ADDR_WIDTH_P : 0] sr_wclk_fill_level,
    output logic   [ADDR_WIDTH_P : 0] sr_rclk_fill_level
  );

  logic                      wclk_rst_n;
  logic                      wclk_rclk_rst_n;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_bin;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_bin_next;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_gray;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_gray_next;
  logic [ADDR_WIDTH_P-1 : 0] wclk_wr_addr;
  logic                      wclk_full_next;
  logic   [ADDR_WIDTH_P : 0] wclk_rd_gray;
  logic   [ADDR_WIDTH_P : 0] wclk_rd_bin;
  logic                      wclk_mem_wr_en;

  logic                      rclk_rst_n;
  logic                      rclk_wclk_rst_n;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_bin;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_bin_next;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_gray;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_gray_next;
  logic [ADDR_WIDTH_P-1 : 0] rclk_rd_addr;
  logic                      rclk_empty_next;
  logic   [ADDR_WIDTH_P : 0] rclk_wr_gray;
  logic   [ADDR_WIDTH_P : 0] rclk_wr_bin;

  // ---------------------------------------------------------------------------
  // Write logic
  // ---------------------------------------------------------------------------

  assign wclk_wr_bin_next  = wclk_wr_bin + {{ADDR_WIDTH_P{1'b0}}, wclk_wr_en && !wclk_full};
  assign wclk_wr_gray_next = (wclk_wr_bin_next >> 1) ^ wclk_wr_bin_next;
  assign wclk_full_next    = wclk_wr_gray_next == {~wclk_rd_gray[ADDR_WIDTH_P : ADDR_WIDTH_P-1], wclk_rd_gray[ADDR_WIDTH_P-2 : 0]};
  assign wclk_wr_addr      = wclk_wr_bin[ADDR_WIDTH_P-1 : 0];
  assign wclk_mem_wr_en    = wclk_wr_en && !wclk_full;


  always_ff @(posedge wclk or negedge rst_w_n) begin
    if (!rst_w_n) begin
      wclk_rst_n   <= '0;
      wclk_full    <= '1;
      wclk_wr_bin  <= '0;
      wclk_wr_gray <= '0;
    end else begin
      wclk_rst_n <= '1;
      if (wclk_rclk_rst_n) begin
        wclk_wr_bin  <= wclk_wr_bin_next;
        wclk_wr_gray <= wclk_wr_gray_next;
        wclk_full    <= wclk_full_next;
      end
    end
  end


  always_ff @(posedge wclk or negedge rst_w_n) begin
    if (!rst_w_n) begin
      sr_wclk_fill_level <= '0;
    end else begin
      if (wclk_wr_bin >= wclk_rd_bin) begin
        sr_wclk_fill_level <= wclk_wr_bin - wclk_rd_bin;
      end
      //else begin
      //  sr_wclk_fill_level <= 2**ADDR_WIDTH_P - wclk_rd_bin - wclk_wr_bin;
      //end
    end
  end


  // ---------------------------------------------------------------------------
  // Read logic
  // ---------------------------------------------------------------------------

  assign rclk_rd_bin_next  = rclk_rd_bin + {{ADDR_WIDTH_P{1'b0}}, rclk_rd_en && !rclk_empty};
  assign rclk_rd_gray_next = (rclk_rd_bin_next >> 1) ^ rclk_rd_bin_next;
  assign rclk_rd_addr      = rclk_rd_bin[ADDR_WIDTH_P-1 : 0];
  assign rclk_empty_next   = (rclk_rd_gray_next == rclk_wr_gray);


  always_ff @(posedge rclk or negedge rst_r_n) begin
    if (!rst_r_n) begin
      rclk_rst_n   <= '0;
      rclk_empty   <= '1;
      rclk_rd_bin  <= '0;
      rclk_rd_gray <= '0;
    end else begin
      rclk_rst_n <= '1;
      if (rclk_wclk_rst_n) begin
        rclk_rd_bin  <= rclk_rd_bin_next;
        rclk_rd_gray <= rclk_rd_gray_next;
        rclk_empty   <= rclk_empty_next;
      end
    end
  end


  always_ff @(posedge rclk or negedge rst_r_n) begin
    if (!rst_r_n) begin
      sr_rclk_fill_level <= '0;
    end else begin
      if (rclk_wr_bin >= rclk_rd_bin) begin
        sr_rclk_fill_level <= rclk_wr_bin - rclk_rd_bin;
      end
      // else begin
      //  sr_rclk_fill_level <= 2**ADDR_WIDTH_P - rclk_rd_bin - rclk_wr_bin;
      //end
    end
  end


  ram_sdp2c #(
    .DATA_WIDTH_P        ( DATA_WIDTH_P   ),
    .ADDR_WIDTH_P        ( ADDR_WIDTH_P   )
  ) ram_sdp2c_i0 (
    .clk_a               ( wclk           ),
    .port_a_enable       ( '1             ),
    .port_a_write_enable ( wclk_mem_wr_en ),
    .port_a_address      ( wclk_wr_addr   ),
    .port_a_data_ing     ( wclk_data      ),
    .clk_b               ( rclk           ),
    .port_b_enable       ( '1             ),
    .port_b_address      ( rclk_rd_addr   ),
    .port_b_data_egr     ( rclk_data      )
  );


  cdc_bit_sync cdc_bit_sync_i0 (
    .clk_src   ( wclk            ),
    .rst_src_n ( rst_w_n         ),
    .clk_dst   ( rclk            ),
    .rst_dst_n ( rst_r_n         ),
    .src_bit   ( wclk_rst_n      ),
    .dst_bit   ( rclk_wclk_rst_n )
  );


  cdc_bit_sync cdc_bit_sync_i1 (
    .clk_src   ( rclk            ),
    .rst_src_n ( rst_r_n         ),
    .clk_dst   ( wclk            ),
    .rst_dst_n ( rst_w_n         ),
    .src_bit   ( rclk_rst_n      ),
    .dst_bit   ( wclk_rclk_rst_n )
  );


  gray_to_bin #(
    .WIDTH_P ( ADDR_WIDTH_P+1 )
  ) gray_to_bin_i0 (
    .gray    ( wclk_rd_gray   ),
    .bin     ( wclk_rd_bin    )
  );


  gray_to_bin #(
    .WIDTH_P ( ADDR_WIDTH_P+1 )
  ) gray_to_bin_i1 (
    .gray    ( rclk_wr_gray   ),
    .bin     ( rclk_wr_bin    )
  );

  genvar i;

  // Write pointer, wclk to rclk
  generate
    for (i = 0; i <= ADDR_WIDTH_P; i++) begin
      cdc_bit_sync cdc_bit_sync_i (
        .clk_src   ( wclk            ),
        .rst_src_n ( rst_w_n         ),
        .clk_dst   ( rclk            ),
        .rst_dst_n ( rst_r_n         ),
        .src_bit   ( wclk_wr_gray[i] ),
        .dst_bit   ( rclk_wr_gray[i] )
      );
    end
  endgenerate

  // Read pointer, rclk to wclk
  generate
    for (i = 0; i <= ADDR_WIDTH_P; i++) begin
      cdc_bit_sync cdc_bit_sync_i (
        .clk_src   ( rclk            ),
        .rst_src_n ( rst_r_n         ),
        .clk_dst   ( wclk            ),
        .rst_dst_n ( rst_w_n         ),
        .src_bit   ( rclk_rd_gray[i] ),
        .dst_bit   ( wclk_rd_gray[i] )
      );
    end
  endgenerate

endmodule

`default_nettype wire
