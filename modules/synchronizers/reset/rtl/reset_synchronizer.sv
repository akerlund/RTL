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

// By using a wrapper around the core we will always find any instance
// of 'reset_synchronizer_core_i0' within a 'reset_synchronizer_iX'.
// Thus, we can constraint them all with, e.g.,
// set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*reset_synchronizer_core_i0/reset_origin_n.*]
// set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*io_synchronizer_core_i0/bit_egress.*]

module reset_synchronizer (
    input  wire  clk,
    input  wire  rst_async_n,
    output logic rst_sync_n
  );

  reset_synchronizer_core reset_synchronizer_core_i0 (
    .clk         ( clk         ),
    .rst_async_n ( rst_async_n ),
    .rst_sync_n  ( rst_sync_n  )
  );

endmodule

`default_nettype wire
