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

module osc_square_core #(
    parameter int WAVE_WIDTH_P = -1 // Resolution of the wave
  )(
    // Clock and reset
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       clock_enable,
    output logic [WAVE_WIDTH_P-1 : 0] osc_square
  );

  localparam logic [WAVE_WIDTH_P-1 : 0] SQUARE_LOW_C  = {1'b1, {(WAVE_WIDTH_P-1){1'b0}}}; // Lowest signed integer
  //localparam logic [WAVE_WIDTH_P-1 : 0] SQUARE_HIGH_C = {1'b0, {(WAVE_WIDTH_P-1){1'b1}}}; // Highest signed integer

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      osc_square <= SQUARE_LOW_C;
    end
    else begin

      if (clock_enable) begin
        osc_square <= ~osc_square;
      end

    end
  end

endmodule

`default_nettype wire
