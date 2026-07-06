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

module io_synchronizer_core (
    input  wire  clk,
    input  wire  rst_n,
    input  wire  bit_ingress,
    output logic bit_egress
  );

  (* async_reg = "true", shreg_extract = "no" *) logic bit_meta;
  (* async_reg = "true", shreg_extract = "no" *) logic bit_egress_reg;

  assign bit_egress = bit_egress_reg;

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_meta       <= '0;
      bit_egress_reg <= '0;
    end
    else begin
      bit_meta       <= bit_ingress;
      bit_egress_reg <= bit_meta;
    end
  end

endmodule

`default_nettype wire
