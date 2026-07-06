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

module nq_multiplier_axi4s_if #(
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
    output logic [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
    output logic                          egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] egr_tid,
    output logic                          egr_tuser
 );

  // Signals
  logic                  ing_nq_valid;
  logic                  ing_nq_ready;
  logic [N_BITS_P-1 : 0] ing_nq_multiplicand;
  logic [N_BITS_P-1 : 0] ing_nq_multiplier;
  logic                  egr_nq_valid_d0;
  logic [N_BITS_P-1 : 0] egr_nq_product;
  logic                  egr_nq_overflow;

  // Assign signals to the AXI4-S master side
  assign ing_tready = ing_nq_ready;

  // Assign AXI4-S output ports
  assign egr_tvalid = egr_nq_valid_d0;
  assign egr_tdata  = egr_nq_product;
  assign egr_tlast  = '1;
  assign egr_tuser  = egr_nq_overflow;


  // Core ingress
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ing_nq_valid        <= '0;
      ing_nq_multiplicand <= '0;
      ing_nq_multiplier   <= '0;
      egr_tid             <= '0;
    end
    else begin

      ing_nq_valid <= '0;

      if (ing_tvalid && ing_nq_ready) begin
        egr_tid <= ing_tid;
        if (!ing_tlast) begin
          ing_nq_multiplicand <= ing_tdata;
        end
        else begin
          ing_nq_valid      <= '1;
          ing_nq_multiplier <= ing_tdata;
        end
      end

    end
  end


  nq_multiplier #(
    .N_BITS_P         ( N_BITS_P            ),
    .Q_BITS_P         ( Q_BITS_P            )
  ) nq_multiplier_i0 (
    .clk              ( clk                 ), // input
    .rst_n            ( rst_n               ), // input
    .ing_valid        ( ing_nq_valid        ), // input
    .ing_ready        ( ing_nq_ready        ), // output
    .ing_multiplicand ( ing_nq_multiplicand ), // input
    .ing_multiplier   ( ing_nq_multiplier   ), // input
    .egr_valid        ( egr_nq_valid_d0     ), // output
    .egr_product      ( egr_nq_product      ), // output
    .egr_overflow     ( egr_nq_overflow     )  // output
  );

endmodule

`default_nettype wire
