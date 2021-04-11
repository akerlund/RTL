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

module cordic_radian_synth_wrapper #(
  parameter int AXI_DATA_WIDTH_P = 16,
  parameter int AXI_ID_WIDTH_P   = 3,
  parameter int NR_OF_STAGES_P   = 16
)(
  // Clock and reset
  input  wire                             clk,
  input  wire                             rst_n,

  // AXI4-S master side
  input  wire                             ing_tvalid,
  input  wire    [AXI_DATA_WIDTH_P-1 : 0] ing_tdata,
  input  wire      [AXI_ID_WIDTH_P-1 : 0] ing_tid,
  input  wire                             ing_tuser,

  // AXI4-S slave side
  output logic                            egr_tvalid,
  output logic [2*AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
  output logic     [AXI_ID_WIDTH_P-1 : 0] egr_tid
);

  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
    .NR_OF_STAGES_P   ( NR_OF_STAGES_P   )
  ) cordic_axi4s_if_i0 (
    .clk              ( clk              ),
    .rst_n            ( rst_n            ),
    .ing_tvalid       ( ing_tvalid       ),
    .ing_tdata        ( ing_tdata        ),
    .ing_tid          ( ing_tid          ),
    .ing_tuser        ( ing_tuser        ),
    .egr_tvalid       ( egr_tvalid       ),
    .egr_tdata        ( egr_tdata        ),
    .egr_tid          ( egr_tid          )
  );


endmodule

`default_nettype wire
