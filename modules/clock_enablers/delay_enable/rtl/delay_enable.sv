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

module delay_enable #(
    parameter int COUNTER_WIDTH_P = 1
  )(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          reset_counter_n,
    input  wire                          start,
    output logic                         delay_out,
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_delay_period
  );

  logic [COUNTER_WIDTH_P-1 : 0] delay_counter;
  logic                         delaying;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      delay_out     <= '0;
      delaying      <= '0;
      delay_counter <= '0;
    end
    else begin

      delay_out <= '0;

      if (!reset_counter_n) begin
        delay_counter <= '0;
        delaying      <= '0;
      end
      else if (delaying == '0 && start == '1) begin
        delay_counter <= '0;
        if (cr_delay_period == '0) begin
          delay_out <= '1;
        end
        else begin
          delaying <= '1;
        end
      end
      else begin
        if (delaying == '1) begin
          if (delay_counter >= cr_delay_period-1) begin
            delaying      <= '0;
            delay_counter <= '0;
            delay_out     <= '1;
          end
          else begin
            delay_counter <= delay_counter + 1;
          end
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
