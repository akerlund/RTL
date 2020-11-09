////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module dsp48_multiplier_axi4s_if #(
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
    MUL_RETURN
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
          mul_state      <= MUL_RETURN;
        end

        MUL_RETURN: begin
          mul_state  <= MUL_RECEIVE;
          ing_tready <= '1;
          egr_tvalid <= '1;
          egr_tdata  <= egr_product;
          egr_tuser  <= egr_overflow;
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
