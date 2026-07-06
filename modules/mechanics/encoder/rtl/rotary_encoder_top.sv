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

module rotary_encoder_top (
    input  wire  clk,
    input  wire  rst_n,

    input  wire  encoder_pin_a,
    input  wire  encoder_pin_b,

    output logic rotation_valid,
    output logic rotation_direction
  );

  logic encoder_a;
  logic encoder_b;


  io_synchronizer io_synchronizer_i0 (
    .clk         ( clk           ),
    .rst_n       ( rst_n         ),
    .bit_ingress ( encoder_pin_a ),
    .bit_egress  ( encoder_a     )
  );

  io_synchronizer io_synchronizer_i1 (
    .clk         ( clk           ),
    .rst_n       ( rst_n         ),
    .bit_ingress ( encoder_pin_b ),
    .bit_egress  ( encoder_b     )
  );

  rotary_encoder_fsm rotary_encoder_fsm_i0 (
    .clk                ( clk                ),
    .rst_n              ( rst_n              ),
    .encoder_pin_a      ( encoder_a          ),
    .encoder_pin_b      ( encoder_b          ),
    .valid_change       ( rotation_valid     ),
    .rotation_direction ( rotation_direction )
  );

endmodule

`default_nettype wire
