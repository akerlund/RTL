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

module ram_sp_bw #(
    parameter int BYTE_WIDTH_P = 4,
    parameter int ADDR_WIDTH_P = 5
  )(
    input  wire                         clk,
    input  wire                         enable,
    input  wire                         write_enable,
    input  wire  [BYTE_WIDTH_P*8-1 : 0] data_ingress,
    input  wire    [ADDR_WIDTH_P-1 : 0] address,
    input  wire    [BYTE_WIDTH_P-1 : 0] write_mask,

    output logic [BYTE_WIDTH_P*8-1 : 0] data_egress
  );

  logic [BYTE_WIDTH_P*8-1 : 0] ram_memory [2**ADDR_WIDTH_P-1 : 0];

  always_ff @(posedge clk) begin

    if (enable) begin

      data_egress <= ram_memory[address];

      if (write_enable) begin

        for (int i = 0; i < BYTE_WIDTH_P; i++) begin
          if (write_mask[i]) begin
            ram_memory[address][i*8 +: 8] <= data_ingress[i*8 +: 8];
          end
        end
      end

    end

  end

  initial begin
    if (BYTE_WIDTH_P <= 0) begin
      $error("BYTE_WIDTH_P must be greater than zero");
    end

    if (ADDR_WIDTH_P <= 0) begin
      $error("ADDR_WIDTH_P must be greater than zero");
    end
  end

endmodule

`default_nettype wire
