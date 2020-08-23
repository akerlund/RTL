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

module osc_triangle_core #(
    parameter int                               WAVE_WIDTH_P         = -1, // Width of the wave
    parameter logic signed [WAVE_WIDTH_P-1 : 0] WAVE_AMPLITUDE_INC_P = -1, // Increment of amplitude at every clock enable
    parameter logic signed [WAVE_WIDTH_P-1 : 0] WAVE_AMPLITUDE_MAX_P = -1  // Max amplitude of the triangle
  )(
    // Clock and reset
    input  wire                              clk,
    input  wire                              rst_n,

    // Counter enable to control the frequency
    input  wire                              clock_enable,

    // Waveform output
    output logic signed [WAVE_WIDTH_P-1 : 0] osc_triangle
  );

  localparam logic signed [WAVE_WIDTH_P-1 : 0] TRIANGLE_LOW_C  = {1'b1, {(WAVE_WIDTH_P-1){1'b0}}};

  typedef enum {
    TRIANGLE_RISING_E,
    TRIANGLE_FALLING_E
  } triangle_direction_t;

  triangle_direction_t triangle_direction;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      triangle_direction <= TRIANGLE_RISING_E;
      osc_triangle       <= TRIANGLE_LOW_C;
    end
    else begin

      if (clock_enable) begin

        // Going up
        case (triangle_direction)

          TRIANGLE_RISING_E: begin

            if (osc_triangle >= WAVE_AMPLITUDE_MAX_P) begin
              triangle_direction <= TRIANGLE_FALLING_E;
              osc_triangle       <= osc_triangle - WAVE_AMPLITUDE_INC_P;
            end
            else begin
              osc_triangle       <= osc_triangle + WAVE_AMPLITUDE_INC_P;
            end

          end

          TRIANGLE_FALLING_E: begin

            if (osc_triangle == TRIANGLE_LOW_C) begin
              triangle_direction <= TRIANGLE_RISING_E;
              osc_triangle       <= osc_triangle + WAVE_AMPLITUDE_INC_P;
            end
            else begin
              osc_triangle       <= osc_triangle - WAVE_AMPLITUDE_INC_P;
            end
          end

        endcase

      end
    end
  end

endmodule

`default_nettype wire
