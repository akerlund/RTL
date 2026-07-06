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

module ram_sdp #(
    parameter int DATA_WIDTH_P = 32,
    parameter int ADDR_WIDTH_P = 5
  )(
    // Clock
    input  wire                       clk,

    // Port A (write port)
    input  wire                       port_a_enable,
    input  wire                       port_a_write_enable,
    input  wire  [DATA_WIDTH_P-1 : 0] port_a_data_ing,
    input  wire  [ADDR_WIDTH_P-1 : 0] port_a_address,

    // Port B (read port)
    input  wire                       port_b_enable,
    input  wire  [ADDR_WIDTH_P-1 : 0] port_b_address,
    output logic [DATA_WIDTH_P-1 : 0] port_b_data_egr
  );

  logic [DATA_WIDTH_P-1 : 0] ram_memory [2**ADDR_WIDTH_P-1 : 0];


  // ---------------------------------------------------------------------------
  // Port A, dedicated to writes
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk) begin

    if (port_a_enable) begin

      if (port_a_write_enable) begin
        ram_memory[port_a_address] <= port_a_data_ing;
      end

    end
  end

  // ---------------------------------------------------------------------------
  // Port B, dedicated to reads
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk) begin

    if (port_b_enable) begin
      port_b_data_egr <= ram_memory[port_b_address];
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
