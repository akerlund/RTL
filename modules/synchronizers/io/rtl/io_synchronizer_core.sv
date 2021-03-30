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

module io_synchronizer_core (
    input  wire  clk,
    input  wire  rst_n,
    input  wire  bit_ingress,
    output logic bit_egress
  );

  logic bit_meta;

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_meta   <= '0;
      bit_egress <= '0;
    end
    else begin
      bit_meta   <= bit_ingress;
      bit_egress <= bit_meta;
    end
  end

endmodule

`default_nettype wire
