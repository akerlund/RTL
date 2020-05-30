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

`ifndef IIR_BIQUAD_APB_SLAVE_ADDR_PKG
`define IIR_BIQUAD_APB_SLAVE_ADDR_PKG

package iir_biquad_apb_slave_addr_pkg;

  localparam int CR_IIR_F0_ADDR_C     = 0;
  localparam int CR_IIR_FS_ADDR_C     = 4;
  localparam int CR_IIR_Q_ADDR_C      = 8;
  localparam int CR_IIR_TYPE_ADDR_C   = 12;
  localparam int CR_IIR_BYPASS_ADDR_C = 16;

  localparam int SR_W0_ADDR_C         = 20;
  localparam int SR_ALFA_ADDR_C       = 24;
  localparam int SR_ZERO_B0_ADDR_C    = 28;
  localparam int SR_ZERO_B1_ADDR_C    = 32;
  localparam int SR_ZERO_B2_ADDR_C    = 36;
  localparam int SR_POLE_A0_ADDR_C    = 40;
  localparam int SR_POLE_A1_ADDR_C    = 44;
  localparam int SR_POLE_A2_ADDR_C    = 48;

endpackage

`endif