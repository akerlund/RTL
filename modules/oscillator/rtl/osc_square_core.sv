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

module osc_square_core #(
    parameter int WAVE_WIDTH_P = -1 // Resolution of the wave
  )(
    // Clock and reset
    input  wire                              clk,
    input  wire                              rst_n,
    input  wire                              clock_enable,
    output logic signed [WAVE_WIDTH_P-1 : 0] osc_square
  );

  localparam logic signed [WAVE_WIDTH_P-1 : 0] SQUARE_LOW_C = {1'b1, {(WAVE_WIDTH_P-1){1'b0}}}; // Lowest signed integer
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
