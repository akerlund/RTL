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

module oscillator_apb3_slave #(
    parameter int APB3_BASE_ADDR_P  = -1,
    parameter int APB3_ADDR_WIDTH_P = -1,
    parameter int APB3_DATA_WIDTH_P = -1
  )(
    input  wire                            clk,
    input  wire                            rst_n,

    input  wire                            apb3_psel,
    output logic                           apb3_pready,
    output logic [APB3_DATA_WIDTH_P-1 : 0] apb3_prdata,
    input  wire                            apb3_pwrite,
    input  wire                            apb3_penable,
    input  wire  [APB3_ADDR_WIDTH_P-1 : 0] apb3_paddr,
    input  wire  [APB3_DATA_WIDTH_P-1 : 0] apb3_pwdata,

    // Configuration registers
    output logic [APB3_DATA_WIDTH_P-1 : 0] cr_waveform_select,
    output logic [APB3_DATA_WIDTH_P-1 : 0] cr_frequency,
    output logic [APB3_DATA_WIDTH_P-1 : 0] cr_duty_cycle
  );

  localparam logic [APB3_ADDR_WIDTH_P-1 : 0] CR_WAVEFORM_SELECT_ADDR_C = APB3_BASE_ADDR_P + 0;
  localparam logic [APB3_ADDR_WIDTH_P-1 : 0] CR_FREQUENCY_ADDR_C       = APB3_BASE_ADDR_P + 4;
  localparam logic [APB3_ADDR_WIDTH_P-1 : 0] CR_DUTY_CYCLE_ADDR_C      = APB3_BASE_ADDR_P + 8;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // APB interfaces
      apb3_pready        <= '0;
      apb3_prdata        <= '0;

      // Registers
      cr_waveform_select <= '0;
      cr_frequency       <= '0;
      cr_duty_cycle      <= '0;

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

            if (apb3_paddr == CR_WAVEFORM_SELECT_ADDR_C) begin
              cr_waveform_select <= apb3_pwdata;
            end

            if (apb3_paddr == CR_FREQUENCY_ADDR_C) begin
              cr_frequency <= apb3_pwdata;
            end

            if (apb3_paddr == CR_DUTY_CYCLE_ADDR_C) begin
              cr_duty_cycle <= apb3_pwdata;
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
