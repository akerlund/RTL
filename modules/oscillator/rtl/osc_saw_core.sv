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

module osc_saw_core #(
    parameter int                               WAVE_WIDTH_P         = -1, // Width of the wave
    parameter int                               WAVE_AMPLITUDE_INC_P = -1, // Increment of amplitude at every clock enable
    parameter logic signed [WAVE_WIDTH_P-1 : 0] WAVE_AMPLITUDE_MAX_P = -1  // Max amplitude of the triangle
  )(
    // Clock and reset
    input  wire                              clk,
    input  wire                              rst_n,

    // Counter enable to control the frequency
    input  wire                              clock_enable,

    // Waveform output
    output logic signed [WAVE_WIDTH_P-1 : 0] osc_saw
  );

  localparam logic signed [WAVE_WIDTH_P-1 : 0] SAW_LOW_C  = {1'b1, {(WAVE_WIDTH_P-1){1'b0}}};


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      osc_saw <= SAW_LOW_C;
    end
    else begin

      if (clock_enable) begin

        osc_saw <= osc_saw + WAVE_AMPLITUDE_INC_P;

        if (osc_saw >= WAVE_AMPLITUDE_MAX_P) begin
          osc_saw <= SAW_LOW_C;
        end

      end
    end
  end

endmodule

`default_nettype wire
