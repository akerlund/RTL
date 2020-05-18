////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`ifndef CORDIC_ATAN_TABLE_PKG
`define CORDIC_ATAN_TABLE_PKG

package cordic_atan_table_pkg;

  // Generate table of atan values
  logic signed [31 : 0] atan_table_31x32bit [0 : 30] = {
    32'b00100000000000000000000000000000, // 45.000 degrees -> atan(2^0)
    32'b00010010111001000000010100011101, // 26.565 degrees -> atan(2^-1)
    32'b00001001111110110011100001011011, // 14.036 degrees -> atan(2^-2)
    32'b00000101000100010001000111010100, // atan(2^-3)
    32'b00000010100010110000110101000011,
    32'b00000001010001011101011111100001,
    32'b00000000101000101111011000011110,
    32'b00000000010100010111110001010101,
    32'b00000000001010001011111001010011,
    32'b00000000000101000101111100101110,
    32'b00000000000010100010111110011000,
    32'b00000000000001010001011111001100,
    32'b00000000000000101000101111100110,
    32'b00000000000000010100010111110011,
    32'b00000000000000001010001011111001,
    32'b00000000000000000101000101111100,
    32'b00000000000000000010100010111110,
    32'b00000000000000000001010001011111,
    32'b00000000000000000000101000101111,
    32'b00000000000000000000010100010111,
    32'b00000000000000000000001010001011,
    32'b00000000000000000000000101000101,
    32'b00000000000000000000000010100010,
    32'b00000000000000000000000001010001,
    32'b00000000000000000000000000101000,
    32'b00000000000000000000000000010100,
    32'b00000000000000000000000000001010,
    32'b00000000000000000000000000000101,
    32'b00000000000000000000000000000010,
    32'b00000000000000000000000000000001,
    32'b00000000000000000000000000000000
  };

endpackage

`endif
