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

`ifndef OSCILLATOR_TYPES_PKG
`define OSCILLATOR_TYPES_PKG

package oscillator_types_pkg;

  typedef enum logic [1 : 0] {
    OSC_SQUARE_E,
    OSC_TRIANGLE_E,
    OSC_SAW_E,
    OSC_SINE_E
  } osc_waveform_type_t;

endpackage

`endif
