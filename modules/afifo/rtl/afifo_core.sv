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

    output logic                      sr_wp_fifo_active,
    output logic   [ADDR_WIDTH_P : 0] sr_wp_fill_level,
    output logic   [ADDR_WIDTH_P : 0] sr_wp_max_fill_level,

    output logic                      sr_rp_fifo_active,
    output logic   [ADDR_WIDTH_P : 0] sr_rp_fill_level
  );

  function logic [DATA_WIDTH_P-1 : 0] binary_to_gray (input logic [DATA_WIDTH_P-1 : 0] binary);
    binary_to_gray[DATA_WIDTH_P-1] = binary[DATA_WIDTH_P-1];
    for (int i = DATA_WIDTH_P-1; i > 0; i = i - 1) begin
      binary_to_gray[i-1] = binary[i] ^ binary[i-1];
    end
  endfunction

  function logic [DATA_WIDTH_P-1 : 0] gray_to_binary (input logic [DATA_WIDTH_P-1 : 0] gray);
    for (int i = 0; i < DATA_WIDTH_P; i = i + 1) begin
      gray_to_binary[i] = gray[i] ^ gray[i-1];
    end
  endfunction

  localparam logic [ADDR_WIDTH_P : 0] FIFO_MAX_LEVEL_C = 2**ADDR_WIDTH_P;

  // Write port signals
  logic                      wp_wp_under_reset_n;
  logic                      wp_rp_under_reset_n;
  logic   [ADDR_WIDTH_P : 0] wp_write_pointer_binary;
  logic   [ADDR_WIDTH_P : 0] wp_write_pointer_gray;
  logic   [ADDR_WIDTH_P : 0] wp_read_pointer_gray;

  // Read port signals
  logic                      rp_rp_under_reset_n;
  logic                      rp_wp_under_reset_n;
  logic   [ADDR_WIDTH_P : 0] rp_read_pointer_binary;
  logic   [ADDR_WIDTH_P : 0] rp_read_pointer_gray;
  logic   [ADDR_WIDTH_P : 0] rp_write_pointer_gray;
  logic                      rp_fifo_empty;

  // RAM signals
  logic [ADDR_WIDTH_P-1 : 0] ram_write_address;
  logic                      ram_write_enable;
  logic [ADDR_WIDTH_P-1 : 0] ram_read_address;

  assign ram_write_enable = wp_write_en && !wp_fifo_full;

  // Write process
  always_ff @ (posedge clk_wp or negedge rst_wp_n) begin
    if (!rst_wp_n) begin
      wp_wp_under_reset_n     <= '0;
      wp_write_pointer_binary <= '0;
      wp_write_pointer_gray   <= '0;
      ram_write_address       <= '0;
      wp_fifo_full            <= '0;
      sr_wp_fifo_active       <= '0;
      sr_wp_fill_level        <= '0;
      sr_wp_max_fill_level    <= '0;
    end
    else begin

      wp_wp_under_reset_n <= 1;

      // Synchronized reset
      if (wp_wp_under_reset_n && wp_rp_under_reset_n) begin

        sr_wp_fifo_active <= '1;

        // Increasing pointers
        if (ram_write_enable) begin
          wp_write_pointer_binary <= wp_write_pointer_binary + 1;
          wp_write_pointer_gray   <= binary_to_gray(wp_write_pointer_binary);
        end

        // Assigning RAM address
        ram_write_address <= wp_write_pointer_binary[ADDR_WIDTH_P-1 : 0];

        // Setting output 'wp_fifo_full'
        if (!wp_write_pointer_gray[ADDR_WIDTH_P : ADDR_WIDTH_P-1] &&
            wp_write_pointer_gray[ADDR_WIDTH_P-2 : 0] == wp_read_pointer_gray[ADDR_WIDTH_P-2 : 0]) begin
          wp_fifo_full <= '1;
        end
        else begin
          wp_fifo_full <= '0;
        end


        sr_wp_fill_level <= wp_write_pointer_binary - gray_to_binary(wp_read_pointer_gray);

        if (sr_wp_fill_level >= sr_wp_max_fill_level) begin
          sr_wp_max_fill_level <= sr_wp_fill_level;
        end

      end
    end
  end


  // Read process
  always_ff @ (posedge clk_wp or negedge rst_wp_n) begin
    if (!rst_wp_n) begin
      rp_rp_under_reset_n    <= '0;
      rp_read_pointer_binary <= '0;
      rp_read_pointer_gray   <= '0;
      ram_read_address       <= '0;
      rp_valid               <= '0;
      rp_fifo_empty          <= '0;
      sr_rp_fifo_active      <= '0;
      sr_rp_fill_level       <= '0;
    end
    else begin

      rp_rp_under_reset_n <= 1;

      if (rp_rp_under_reset_n && rp_wp_under_reset_n) begin // Synchronized reset

        sr_rp_fifo_active <= 1;

        if (rp_read_en && !rp_fifo_empty) begin
          rp_read_pointer_binary <= rp_read_pointer_binary + 1;
          rp_read_pointer_gray   <= binary_to_gray(rp_read_pointer_binary);
        end

        ram_read_address <= rp_read_pointer_binary[ADDR_WIDTH_P-1 : 0];

        if (rp_read_en && !rp_fifo_empty) begin
          rp_valid <= '1;
        end
        else begin
          rp_valid <= '0;
        end


        if (rp_read_pointer_gray == rp_write_pointer_gray) begin
          rp_fifo_empty <= '1;
        end
        else begin
          rp_fifo_empty <= '0;
        end

        // Calculate fill level
        sr_rp_fill_level <= gray_to_binary(rp_write_pointer_gray) - rp_read_pointer_gray;

      end
    end
  end


  ram_sdp2c #(
    .DATA_WIDTH_P        ( DATA_WIDTH_P      ),
    .ADDR_WIDTH_P        ( ADDR_WIDTH_P      )
  ) ram_sdp2c_i0 (
    .clk_a               ( clk_wp            ),
    .port_a_enable       ( '1                ),
    .port_a_write_enable ( ram_write_enable  ),
    .port_a_address      ( ram_write_address ),
    .port_a_data_ing     ( wp_data_in        ),
    .clk_b               ( clk_rp            ),
    .port_b_enable       ( '1                ),
    .port_b_address      ( ram_read_address  ),
    .port_b_data_egr     ( rp_data_out       )
  );


  cdc_bit_sync cdc_bit_sync_i0 (
    .clk_src   ( clk_wp              ),
    .rst_src_n ( rst_wp_n            ),
    .clk_dst   ( clk_rp              ),
    .rst_dst_n ( rst_rp_n            ),
    .src_bit   ( wp_wp_under_reset_n ),
    .dst_bit   ( rp_wp_under_reset_n )
  );


  cdc_bit_sync cdc_bit_sync_i1 (
    .clk_src   ( clk_rp              ),
    .rst_src_n ( rst_rp_n            ),
    .clk_dst   ( clk_wp              ),
    .rst_dst_n ( rst_wp_n            ),
    .src_bit   ( rp_rp_under_reset_n ),
    .dst_bit   ( wp_rp_under_reset_n )
  );

  // Read pointer, clk_rp to clk_wp
  genvar i;
  generate
    for (i = 0; i < ADDR_WIDTH_P; i++) begin
      cdc_bit_sync cdc_bit_sync_i (
        .clk_src   ( clk_rp                  ),
        .rst_src_n ( rst_rp_n                ),
        .clk_dst   ( clk_wp                  ),
        .rst_dst_n ( rst_wp_n                ),
        .src_bit   ( rp_read_pointer_gray[i] ),
        .dst_bit   ( wp_read_pointer_gray[i] )
      );
    end
  endgenerate

  // Write pointer, clk_wp to clk_rp
  generate
    for (i = 0; i < ADDR_WIDTH_P; i++) begin
      cdc_bit_sync cdc_bit_sync_i (
        .clk_src   ( clk_wp                   ),
        .rst_src_n ( rst_wp_n                 ),
        .clk_dst   ( clk_rp                   ),
        .rst_dst_n ( rst_rp_n                 ),
        .src_bit   ( wp_write_pointer_gray[i] ),
        .dst_bit   ( rp_write_pointer_gray[i] )
      );
    end
  endgenerate

endmodule

`default_nettype wire
