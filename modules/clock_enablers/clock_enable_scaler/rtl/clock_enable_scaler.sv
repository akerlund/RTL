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

module clock_enable_scaler #(
    parameter int COUNTER_WIDTH_P = 1
  )(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          reset_counter_n,
    input  wire                          ing_enable,
    output logic                         egr_enable,
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_enable_period
  );

  logic [COUNTER_WIDTH_P-1 : 0] clock_enable_counter;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      egr_enable           <= '0;
      clock_enable_counter <= '0;
    end
    else begin

      egr_enable <= '0;

      if (!reset_counter_n) begin
        clock_enable_counter <= '0;
      end
      else if (cr_enable_period == '0) begin
        clock_enable_counter <= '0;
      end
      else if (ing_enable) begin

        clock_enable_counter <= clock_enable_counter + 1;

        if (clock_enable_counter >= cr_enable_period-1) begin
          egr_enable           <= '1;
          clock_enable_counter <= '0;
        end
      end

    end
  end

  initial begin
    if (COUNTER_WIDTH_P <= 0) begin
      $error("COUNTER_WIDTH_P must be greater than zero");
    end
  end

endmodule

`default_nettype wire
