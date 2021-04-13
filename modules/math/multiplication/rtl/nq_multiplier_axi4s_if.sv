////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
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
  logic                  egr_nq_valid_d1;
  logic [N_BITS_P-1 : 0] egr_nq_product;
  logic                  egr_nq_overflow;

  // Assign signals to the AXI4-S master side
  assign ing_tready = ing_nq_ready;

  // Assign AXI4-S output ports
  assign egr_tvalid = egr_nq_valid_d0 && !egr_nq_valid_d1;
  assign egr_tdata  = egr_nq_product;
  assign egr_tlast  = '1;
  assign egr_tuser  = egr_nq_overflow;


  // Core ingress
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ing_nq_valid        <= '0;
      ing_nq_multiplicand <= '0;
      ing_nq_multiplier   <= '0;
      egr_nq_valid_d1     <= '0;
      egr_tid             <= '0;
    end
    else begin

      ing_nq_valid    <= '0;
      egr_nq_valid_d1 <= egr_nq_valid_d0;

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
