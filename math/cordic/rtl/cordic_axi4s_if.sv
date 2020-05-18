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

`default_nettype none

module cordic_axi4s_if #(
    parameter int AXI_DATA_WIDTH_P    = 16,
    parameter int AXI_ID_WIDTH_P      = 16,
    parameter int CORDIC_DATA_WIDTH_P = 16
  )(
    // Clock and reset
    input  wire                             clk,
    input  wire                             rst_n,

    // AXI4-S master side
    input  wire                             ing_tvalid,
    input  wire    [AXI_DATA_WIDTH_P-1 : 0] ing_tdata,
    input  wire      [AXI_ID_WIDTH_P-1 : 0] ing_tid,

    // AXI4-S slave side
    output logic                            egr_tvalid,
    output logic   [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
    output logic     [AXI_ID_WIDTH_P-1 : 0] egr_tid
 );

  // Used to shift the ing_tvalid which is used to assing egr_tvalid
  logic [CORDIC_DATA_WIDTH_P-1 : 0] valid_shifter;

  // CORDIC signals
  logic [CORDIC_DATA_WIDTH_P-1 : 0] ing_angle_vector;
  logic [CORDIC_DATA_WIDTH_P-1 : 0] egr_sine_vector;
  logic [CORDIC_DATA_WIDTH_P-1 : 0] egr_cosine_vector;

  // AXI4-S slave ports
  assign egr_tvalid = valid_shifter[CORDIC_DATA_WIDTH_P-1];
  assign egr_tdata  = egr_sine_vector;
  assign egr_tid    = '0;

  // CORDIC signals
  assign ing_angle_vector = ing_tdata;


  // Shift the ing_tvalid which is used to assing egr_tvalid
  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid_shifter    <= '0;
    end
    else begin
      valid_shifter    <= valid_shifter << 1;
      valid_shifter[0] <= ing_tvalid;
    end
  end


  cordic_top #(
    .DATA_WIDTH_P      ( CORDIC_DATA_WIDTH_P )
  ) cordic_top_i0 (

    // Clock and reset
    .clk               ( clk                 ),
    .rst_n             ( rst_n               ),

    // Vectors
    .ing_angle_vector  ( ing_angle_vector    ),
    .egr_sine_vector   ( egr_sine_vector     ),
    .egr_cosine_vector ( egr_cosine_vector   )
  );




endmodule

`default_nettype wire
