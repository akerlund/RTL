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

`ifndef OSC_ADDRESS_PKG
`define OSC_ADDRESS_PKG

package osc_address_pkg;

  localparam logic [15 : 0] OSC_HIGH_ADDRESS         = 16'h0018;
  localparam logic [15 : 0] OSC_WAVEFORM_SELECT_ADDR = 16'h0000;
  localparam logic [15 : 0] OSC_FREQUENCY_ADDR       = 16'h0008;
  localparam logic [15 : 0] OSC_DUTY_CYCLE_ADDR      = 16'h0010;

endpackage

`endif
