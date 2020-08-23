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
//   - True Dual Port RAM, both ports can read and write
//   - Memory collisions are enabled in simulations, outputs will be set to X
//
// Target Devices: Xilinx FPGA
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module ram_tdp #(
    parameter int DATA_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P = -1
  )(
    // Clock
    input  wire                       clk,

    // Port A
    input  wire                       port_a_enable,
    input  wire                       port_a_write_enable,
    input  wire  [ADDR_WIDTH_P-1 : 0] port_a_address,
    input  wire  [DATA_WIDTH_P-1 : 0] port_a_data_ing,
    output logic [DATA_WIDTH_P-1 : 0] port_a_data_egr,

    // Port B
    input  wire                       port_b_enable,
    input  wire                       port_b_write_enable,
    input  wire  [ADDR_WIDTH_P-1 : 0] port_b_address,
    input  wire  [DATA_WIDTH_P-1 : 0] port_b_data_ing,
    output logic [DATA_WIDTH_P-1 : 0] port_b_data_egr
  );

  logic [DATA_WIDTH_P-1 : 0] ram [2**ADDR_WIDTH_P-1 : 0];


  // Port A
  always_ff @(posedge clk) begin

    if (port_a_enable) begin

      port_a_data_egr <= ram[port_a_address];

      if (port_a_write_enable) begin
        ram[port_a_address] <= port_a_data_ing;
      end

      // synthesis translate_off
      if (port_b_write_enable && port_a_write_enable && (port_a_address == port_b_address)) begin
        port_a_data_egr <= {DATA_WIDTH_P{1'bx}};
      end
      // synthesis translate_on

    end

  end


  // Port B
  always_ff @(posedge clk) begin

    if (port_b_enable) begin

      port_b_data_egr <= ram[port_b_address];

      if (port_b_write_enable) begin
        ram[port_b_address] <= port_b_data_ing;
      end

      // synthesis translate_off
      if (port_a_write_enable && port_b_write_enable && (port_a_address == port_b_address)) begin
        port_b_data_egr <= {DATA_WIDTH_P{1'bx}};
      end
      // synthesis translate_on

    end

  end

endmodule

`default_nettype wire
