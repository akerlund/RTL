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
// Description: Will assert the enable port with a period time that is lesser
// than the system clock period.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module frequency_enable #(
    parameter int SYS_CLK_FREQUENCY_P = -1,
    parameter int AXI_DATA_WIDTH_P    = -1,
    parameter int AXI_ID_WIDTH_P      = -1,
    parameter int Q_BITS_P            = -1,
    parameter int AXI4S_ID_P          = -1
  )(
    input  wire                                      clk,
    input  wire                                      rst_n,

    output logic                                     enable,
    input  wire  [$clog2(SYS_CLK_FREQUENCY_P)-1 : 0] cr_enable_frequency,

    // -------------------------------------------------------------------------
    // Long division interface
    // -------------------------------------------------------------------------

    output logic                                     div_egr_tvalid,
    input  wire                                      div_egr_tready,
    output logic            [AXI_DATA_WIDTH_P-1 : 0] div_egr_tdata,
    output logic                                     div_egr_tlast,
    output logic              [AXI_ID_WIDTH_P-1 : 0] div_egr_tid,

    input  wire                                      div_ing_tvalid,
    output logic                                     div_ing_tready,
    input  wire             [AXI_DATA_WIDTH_P-1 : 0] div_ing_tdata,  // Quotient
    input  wire                                      div_ing_tlast,
    input  wire               [AXI_ID_WIDTH_P-1 : 0] div_ing_tid,
    input  wire                                      div_ing_tuser   // Overflow
  );

  typedef enum {
    SEND_DIVIDEND_E,
    SEND_DIVISOR_E,
    WAIT_QUOTIENT_E,
    ENABLE_COUNTING_E
  } enable_state_t;

  enable_state_t enable_state;

  logic [$clog2(SYS_CLK_FREQUENCY_P)-1 : 0] counter;
  logic [$clog2(SYS_CLK_FREQUENCY_P)-1 : 0] enable_frequency;
  logic [$clog2(SYS_CLK_FREQUENCY_P)-1 : 0] frequency_as_sys_clks;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // Ports
      enable                <= '0;
      div_egr_tvalid        <= '0;
      div_egr_tdata         <= '0;
      div_egr_tlast         <= '0;
      div_egr_tid           <= '0;
      div_ing_tready        <= '0;

      enable_state          <= SEND_DIVIDEND_E;
      counter               <= '0;
      enable_frequency      <= '0;
      frequency_as_sys_clks <= '0;
    end
    else begin

      div_egr_tid <= AXI4S_ID_P;

      case (enable_state)

        SEND_DIVIDEND_E: begin

          if (cr_enable_frequency) begin

            enable_frequency <= cr_enable_frequency;

            enable_state     <= SEND_DIVISOR_E;

            div_egr_tvalid   <= '1;
            div_egr_tdata    <= SYS_CLK_FREQUENCY_P << Q_BITS_P;
            div_egr_tlast    <= '0;
            div_egr_tid      <= AXI4S_ID_P;
          end
        end


        SEND_DIVISOR_E: begin

          if (div_egr_tready) begin

            // Dividend was sent
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_enable_frequency << Q_BITS_P;
              div_egr_tlast  <= '1;
            end
            // Divisor was sent
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              enable_state   <= WAIT_QUOTIENT_E;
            end
          end
        end


        WAIT_QUOTIENT_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            div_ing_tready        <= '0;
            frequency_as_sys_clks <= div_ing_tdata >> Q_BITS_P;
            enable_state          <= ENABLE_COUNTING_E;
          end
        end


        ENABLE_COUNTING_E: begin

          enable  <= '0;
          counter <= counter + 1;

          if (counter >= frequency_as_sys_clks-1) begin
            enable  <= '1;
            counter <= '0;
          end

          if (enable_frequency != cr_enable_frequency) begin
            enable       <= '0;
            counter      <= '0;
            enable_state <= SEND_DIVIDEND_E;
          end

        end

      endcase

    end
  end

endmodule

`default_nettype wire
