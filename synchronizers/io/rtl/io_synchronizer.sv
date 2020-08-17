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

// By using a wrapper around the core we will always find any instance
// of 'io_synchronizer_core_i0' within a 'io_synchronizerX'.
// Thus, we can constraint them all with, e.g.,
// set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*io_synchronizer_core_i0/bit_egress.*]

module io_synchronizer (
    input  wire  clk,
    input  wire  rst_n,
    input  wire  bit_ingress,
    output logic bit_egress
  );

  io_synchronizer_core io_synchronizer_core_i0 (
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .bit_ingress ( bit_ingress ),
    .bit_egress  ( bit_egress  )
  );

endmodule

`default_nettype wire
