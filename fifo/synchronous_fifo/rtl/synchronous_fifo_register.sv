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

module synchronous_fifo_register #(
    parameter int DATA_WIDTH_P    = -1,
    parameter int ADDRESS_WIDTH_P = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,

    input  wire                        ing_enable,
    input  wire   [DATA_WIDTH_P-1 : 0] ing_data,
    output logic                       ing_full,

    input  wire                        egr_enable,
    output logic  [DATA_WIDTH_P-1 : 0] egr_data,
    output logic                       egr_empty,

    output logic [ADDRESS_WIDTH_P : 0] sr_fill_level
  );

  logic                         write_enable;
  logic [ADDRESS_WIDTH_P-1 : 0] write_address;
  logic                         read_enable;
  logic [ADDRESS_WIDTH_P-1 : 0] read_address;

  assign write_enable = ing_enable && !ing_full;
  assign read_enable  = egr_enable  && !egr_empty;

  assign ing_full = sr_fill_level[ADDRESS_WIDTH_P];

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      write_address <= '0;
      read_address  <= '0;
      sr_fill_level <= '0;
      egr_empty <= '1;
    end
    else begin
      if (write_enable) begin
        write_address <= write_address + 1;
        if (read_enable) begin
          read_address <= read_address + 1;
        end
        else begin
          sr_fill_level <= sr_fill_level + 1;
          egr_empty <= '0;
        end
      end
      else if (read_enable) begin
        read_address  <= read_address  + 1;
        sr_fill_level <= sr_fill_level - 1;
        if (sr_fill_level == 1) begin
          egr_empty <= '1;
        end
      end
    end
  end

  fpga_reg_1c_1w_1r #(
    .DATA_WIDTH_P    ( DATA_WIDTH_P    ),
    .ADDRESS_WIDTH_P ( ADDRESS_WIDTH_P )
  ) fpga_reg_1c_1w_1r_i0 (
    .clk             ( clk             ), // input
    .port_a_write_en ( write_enable    ), // input
    .port_a_address  ( write_address   ), // input
    .port_a_data_in  ( ing_data        ), // input
    .port_b_address  ( read_address    ), // input
    .port_b_data_out ( egr_data        )  // output
  );


endmodule

`default_nettype wire
