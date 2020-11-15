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

`include "uvm_macros.svh"
import uvm_pkg::*;

import oscillator_types_pkg::*;
import vip_apb3_types_pkg::*;

`include "clock_enable.sv"
`include "clock_enable_scaler.sv"
`include "delay_enable.sv"
`include "frequency_enable.sv"

`include "osc_square_core.sv"
`include "osc_square_top.sv"
`include "osc_triangle_core.sv"
`include "osc_triangle_top.sv"
`include "osc_saw_core.sv"
`include "osc_saw_top.sv"
`include "osc_sin_top.sv"
`include "oscillator_apb_slave.sv"
`include "oscillator_core.sv"
`include "oscillator_top.sv"

`include "long_division_core.sv"
`include "long_division_axi4s_if.sv"

`include "cordic_radian_core.sv"
`include "cordic_radian_top.sv"
`include "cordic_axi4s_if.sv"

`include "mixer.sv"
