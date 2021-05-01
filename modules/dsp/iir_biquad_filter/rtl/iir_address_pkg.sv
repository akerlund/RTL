////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/PYRG
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

`ifndef IIR_ADDRESS_PKG
`define IIR_ADDRESS_PKG

package iir_address_pkg;

  localparam logic [15 : 0] IIR_HIGH_ADDRESS = 16'h0068;
  localparam logic [15 : 0] IIR_F0_ADDR     = 16'h0000;
  localparam logic [15 : 0] IIR_FS_ADDR     = 16'h0008;
  localparam logic [15 : 0] IIR_Q_ADDR      = 16'h0010;
  localparam logic [15 : 0] IIR_TYPE_ADDR   = 16'h0018;
  localparam logic [15 : 0] IIR_BYPASS_ADDR = 16'h0020;
  localparam logic [15 : 0] IIR_W0_ADDR     = 16'h0028;
  localparam logic [15 : 0] IIR_ALFA_ADDR   = 16'h0030;
  localparam logic [15 : 0] IIR_B0_ADDR     = 16'h0038;
  localparam logic [15 : 0] IIR_B1_ADDR     = 16'h0040;
  localparam logic [15 : 0] IIR_B2_ADDR     = 16'h0048;
  localparam logic [15 : 0] IIR_10_ADDR     = 16'h0050;
  localparam logic [15 : 0] IIR_11_ADDR     = 16'h0058;
  localparam logic [15 : 0] IIR_12_ADDR     = 16'h0060;

endpackage

`endif
