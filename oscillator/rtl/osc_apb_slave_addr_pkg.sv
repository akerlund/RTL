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

`ifndef OSC_APB_SLAVE_ADDR_PKG
`define OSC_APB_SLAVE_ADDR_PKG

package osc_apb_slave_addr_pkg;

  localparam int CR_OSC_WAVEFORM_SELECT_ADDR_C = 0;
  localparam int CR_OSC_FREQUENCY_ADDR_C       = 4;
  localparam int CR_OSC_DUTY_CYCLE_ADDR_C      = 8;

endpackage

`endif