////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
