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

import oscillator_types_pkg::*;

`default_nettype none

module oscillator_core #(
    parameter int SYS_CLK_FREQUENCY_P = -1,
    parameter int PRIME_FREQUENCY_P   = -1,
    parameter int AXI_DATA_WIDTH_P    = -1,
    parameter int AXI_ID_WIDTH_P      = -1,
    parameter int AXI_ID_P            = -1,
    parameter int APB_DATA_WIDTH_P    = -1,
    parameter int WAVE_WIDTH_P        = -1,
    parameter int Q_BITS_P            = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // Waveform output
    output logic     [WAVE_WIDTH_P-1 : 0] waveform,

    // Long division interface
    output logic                          div_egr_tvalid,
    input  wire                           div_egr_tready,
    output logic [AXI_DATA_WIDTH_P-1 : 0] div_egr_tdata,
    output logic                          div_egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] div_egr_tid,

    input  wire                           div_ing_tvalid,
    output logic                          div_ing_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] div_ing_tdata,     // Quotient
    input  wire                           div_ing_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] div_ing_tid,
    input  wire                           div_ing_tuser,     // Overflow

    // Configuration registers
    input  wire  [APB_DATA_WIDTH_P-1 : 0] cr_waveform_select,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] cr_frequency,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] cr_duty_cycle
  );

  // This is used for frequency calculations
  typedef enum {
    WAIT_FOR_CR_FREQUENCY_E,
    SEND_DIVIDEND_0_E,
    SEND_DIVISOR_0_E,
    WAIT_QUOTIENT_0_E,
    SEND_DIVIDEND_1_E,
    SEND_DIVISOR_1_E,
    WAIT_QUOTIENT_1_E
  } divider_state_t;

  divider_state_t divider_state;

  // Counters maximum width
  localparam int COUNTER_WIDTH_C = $clog2(SYS_CLK_FREQUENCY_P); // Maybe this can be smaller?


  // Internal reegister

  osc_waveform_type_t osc_selected_waveform;

  logic  [COUNTER_WIDTH_C-1 : 0] sqr_enable_period;
  logic  [COUNTER_WIDTH_C-1 : 0] tri_enable_period;
  logic [APB_DATA_WIDTH_P-1 : 0] cr_frequency_d0;
  logic     [WAVE_WIDTH_P-1 : 0] wave_square;
  logic     [WAVE_WIDTH_P-1 : 0] wave_triangle;

  assign osc_selected_waveform = osc_waveform_type_t'(cr_waveform_select);

  // Waveform process
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      waveform <= '0;
    end
    else begin

      case (osc_selected_waveform)

        OSC_SQUARE_E: begin
          waveform <= wave_square;
        end

        OSC_TRIANGLE_E: begin
          waveform <= wave_triangle;
        end

        // OSC_SAW_E: begin

        // end

        // OSC_SINE_E: begin

        // end

      endcase

    end

  end


  // FSM for interfacing with the divider and calculate for the
  // Triangle: PRIME_FREQUENCY_P   / cr_frequency
  // Square:   SYS_CLK_FREQUENCY_P / cr_frequency, also is triangle * (eg) 250
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      divider_state     <= WAIT_FOR_CR_FREQUENCY_E;
      cr_frequency_d0   <= '0;
      sqr_enable_period <= '0;
      tri_enable_period <= '0;

      // Ports
      div_egr_tvalid    <= '0;
      div_egr_tdata     <= '0;
      div_egr_tlast     <= '0;
      div_egr_tid       <= '0;
      div_ing_tready    <= '0;

    end
    else begin

      div_egr_tid <= AXI_ID_P;

      case (divider_state)

        WAIT_FOR_CR_FREQUENCY_E: begin

          if (cr_frequency != cr_frequency_d0) begin
            cr_frequency_d0 <= cr_frequency;
            divider_state   <= SEND_DIVIDEND_0_E;
          end
        end


        SEND_DIVIDEND_0_E: begin

          divider_state  <= SEND_DIVISOR_0_E;
          div_egr_tvalid <= '1;
          div_egr_tdata  <= PRIME_FREQUENCY_P << Q_BITS_P;
          div_egr_tlast  <= '0;
        end


        SEND_DIVISOR_0_E: begin

          if (div_egr_tready) begin

            // Dividend was sent
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_frequency_d0 << Q_BITS_P;
              div_egr_tlast  <= '1;
            end
            // Divisor was sent
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              divider_state  <= WAIT_QUOTIENT_0_E;
            end
          end
        end


        WAIT_QUOTIENT_0_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            div_ing_tready    <= '0;
            tri_enable_period <= div_ing_tdata >> Q_BITS_P;
            divider_state     <= SEND_DIVIDEND_1_E;
          end
        end


        SEND_DIVIDEND_1_E: begin

          divider_state  <= SEND_DIVISOR_1_E;
          div_egr_tvalid <= '1;
          div_egr_tdata  <= (SYS_CLK_FREQUENCY_P >> 4) << Q_BITS_P;
          div_egr_tlast  <= '0;
        end


        SEND_DIVISOR_1_E: begin

          if (div_egr_tready) begin

            // Dividend was sent
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_frequency_d0 << Q_BITS_P;
              div_egr_tlast  <= '1;
            end
            // Divisor was sent
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              divider_state  <= WAIT_QUOTIENT_1_E;
            end
          end
        end


        WAIT_QUOTIENT_1_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            div_ing_tready    <= '0;
            sqr_enable_period <= (div_ing_tdata >> Q_BITS_P) << 4;
            divider_state     <= WAIT_FOR_CR_FREQUENCY_E;
          end
        end

      endcase

    end
  end


  osc_square_top #(
    .WAVE_WIDTH_P     ( WAVE_WIDTH_P      ),
    .COUNTER_WIDTH_P  ( COUNTER_WIDTH_C   ),
    .APB_DATA_WIDTH_P ( APB_DATA_WIDTH_P  )
  ) osc_square_top_i0 (
    .clk              ( clk               ), // input
    .rst_n            ( rst_n             ), // input
    .osc_square       ( wave_square       ), // output
    .cr_duty_cycle    ( cr_duty_cycle     ), // input
    .cr_clock_enable  ( sqr_enable_period )  // input  - SYS_CLK_FREQUENCY_P / cr_frequency
  );


  osc_triangle_top #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_P ),
    .PRIME_FREQUENCY_P   ( PRIME_FREQUENCY_P   ),
    .WAVE_WIDTH_P        ( WAVE_WIDTH_P        )
  ) osc_triangle_top_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .osc_triangle        ( wave_triangle       ), // output
    .cr_clock_enable     ( tri_enable_period   )  // input  - PRIME_FREQUENCY_P / cr_frequency
  );

endmodule

`default_nettype wire
