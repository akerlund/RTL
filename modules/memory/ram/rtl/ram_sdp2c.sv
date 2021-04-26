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
// Simple Dual Port (SDP) RAM, 2 clocks:
//   * Port A is dedicated to writes
//   * Port B is dedicated to reads
//
// Target Devices: Xilinx FPGA
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module ram_sdp2c #(
    parameter int DATA_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P = -1
  )(
    input  wire                       clk_a,
    input  wire                       port_a_enable,
    input  wire                       port_a_write_enable,
    input  wire  [ADDR_WIDTH_P-1 : 0] port_a_address,
    input  wire  [DATA_WIDTH_P-1 : 0] port_a_data_ing,

    input  wire                       clk_b,
    input  wire                       port_b_enable,
    input  wire  [ADDR_WIDTH_P-1 : 0] port_b_address,
    output logic [DATA_WIDTH_P-1 : 0] port_b_data_egr
  );

  logic [DATA_WIDTH_P-1 : 0] ram_memory [2**ADDR_WIDTH_P-1 : 0];

  always_ff @ (posedge clk_a) begin
    if (port_a_enable) begin
      if (port_a_write_enable) begin
        ram_memory[port_a_address] <= port_a_data_ing;
      end
    end
  end

  always_ff @ (posedge clk_b) begin
    if (port_b_enable) begin
      port_b_data_egr <= ram_memory[port_b_address];
    end

    // synthesis translate_off
    if (port_a_enable && (port_a_address == port_b_address)) begin
      port_b_data_egr <= {DATA_WIDTH_P{1'bx}};
    end
    // synthesis translate_on
  end

endmodule

`default_nettype wire
