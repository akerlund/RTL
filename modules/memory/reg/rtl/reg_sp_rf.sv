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

module reg_sp_rf #(
    parameter int DATA_WIDTH_P = 32,
    parameter int ADDR_WIDTH_P = 5
  )(
    input  wire                       clk,

    input  wire                       port_a_write_en,
    input  wire  [ADDR_WIDTH_P-1 : 0] port_a_address,
    input  wire  [DATA_WIDTH_P-1 : 0] port_a_data_in,

    input  wire  [ADDR_WIDTH_P-1 : 0] port_b_address,
    output logic [DATA_WIDTH_P-1 : 0] port_b_data_out
  );

  logic [DATA_WIDTH_P-1 : 0] fpga_reg [2**ADDR_WIDTH_P-1 : 0];

  assign port_b_data_out = fpga_reg[port_b_address];

  always_ff @ (posedge clk) begin
    if (port_a_write_en) begin
      fpga_reg[port_a_address] <= port_a_data_in;
    end
  end

  initial begin
    if (DATA_WIDTH_P <= 0) begin
      $error("DATA_WIDTH_P must be greater than zero");
    end

    if (ADDR_WIDTH_P <= 0) begin
      $error("ADDR_WIDTH_P must be greater than zero");
    end
  end

endmodule

`default_nettype wire
