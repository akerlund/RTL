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

module iir_biquad_apb_slave #(
    parameter int APB_BASE_ADDR_P  = -1,
    parameter int APB_ADDR_WIDTH_P = -1,
    parameter int APB_DATA_WIDTH_P = -1
  )(
    input  wire                           clk,
    input  wire                           rst_n,

    input  wire                           apb3_psel,
    output logic                          apb3_pready,
    output logic [APB_DATA_WIDTH_P-1 : 0] apb3_prdata,
    input  wire                           apb3_pwrite,
    input  wire                           apb3_penable,
    input  wire  [APB_ADDR_WIDTH_P-1 : 0] apb3_paddr,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] apb3_pwdata,

    // Configuration registers
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_iir_f0,
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_iir_fs,
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_iir_q,
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_iir_type,
    output logic [APB_DATA_WIDTH_P-1 : 0] cr_bypass
  );

  localparam logic [APB_ADDR_WIDTH_P-1 : 0] CR_IIR_F0_ADDR_C     = APB_BASE_ADDR_P + 0;
  localparam logic [APB_ADDR_WIDTH_P-1 : 0] CR_IIR_FS_ADDR_C     = APB_BASE_ADDR_P + 4;
  localparam logic [APB_ADDR_WIDTH_P-1 : 0] CR_IIR_Q_ADDR_C      = APB_BASE_ADDR_P + 8;
  localparam logic [APB_ADDR_WIDTH_P-1 : 0] CR_IIR_TYPE_ADDR_C   = APB_BASE_ADDR_P + 12;
  localparam logic [APB_ADDR_WIDTH_P-1 : 0] CR_IIR_BYPASS_ADDR_C = APB_BASE_ADDR_P + 16;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // APB interfaces
      apb3_pready <= '0;
      apb3_prdata <= '0;

      // Registers
      cr_iir_f0   <= '0;
      cr_iir_fs   <= '0;
      cr_iir_q    <= '0;
      cr_iir_type <= '0;
      cr_bypass   <= '0;

    end
    else begin

      apb3_pready <= '0;
      apb3_prdata <= '0;

      if (apb3_psel) begin

        apb3_pready <= '1;

        if (apb3_penable && apb3_pready) begin

          // ---------------------------------------------------------------------
          // Writes
          // ---------------------------------------------------------------------

          if (apb3_pwrite) begin

            if (apb3_paddr == CR_IIR_F0_ADDR_C) begin
              cr_iir_f0 <= apb3_pwdata;
            end

            if (apb3_paddr == CR_IIR_FS_ADDR_C) begin
              cr_iir_fs <= apb3_pwdata;
            end

            if (apb3_paddr == CR_IIR_Q_ADDR_C) begin
              cr_iir_q <= apb3_pwdata;
            end

            if (apb3_paddr == CR_IIR_TYPE_ADDR_C) begin
              cr_iir_type <= apb3_pwdata;
            end

            if (apb3_paddr == CR_IIR_BYPASS_ADDR_C) begin
              cr_bypass <= apb3_pwdata;
            end

          end

          // ---------------------------------------------------------------------
          // Reads
          // ---------------------------------------------------------------------

          else begin
            apb3_prdata <= '0;
          end
        end
      end
    end
  end

endmodule

`default_nettype wire
