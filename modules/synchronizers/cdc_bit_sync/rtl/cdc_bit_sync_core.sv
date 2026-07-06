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

module cdc_bit_sync_core (

    input  wire  clk_src,
    input  wire  rst_src_n,
    input  wire  clk_dst,
    input  wire  rst_dst_n,

    input  wire  src_bit,
    output logic dst_bit
  );

  logic src_bit_d0;
  (* async_reg = "true", shreg_extract = "no" *) logic dst_bit_d0;
  (* async_reg = "true", shreg_extract = "no" *) logic dst_bit_reg;

  assign dst_bit = dst_bit_reg;

  always_ff @ (posedge clk_src or negedge rst_src_n) begin
    if (!rst_src_n) begin
      src_bit_d0 <= '0;
    end
    else begin
      src_bit_d0 <= src_bit;
    end
  end

  always_ff @ (posedge clk_dst or negedge rst_dst_n) begin
    if (!rst_dst_n) begin
      dst_bit_d0 <= '0;
      dst_bit_reg <= '0;
    end
    else begin
      dst_bit_d0 <= src_bit_d0;
      dst_bit_reg <= dst_bit_d0;
    end
  end

endmodule

`default_nettype wire
