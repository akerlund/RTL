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

module axi4s_hsl_if #(
    parameter int AXI_ID_WIDTH_P = -1
  )(
    // Clock and reset
    input  wire                         clk,
    input  wire                         rst_n,

    // AXI4-S master side
    input  wire                         ing_tvalid,
    output logic                        ing_tready,
    input  wire                [35 : 0] ing_tdata,
    input  wire  [AXI_ID_WIDTH_P-1 : 0] ing_tid,

    // AXI4-S slave side
    output logic                        egr_tvalid,
    input  wire                         egr_tready,
    output logic               [35 : 0] egr_tdata,
    output logic [AXI_ID_WIDTH_P-1 : 0] egr_tid
  );

  logic ing_transaction;
  logic egr_transaction;

  assign ing_transaction = ing_tready && ing_tvalid;
  assign egr_transaction = egr_tready && egr_tvalid;

  color_hsl_12bit_color color_hsl_12bit_color_i0 (

    .clk         ( clk                ), // input
    .rst_n       ( rst_n              ), // inout

    .ready       ( ing_tready         ), // output
    .valid_hue   ( ing_transaction    ), // input
    .hue         ( ing_tdata[11 : 0]  ), // input
    .saturation  ( ing_tdata[23 : 12] ), // input
    .brightness  ( ing_tdata[35 : 24] ), // input

    .valid_rgb   ( egr_tvalid         ), // output
    .color_red   ( egr_tdata[11 : 0]  ), // output
    .color_green ( egr_tdata[23 : 12] ), // output
    .color_blue  ( egr_tdata[35 : 24] )  // output
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      egr_tid <= '0;
    end
    else begin
      if (ing_transaction) begin
        egr_tid <= egr_tid;
      end
    end
  end

endmodule

`default_nettype wire
