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
// of 'cdc_bit_sync_core_i0' within a 'cdc_bit_sync_iX'.
// Thus, we can constraint them all with, e.g.,
// set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*cdc_bit_sync_core_i0/dst_bit.*]

module cdc_bit_sync (

    input  wire  clk_src,
    input  wire  rst_src_n,
    input  wire  clk_dst,
    input  wire  rst_dst_n,
    input  wire  src_bit,
    output logic dst_bit
  );

  cdc_bit_sync_core cdc_bit_sync_core_i0 (

    .clk_src   ( clk_src   ),
    .rst_src_n ( rst_src_n ),
    .clk_dst   ( clk_dst   ),
    .rst_dst_n ( rst_dst_n ),
    .src_bit   ( src_bit   ),
    .dst_bit   ( dst_bit   )
  );

endmodule

`default_nettype wire
