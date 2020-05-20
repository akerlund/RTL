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

`timescale 1ns / 1ps

module xadc_wrapper (
  input  wire         clk,
  input  wire         rst_n,
  input  wire         axis_o_tready,
  output logic [15:0] axis_o_tdata,
  output logic        axis_o_tvalid,
  output logic  [4:0] axis_o_tuser,

  // XDC Pins
  input  wire         DCLK,  // Clock input for DRP
  input  wire   [3:0] VAUXP, // Auxiliary analog channel inputs
  input  wire   [3:0] VAUXN,
  input  wire         VP,    // Dedicated and Hardwired Analog Input Pair
  input  wire         VN
);

  assign axis_o_tdata  = {4'h0, MEASURED_VCCAUX[15:4]};
  assign axis_o_tvalid = axis_o_tready;

  ug480 ug480_i0 (v
    .DCLK             ( clk              ),
    .RESET            ( ~rst_n           ),
    .VAUXP            ( VAUXP            ),
    .VAUXN            ( VAUXN            ),
    .VP               ( VP               ),
    .VN               ( VN               ),
    .MEASURED_TEMP    ( MEASURED_TEMP    ),
    .MEASURED_VCCINT  ( MEASURED_VCCINT  ),
    .MEASURED_VCCAUX  ( MEASURED_VCCAUX  ),
    .MEASURED_VCCBRAM ( MEASURED_VCCBRAM ),
    .MEASURED_AUX0    ( MEASURED_AUX0    ),
    .MEASURED_AUX1    ( MEASURED_AUX1    ),
    .MEASURED_AUX2    ( MEASURED_AUX2    ),
    .MEASURED_AUX3    ( MEASURED_AUX3    ),
    .ALM              ( ALM              ),
    .CHANNEL          ( CHANNEL          ),
    .OT               ( OT               ),
    .XADC_EOC         ( XADC_EOC         ),
    .XADC_EO          ( XADC_EO          )
   );

endmodule