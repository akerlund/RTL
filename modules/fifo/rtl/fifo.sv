////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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

module fifo #(
    parameter int DATA_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P = -1
  )(
    // Clock and reset
    input  wire                       clk,
    input  wire                       rst_n,

    // Ingress
    input  wire                       ing_enable,
    input  wire  [DATA_WIDTH_P-1 : 0] ing_data,
    output logic                      ing_full,
    output logic                      ing_almost_full,

    // Egress
    input  wire                       egr_enable,
    output logic [DATA_WIDTH_P-1 : 0] egr_data,
    output logic                      egr_empty,

    // Configuration and status registers
    output logic   [ADDR_WIDTH_P : 0] sr_fill_level,
    output logic   [ADDR_WIDTH_P : 0] sr_max_fill_level,
    input  wire    [ADDR_WIDTH_P : 0] cr_almost_full_level
  );

  // FPGA will use RAM if the memory is larger than 2048 bits (256 bytes)
  localparam bit GENERATE_FIFO_REG_C = DATA_WIDTH_P * 2**ADDR_WIDTH_P <= 2048 ? 1'b1 : 1'b0;

  // Maximum fill level
  localparam logic [ADDR_WIDTH_P : 0] FIFO_MAX_LEVEL_C = 2**ADDR_WIDTH_P;

  logic write_enable;
  logic read_enable;

  assign write_enable = ing_enable && (!ing_full || egr_enable);
  assign read_enable  = egr_enable && !egr_empty;

  generate

    if (GENERATE_FIFO_REG_C) begin : gen_sync_reg

      // Generate with registers
      fifo_register #(
        .DATA_WIDTH_P  ( DATA_WIDTH_P  ),
        .ADDR_WIDTH_P  ( ADDR_WIDTH_P  )
      ) fifo_register_i0 (

        // Clock and reset
        .clk           ( clk           ), // input
        .rst_n         ( rst_n         ), // input

        // Ingress
        .ing_enable    ( write_enable  ), // input
        .ing_data      ( ing_data      ), // input
        .ing_full      ( ing_full      ), // output

        // Egress
        .egr_enable    ( read_enable   ), // input
        .egr_data      ( egr_data      ), // output
        .egr_empty     ( egr_empty     ), // output

        // Status registers
        .sr_fill_level ( sr_fill_level )  // output
      );

    end
    else begin : generate_synchronous_ram_fifo

      localparam int REG_ADDR_WIDTH_C = 1;

      // Generate with RAM
      logic   [ADDR_WIDTH_P-1 : 0] ram_write_address;
      logic   [ADDR_WIDTH_P-1 : 0] ram_read_address;
      logic   [DATA_WIDTH_P-1 : 0] ram_read_data;
      logic   [ADDR_WIDTH_P   : 0] ram_fill_level;

      logic                        reg_write_enable;
      logic                        reg_full;

      assign ram_fill_level  = (ram_write_address >= ram_read_address) ?
                               {1'b0, ram_write_address} - {1'b0, ram_read_address} :
                               FIFO_MAX_LEVEL_C - ({1'b0, ram_read_address} - {1'b0, ram_write_address});

      assign ing_full        = sr_fill_level[ADDR_WIDTH_P] && !read_enable;
      assign ing_almost_full = (sr_fill_level >= cr_almost_full_level);

      // RAM read and write process
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          ram_write_address <='0;
          ram_read_address  <='0;
          reg_write_enable  <='0;
        end
        else begin

          if (write_enable) begin
            ram_write_address <= ram_write_address + 1;
          end

          // Reading from the RAM to the register FIFO
          if (ram_fill_level > 0 && (!reg_full || read_enable)) begin
            ram_read_address <= ram_read_address + 1;
            reg_write_enable <= '1;
          end else begin
            reg_write_enable <= '0;
          end
        end
      end

      // Generate the FIFO's RAM
      ram_sdp #(
        .DATA_WIDTH_P        ( DATA_WIDTH_P      ),
        .ADDR_WIDTH_P        ( ADDR_WIDTH_P      )
      ) ram_sdp_i0 (

        // Clock
        .clk                 ( clk               ), // input

        // Port A (write port)
        .port_a_enable       ( '1                ), // input
        .port_a_write_enable ( write_enable      ), // input
        .port_a_data_ing     ( ing_data          ), // input
        .port_a_address      ( ram_write_address ), // input

        // Port B (read port)
        .port_b_enable       ( '1                ), // input
        .port_b_address      ( ram_read_address  ), // input
        .port_b_data_egr     ( ram_read_data     )  // output
      );

      // Register at the output removes the delay of 1 clk period
      // it takes for RAM memories to output data
      fifo_register #(
        .DATA_WIDTH_P    ( DATA_WIDTH_P     ),
        .ADDR_WIDTH_P    ( REG_ADDR_WIDTH_C )
      ) fifo_register_i0 (

        // Clock and reset
        .clk             ( clk              ), // input
        .rst_n           ( rst_n            ), // input

        // Ingress
        .ing_enable      ( reg_write_enable ), // input
        .ing_data        ( ram_read_data    ), // input
        .ing_full        ( reg_full         ), // output

        // Egress
        .egr_enable      ( read_enable      ), // input
        .egr_data        ( egr_data         ), // output
        .egr_empty       ( egr_empty        ), // output

        // Status registers
        .sr_fill_level   (                  )  // output
      );


      // Status process
      always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          sr_fill_level     <= '0;
          sr_max_fill_level <= '0;
        end
        else begin

          // Update the FIFO's fill level
          if (read_enable && !write_enable) begin
            sr_fill_level <= sr_fill_level - 1;
          end else if (write_enable && !read_enable) begin
            sr_fill_level <= sr_fill_level + 1;
          end

          // Update the maximum fill level the FIFO has reached
          if (sr_fill_level >= sr_max_fill_level) begin
            sr_max_fill_level <= sr_fill_level;
          end
        end
      end
    end
  endgenerate

endmodule

`default_nettype wire
