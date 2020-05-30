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

import iir_biquad_apb_slave_addr_pkg::*;

`default_nettype none

module iir_biquad_apb_slave #(
    parameter int APB_BASE_ADDR_P  = -1,
    parameter int APB_ADDR_WIDTH_P = -1,
    parameter int APB_DATA_WIDTH_P = -1
  )(
    input  wire                           clk,
    input  wire                           rst_n,

    input  wire  [APB_ADDR_WIDTH_P-1 : 0] apb3_paddr,
    input  wire                           apb3_psel,
    input  wire                           apb3_penable,
    input  wire                           apb3_pwrite,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] apb3_pwdata,
    output logic                          apb3_pready,
    output logic [APB_DATA_WIDTH_P-1 : 0] apb3_prdata,

    // Configuration registers
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_iir_f0,
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_iir_fs,
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_iir_q,
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_iir_type,
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_bypass,

    // Status registers
    input  wire  [APB_DATA_WIDTH_P-1 : 0] sr_w0,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] sr_alfa,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] sr_zero_b0,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] sr_zero_b1,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] sr_zero_b2,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] sr_pole_a0,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] sr_pole_a1,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] sr_pole_a2

  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // APB interfaces
      apb3_pready    <= '0;
      apb3_prdata    <= '0;

      // Registers
      cr_iir_f0      <= '0;
      cr_iir_fs      <= '0;
      cr_iir_q       <= '0;
      cr_iir_type    <= '0;
      cr_bypass      <= '0;

    end
    else begin

      apb3_pready    <= '0;
      apb3_prdata    <= '0;

      if (apb3_psel) begin

        if (apb3_penable) begin

          apb3_pready <= '1;
          apb3_prdata <= apb3_prdata;

          // ---------------------------------------------------------------------
          // Writes
          // ---------------------------------------------------------------------

          if (apb3_pwrite && apb3_pready) begin

            if (apb3_paddr == APB_BASE_ADDR_P + CR_IIR_F0_ADDR_C) begin
              cr_iir_f0 <= apb3_pwdata;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + CR_IIR_FS_ADDR_C) begin
              cr_iir_fs <= apb3_pwdata;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + CR_IIR_Q_ADDR_C) begin
              cr_iir_q <= apb3_pwdata;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + CR_IIR_TYPE_ADDR_C) begin
              cr_iir_type <= apb3_pwdata;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + CR_IIR_BYPASS_ADDR_C) begin
              cr_bypass <= apb3_pwdata;
            end

          end

          // ---------------------------------------------------------------------
          // Reads
          // ---------------------------------------------------------------------

          else begin

            if (apb3_paddr == APB_BASE_ADDR_P + SR_W0_ADDR_C) begin
              apb3_prdata <= sr_w0;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + SR_ALFA_ADDR_C) begin
              apb3_prdata <= sr_alfa;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + SR_ZERO_B0_ADDR_C) begin
              apb3_prdata <= sr_zero_b0;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + SR_ZERO_B1_ADDR_C) begin
              apb3_prdata <= sr_zero_b1;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + SR_ZERO_B2_ADDR_C) begin
              apb3_prdata <= sr_zero_b2;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + SR_POLE_A0_ADDR_C) begin
              apb3_prdata <= sr_pole_a0;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + SR_POLE_A1_ADDR_C) begin
              apb3_prdata <= sr_pole_a1;
            end

            if (apb3_paddr == APB_BASE_ADDR_P + SR_POLE_A2_ADDR_C) begin
              apb3_prdata <= sr_pole_a2;
            end

          end
        end
      end
    end
  end

endmodule

`default_nettype wire
