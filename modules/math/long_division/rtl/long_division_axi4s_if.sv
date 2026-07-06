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

module long_division_axi4s_if #(
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int N_BITS_P         = -1,
    parameter int Q_BITS_P         = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // AXI4-S master side
    input  wire                           ing_tvalid,
    output logic                          ing_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] ing_tdata,
    input  wire                           ing_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] ing_tid,

    // AXI4-S slave side
    output logic                          egr_tvalid,
    output logic [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,  // Quotient
    output logic                          egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] egr_tid,
    output logic                          egr_tuser   // Overflow
 );


  logic [AXI_ID_WIDTH_P-1 : 0] ing_tid_d0;
  logic       [N_BITS_P-1 : 0] ing_dividend;
  logic       [N_BITS_P-1 : 0] ing_divisor;
  logic                        ing_valid;
  logic                        ing_ready;
  logic                        egr_valid;
  logic       [N_BITS_P-1 : 0] egr_quotient;
  logic                        egr_overflow;

  // Assign signals to the AXI4-S master side
  assign ing_tready = ing_ready;

  // Assign AXI4-S output ports
  assign egr_tvalid = egr_valid;
  assign egr_tdata  = egr_valid ? {{(AXI_DATA_WIDTH_P-N_BITS_P){egr_quotient[N_BITS_P-1]}}, egr_quotient} : '0;
  assign egr_tlast  = '1;
  assign egr_tid    = ing_tid_d0;
  assign egr_tuser  = egr_overflow;


  // Core ingress
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ing_tid_d0   <= '0;
      ing_dividend <= '0;
      ing_divisor  <= '0;
      ing_valid    <= '0;
    end
    else begin
      ing_valid <= '0;
      if (ing_tvalid && ing_tready) begin
        ing_tid_d0 <= ing_tid;
        if (!ing_tlast) begin
          ing_dividend <= ing_tdata;
        end
        else begin
          ing_valid   <= '1;
          ing_divisor <= ing_tdata;
        end
      end

    end
  end


  long_division_core #(
    .N_BITS_P      ( N_BITS_P     ),
    .Q_BITS_P      ( Q_BITS_P     )
  ) long_division_core_i0 (
    .clk           ( clk          ), // input
    .rst_n         ( rst_n        ), // input
    .ing_valid     ( ing_valid    ), // input
    .ing_ready     ( ing_ready    ), // output
    .ing_dividend  ( ing_dividend ), // input
    .ing_divisor   ( ing_divisor  ), // input
    .egr_valid     ( egr_valid    ), // output
    .egr_quotient  ( egr_quotient ), // output
    .egr_remainder (              ), // output
    .egr_overflow  ( egr_overflow )  // output
  );

endmodule

`default_nettype wire
