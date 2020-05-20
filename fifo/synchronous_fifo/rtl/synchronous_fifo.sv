////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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

module synchronous_fifo #(
    parameter int DATA_WIDTH_P    = -1,
    parameter int ADDRESS_WIDTH_P = -1
  )(
    // Clock and reset
    input  wire                        clk,
    input  wire                        rst_n,

    // Write port
    input  wire                        wp_write_enable,
    input  wire   [DATA_WIDTH_P-1 : 0] wp_data,
    output logic                       wp_fifo_full,

    // Read port
    input  wire                        rp_read_enable,
    output logic  [DATA_WIDTH_P-1 : 0] rp_data,
    output logic                       rp_fifo_empty,

    // Configuration and status registers
    output logic [ADDRESS_WIDTH_P : 0] sr_fill_level,
    output logic [ADDRESS_WIDTH_P : 0] sr_max_fill_level,
    input  wire  [ADDRESS_WIDTH_P : 0] cr_almost_full_level
  );

  // FPGA will use RAM if the memory is larger than 2048 bits
  localparam bit GENERATE_FIFO_REG_C = DATA_WIDTH_P * 2**ADDRESS_WIDTH_P <= 2048 ? 1'b1 : 1'b0;

  // Maximum fill level
  localparam logic [ADDRESS_WIDTH_P : 0] FIFO_MAX_LEVEL_C = 2**ADDRESS_WIDTH_P - 1;

  logic                         write_enable;
  logic [ADDRESS_WIDTH_P-1 : 0] write_address;
  logic                         read_enable;
  logic [ADDRESS_WIDTH_P-1 : 0] read_address;

  assign write_enable = wp_write_enable && (!wp_fifo_full || rp_read_enable);
  assign read_enable  = rp_read_enable  && !rp_fifo_empty;

  generate

    if (GENERATE_FIFO_REG_C) begin : gen_sync_reg

      // Generate with registers
      synchronous_fifo_register #(
        .DATA_WIDTH_P    ( DATA_WIDTH_P    ),
        .ADDRESS_WIDTH_P ( ADDRESS_WIDTH_P )
      ) synchronous_fifo_register_i0 (

        // Clock and reset
        .clk             ( clk             ),
        .rst_n           ( rst_n           ),

        // Write port
        .wp_write_enable ( write_enable    ),
        .wp_data         ( wp_data         ),
        .wp_fifo_full    (                 ),

        // Read port
        .rp_read_enable  ( read_enable     ),
        .rp_data         ( rp_data         ),
        .rp_fifo_empty   ( rp_fifo_empty   ),

        // Status registers
        .sr_fill_level   (                 )
      );

    end
    else begin : generate_synchronous_ram_fifo

      // Generate with RAM
      logic [ADDRESS_WIDTH_P-1 : 0] ram_write_address;
      logic [ADDRESS_WIDTH_P-1 : 0] ram_read_address;
      logic    [DATA_WIDTH_P-1 : 0] ram_read_data;
      logic [ADDRESS_WIDTH_P-1 : 0] ram_fill_level;

      logic                         reg_write_enable;
      logic                 [2 : 0] reg_fill_level;

      assign ram_fill_level = ram_write_address >= ram_read_address ?
                              {1'b0, ram_write_address} - {1'b0, ram_read_address} :
                              FIFO_MAX_LEVEL_C - ({1'b0, ram_read_address} - {1'b0, ram_write_address});

      // RAM read and write process
      always_ff @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          ram_write_address <='0;
          ram_read_address  <='0;
          reg_write_enable  <='0;
        end
        else begin
          if (write_enable) begin
            ram_write_address <= ram_write_address + 1;
          end
          if (ram_fill_level > 0 && (reg_fill_level < 3 || read_enable)) begin
            ram_read_address <= ram_read_address + 1;
            reg_write_enable <= '1;
          end
          else begin
            reg_write_enable <= '0;
          end
        end
      end

      // Generate the FIFO's RAM
      fpga_ram_1c_1w_1r #(
        .DATA_WIDTH_P    ( DATA_WIDTH_P      ),
        .ADDRESS_WIDTH_P ( ADDRESS_WIDTH_P   )
      ) fpga_ram_1c_1w_1r_i0 (

        // Clock
        .clk             ( clk               ),

        // Port A
        .port_a_write_en ( write_enable      ),
        .port_a_address  ( ram_write_address ),
        .port_a_data_in  ( wp_data           ),

        // Port B
        .port_b_address  ( ram_read_address  ),
        .port_b_data_out ( ram_read_data     )
      );

      // Register at the output removes the delay of 1 clk period
      // it takes for RAM memories to output data
      synchronous_fifo_register #(
        .DATA_WIDTH_P    ( DATA_WIDTH_P     ),
        .ADDRESS_WIDTH_P ( 2                )
      ) synchronous_fifo_register_i0 (

        // Clock and reset
        .clk             ( clk              ),
        .rst_n           ( rst_n            ),

        // Write port
        .wp_write_enable ( reg_write_enable ),
        .wp_data         ( ram_read_data    ),
        .wp_fifo_full    (                  ),

        // Read port
        .rp_read_enable  ( read_enable      ),
        .rp_data         ( rp_data          ),
        .rp_fifo_empty   ( rp_fifo_empty    ),

        // Status registers
        .sr_fill_level   ( reg_fill_level   )
      );
    end
  endgenerate

  // Status process
  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      wp_fifo_full        <= '0;
      wp_fifo_almost_full <= '0;
      sr_fill_level       <= '0;
      sr_max_fill_level   <= '0;

    end
    else begin

      // Determine if the FIFO is full
      if (sr_fill_level >= FIFO_MAX_LEVEL_C) begin
        wp_fifo_full <= '1;
      end
      else begin
        wp_fifo_full <= '0;
      end

      // Determine if the FIFO is almost full
      if (sr_fill_level >= cr_almost_full_level) begin
        wp_fifo_almost_full <= '1;
      end
      else begin
        wp_fifo_almost_full <= '0;
      end

      // Update the FIFO's fill level
      if (read_enable && !write_enable) begin
        sr_fill_level <= sr_fill_level - 1;
      end
      else if (write_enable && !read_enable) begin
        sr_fill_level <= sr_fill_level + 1;
      end

      // Update the maximum fill level the FIFO has reached
      if (sr_fill_level >= sr_max_fill_level) begin
        sr_max_fill_level <= sr_fill_level;
      end

    end
  end

endmodule

`default_nettype wire
