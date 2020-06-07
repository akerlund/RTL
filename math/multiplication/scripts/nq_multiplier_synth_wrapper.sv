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

`default_nettype none

module nq_multiplier_synth_wrapper #(
  parameter int AXI_DATA_WIDTH_P = 32,
  parameter int AXI_ID_WIDTH_P   = 1,
  parameter int N_BITS_P         = 32,
  parameter int Q_BITS_P         = 15
)(
  // Clock and reset
  input  wire                           clk,
  input  wire                           rst_n,

  // AXI4-S master side
  input  wire                           ing_tvalid,
  output logic                          ing_tready,
  input  wire  [AXI_DATA_WIDTH_P-1 : 0] ing_tdata,
  input  wire                           ing_tlast,
  input  wire    [AXI_ID_WIDTH_P-1 : 0] ing_tid,

  // AXI4-S slave side
  output logic                          egr_tvalid,
  output logic [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
  output logic                          egr_tlast,
  output logic   [AXI_ID_WIDTH_P-1 : 0] egr_tid,
  output logic                          egr_tuser
);

nq_multiplier_axi4s_if #(
  .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
  .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
  .N_BITS_P         ( N_BITS_P         ),
  .Q_BITS_P         ( Q_BITS_P         )
) nq_multiplier_axi4s_if_i0 (
  .clk              ( clk              ),
  .rst_n            ( rst_n            ),

  .ing_tvalid       ( ing_tvalid       ),
  .ing_tready       ( ing_tready       ),
  .ing_tdata        ( ing_tdata        ),
  .ing_tlast        ( ing_tlast        ),
  .ing_tid          ( ing_tid          ),

  .egr_tvalid       ( egr_tvalid       ),
  .egr_tdata        ( egr_tdata        ),
  .egr_tlast        ( egr_tlast        ),
  .egr_tid          ( egr_tid          ),
  .egr_tuser        ( egr_tuser        )
);


endmodule

`default_nettype wire
