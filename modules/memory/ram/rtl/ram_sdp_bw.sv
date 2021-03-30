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
// Simple Dual Port (SDP) RAM:
//   * Port A is dedicated to writes
//   * Port B is dedicated to reads
// Byte Write enable (BW), data widths are parameterized as number of bytes
//
// Target Devices: Xilinx FPGA
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module ram_sdp_bw #(
    parameter int BYTE_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P = -1
  )(

    // Clock
    input  wire                         clk,

    // Port A (write port)
    input  wire                         port_a_enable,
    input  wire                         port_a_write_enable,
    input  wire    [ADDR_WIDTH_P-1 : 0] port_a_address,
    input  wire  [BYTE_WIDTH_P*8-1 : 0] port_a_data_ing,
    input  wire    [BYTE_WIDTH_P-1 : 0] port_a_write_mask,

    // Port B (read port)
    input  wire                         port_b_enable,
    input  wire    [ADDR_WIDTH_P-1 : 0] port_b_address,
    output logic [BYTE_WIDTH_P*8-1 : 0] port_b_data_egr
  );

  logic [BYTE_WIDTH_P*8-1 : 0] ram [2**ADDR_WIDTH_P-1 : 0];

  // ---------------------------------------------------------------------------
  // Port A, dedicated to writes
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk) begin

    if (port_a_enable) begin

      if (port_a_write_enable) begin

        for (int i = 0; i < BYTE_WIDTH_P; i++) begin

          if (port_a_write_mask[i]) begin
            ram[port_a_address][i*8 +: 8] <= port_a_data_ing[i*8 +: 8];
          end

        end
      end

    end
  end

  // ---------------------------------------------------------------------------
  // Port B, dedicated to reads
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk) begin

    if (port_b_enable) begin

      port_b_data_egr <= ram[port_b_address];

    end

  end

endmodule

`default_nettype wire
