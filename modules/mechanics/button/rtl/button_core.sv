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

module button_core #(
    parameter int    NR_OF_DEBOUNCE_CLKS_P = 1,
    parameter string CONNECTION_TYPE_P     = "OPEN"
  )(
    input  wire  clk,
    input  wire  rst_n,
    input  wire  button_in_pin,
    output logic button_press_toggle
  );

  logic synchronized_button;
  logic button_in;

  logic button_is_debounced;
  localparam int DEBOUNCE_COUNTER_WIDTH_C = (NR_OF_DEBOUNCE_CLKS_P <= 1) ?
                                            1 : $clog2(NR_OF_DEBOUNCE_CLKS_P+1);

  logic [DEBOUNCE_COUNTER_WIDTH_C-1 : 0] button_counter;

  io_synchronizer io_synchronizer_i0 (
    .clk         ( clk                 ),
    .rst_n       ( rst_n               ),
    .bit_ingress ( button_in_pin       ),
    .bit_egress  ( synchronized_button )
  );

  generate
    if (CONNECTION_TYPE_P == "OPEN") begin : gen_open_connection
      assign button_in = synchronized_button;
    end
    else if (CONNECTION_TYPE_P == "CLOSED") begin : gen_closed_connection
      assign button_in = ~synchronized_button;
    end
    else begin : gen_unsupported_connection
      assign button_in = '0;
      initial begin
        $error("CONNECTION_TYPE_P must be OPEN or CLOSED");
      end
    end
  endgenerate

  // Debouncer
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      button_is_debounced <= '0;
      button_counter      <= '0;
      button_press_toggle <= '0;

    end
    else begin

      button_press_toggle <= '0;

      if (button_in == button_is_debounced) begin
        button_counter <= '0;
      end
      else if (button_counter == DEBOUNCE_COUNTER_WIDTH_C'(NR_OF_DEBOUNCE_CLKS_P)) begin
        button_is_debounced <= button_in;
        button_counter      <= '0;
        if (button_in) begin
          button_press_toggle <= '1;
        end
      end
      else begin
        button_counter <= button_counter + 1;
      end
    end
  end

  initial begin
    if (NR_OF_DEBOUNCE_CLKS_P <= 0) begin
      $error("NR_OF_DEBOUNCE_CLKS_P must be greater than zero");
    end
  end

endmodule

`default_nettype wire
