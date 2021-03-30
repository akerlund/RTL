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

module reset_synchronizer_core (
    input  wire  clk,
    input  wire  rst_async_n,
    output logic rst_sync_n
  );

  logic io_synchronized_rst;
  logic reset_origin_n;

  assign rst_sync_n = reset_origin_n;

  io_synchronizer io_synchronizer_i0 (
    .clk         ( clk                 ),
    .rst_n       ( rst_async_n         ),
    .bit_ingress ( 1'b1                ),
    .bit_egress  ( io_synchronized_rst )
  );

  always_ff @ (posedge clk or negedge rst_async_n) begin
    if (!rst_async_n) begin
      reset_origin_n <= '0;
    end
    else begin
      reset_origin_n <= io_synchronized_rst;
    end
  end

endmodule

`default_nettype wire
