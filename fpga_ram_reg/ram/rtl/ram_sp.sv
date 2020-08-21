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
// Single Port (SP) RAM
//
// Target Devices: Xilinx FPGA
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

 module ram_sp #(
    parameter int DATA_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P = -1
  )(
    input  wire                       clk,
    input  wire                       enable,
    input  wire                       write_enable,
    input  wire  [DATA_WIDTH_P-1 : 0] data_ingress,
    input  wire  [ADDR_WIDTH_P-1 : 0] address,
    output logic [DATA_WIDTH_P-1 : 0] data_egress
  );

  logic [DATA_WIDTH_P-1 : 0] ram_memory [2**ADDR_WIDTH_P-1 : 0];

  always_ff @(posedge clk) begin

    if (enable) begin

      data_egress <= ram_memory[address];

      if (write_enable) begin
        ram_memory[address] <= data_ingress;
      end

    end

  end

endmodule

`default_nettype wire
