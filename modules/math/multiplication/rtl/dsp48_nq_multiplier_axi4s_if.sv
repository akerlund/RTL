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

module dsp48_nq_multiplier_axi4s_if #(
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
  logic [N_BITS_P-1 : 0] ing_multiplicand;
  logic [N_BITS_P-1 : 0] ing_multiplier;
  logic [N_BITS_P-1 : 0] egr_product;
  logic                  egr_overflow;

  typedef enum {
    MUL_RECEIVE,
    MUL_MULTIPLY,
    MUL_REGISTER
  } mul_state_t;

  mul_state_t mul_state;

  // Core ingress
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      mul_state        <= MUL_RECEIVE;

      ing_multiplicand <= '0;
      ing_multiplier   <= '0;

      ing_tready       <= '1;
      egr_tvalid       <= '0;
      egr_tdata        <= '0;
      egr_tlast        <= '1;
      egr_tid          <= '0;
      egr_tuser        <= '0;

    end
    else begin

      egr_tvalid <= '0;

      case (mul_state)

        MUL_RECEIVE: begin
          if (ing_tvalid && ing_tready) begin
            if (!ing_tlast) begin
              egr_tid          <= ing_tid;
              ing_multiplicand <= ing_tdata;
            end
            else begin
              ing_tready     <= '0;
              ing_multiplier <= ing_tdata;
              mul_state      <= MUL_MULTIPLY;
            end
          end
        end

        MUL_MULTIPLY: begin
          mul_state   <= MUL_REGISTER;
        end

        MUL_REGISTER: begin
          mul_state   <= MUL_RECEIVE;
          ing_tready  <= '1;
          egr_tvalid  <= '1;
          egr_tdata   <= egr_product;
          egr_tuser   <= egr_overflow;
        end

      endcase

    end
  end


  dsp48_nq_multiplier #(
    .N_BITS_P         ( N_BITS_P         ),
    .Q_BITS_P         ( Q_BITS_P         )
  ) dsp48_nq_multiplier_i0 (
    .clk              ( clk              ), // input
    .rst_n            ( rst_n            ), // input
    .ing_multiplicand ( ing_multiplicand ), // input
    .ing_multiplier   ( ing_multiplier   ), // input
    .egr_product      ( egr_product      ), // output
    .egr_overflow     ( egr_overflow     )  // output
  );

endmodule

`default_nettype wire
