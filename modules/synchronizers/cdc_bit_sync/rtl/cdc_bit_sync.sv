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

// By using a wrapper around the core we will always find any instance
// of 'cdc_bit_sync_core_i0' within a 'cdc_bit_sync_iX'.
// Thus, we can constraint them all with, e.g.,
// set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*cdc_bit_sync_core_i0/dst_bit.*]

module cdc_bit_sync (

    input  wire  clk_src,
    input  wire  rst_src_n,
    input  wire  clk_dst,
    input  wire  rst_dst_n,
    input  wire  src_bit,
    output logic dst_bit
  );

  cdc_bit_sync_core cdc_bit_sync_core_i0 (

    .clk_src   ( clk_src   ),
    .rst_src_n ( rst_src_n ),
    .clk_dst   ( clk_dst   ),
    .rst_dst_n ( rst_dst_n ),
    .src_bit   ( src_bit   ),
    .dst_bit   ( dst_bit   )
  );

endmodule

`default_nettype wire
