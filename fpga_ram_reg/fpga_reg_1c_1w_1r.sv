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

module fpga_reg_1c_1w_1r #(
    parameter int DATA_WIDTH_P    = -1,
    parameter int ADDRESS_WIDTH_P = -1
  )(
    input  wire                          clk,

    input  wire                          port_a_write_en,
    input  wire  [ADDRESS_WIDTH_P-1 : 0] port_a_address,
    input  wire     [DATA_WIDTH_P-1 : 0] port_a_data_in,

    input  wire  [ADDRESS_WIDTH_P-1 : 0] port_b_address,
    output logic    [DATA_WIDTH_P-1 : 0] port_b_data_out
  );

  logic [DATA_WIDTH_P-1 : 0] fpga_reg [2**ADDRESS_WIDTH_P-1 : 0];

  assign port_b_data_out = fpga_reg[port_b_address];

  always_ff @ (posedge clk) begin
    if (port_a_write_en) begin
      fpga_reg[port_a_address] <= port_a_data_in;
    end
  end

endmodule

`default_nettype wire