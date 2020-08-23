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
    parameter int SYS_CLK_FREQUENCY_P  = -1,
    parameter int PRIME_FREQUENCY_P    = -1,
    parameter int WAVE_WIDTH_P         = -1,
    parameter int DUTY_CYCLE_DIVIDER_P = -1, // Needs to be high so the vector will fit [N_BITS_P-1 : 0]
    parameter int N_BITS_P             = -1,
    parameter int Q_BITS_P             = -1,
    parameter int AXI_DATA_WIDTH_P     = -1,
    parameter int AXI_ID_WIDTH_P       = -1,
    parameter int AXI_ID_P             = -1
  )(
    // Clock and reset
    input  wire                                    clk,
    input  wire                                    rst_n,

    // Waveform output
    output logic signed       [WAVE_WIDTH_P-1 : 0] wave_square,
    output logic signed       [WAVE_WIDTH_P-1 : 0] wave_triangle,
    output logic signed       [WAVE_WIDTH_P-1 : 0] wave_saw,
    output logic signed       [WAVE_WIDTH_P-1 : 0] wave_sin,

    // Long division interface
    output logic                                   div_egr_tvalid,
    input  wire                                    div_egr_tready,
    output logic          [AXI_DATA_WIDTH_P-1 : 0] div_egr_tdata,
    output logic                                   div_egr_tlast,
    output logic            [AXI_ID_WIDTH_P-1 : 0] div_egr_tid,

    input  wire                                    div_ing_tvalid,
    output logic                                   div_ing_tready,
    input  wire           [AXI_DATA_WIDTH_P-1 : 0] div_ing_tdata,     // Quotient
    input  wire                                    div_ing_tlast,
    input  wire             [AXI_ID_WIDTH_P-1 : 0] div_ing_tid,
    input  wire                                    div_ing_tuser,     // Overflow

    // CORDIC interface
    output logic                                   cordic_egr_tvalid,
    input  wire                                    cordic_egr_tready,
    output logic signed   [AXI_DATA_WIDTH_P-1 : 0] cordic_egr_tdata,
    output logic                                   cordic_egr_tlast,
    output logic            [AXI_ID_WIDTH_P-1 : 0] cordic_egr_tid,
    output logic                                   cordic_egr_tuser,  // Vector selection
    input  wire                                    cordic_ing_tvalid,
    output logic                                   cordic_ing_tready,
    input  wire  signed [2*AXI_DATA_WIDTH_P-1 : 0] cordic_ing_tdata,
    input  wire                                    cordic_ing_tlast,

    // Configuration registers
    input  wire                            [1 : 0] cr_waveform_select,
    input  wire                   [N_BITS_P-1 : 0] cr_frequency,
    input  wire                   [N_BITS_P-1 : 0] cr_duty_cycle
  );

  // The prime (or higest/base) frequency's period in system clock periods, e.g.,
  // 200MHz / 1MHz = 200
  localparam int PERIOD_IN_SYS_CLKS_C = SYS_CLK_FREQUENCY_P / PRIME_FREQUENCY_P;

  // Counters maximum width
  localparam int COUNTER_WIDTH_C = $ceil($clog2(SYS_CLK_FREQUENCY_P)); // Maybe this can be smaller?

  // Maximum duty cycle
  localparam logic signed [N_BITS_P-1 : 0] MAXIMUM_DUTY_CYCLE_C = (DUTY_CYCLE_DIVIDER_P-1) << Q_BITS_P;

  // Minimum duty cycle TODO: Doesn't work as expected, still outputs the highest if < 0
  localparam logic signed [N_BITS_P-1 : 0] MINIMUM_DUTY_CYCLE_C = 1 << Q_BITS_P;

  // The value in "cr_duty_cycle" corresponds to a delay of a factor with this value
  // For example, 250M / 1k = 250000 and 18 bits are needed, N32Q11 should do the job
  localparam logic [N_BITS_P-1 : 0] DUTY_CYCLE_STEP_P    = (SYS_CLK_FREQUENCY_P / DUTY_CYCLE_DIVIDER_P) << Q_BITS_P;


  // The FSM for calculations
  typedef enum {
    WAIT_FOR_CONFIGURATIONS_E,
    SEND_DIVIDEND_PRIME_FREQUENCY_E,
    SEND_DIVISOR_CR_FREQUENCY_E,
    WAIT_QUOTIENT_PRIME_CR_E,
    SEND_DIVIDEND_DUTY_CYCLE_STEP_E,
    SEND_DIVISOR_FREQUENCY_1_E,
    WAIT_QUOTIENT_DUTY_CYCLE_STEP_FREQUENCY_E,
    MULTIPLY_DUTY_CYCLE_E,
    WRITE_CONFIGURATION_E
  } osc_core_state_t;

  osc_core_state_t osc_core_state;


  // Internal registers
  logic          [N_BITS_P-1 : 0] cr_frequency_d0;        // Copy of cr_frequency, used to re-calculate when new input
  logic signed   [N_BITS_P-1 : 0] cr_duty_cycle_d0;       // Copy of cr_duty_cycle
  logic signed [2*N_BITS_P-1 : 0] multiplication_product;


  logic   [N_BITS_P-1 : 0] enable_period;          // Intermediate register the triangle and square enable periods
  logic   [N_BITS_P-1 : 0] duty_cycle;             // Intermediate register the square duty cycle

  // Internal signals
  logic   [N_BITS_P-1 : 0] tri_enable_period;
  logic   [N_BITS_P-1 : 0] sqr_enable_period;
  logic   [N_BITS_P-1 : 0] sqr_duty_cycle;


  // FSM for interfacing with the divider and calculate for the
  // Triangle: PRIME_FREQUENCY_P   / cr_frequency
  // Square:   SYS_CLK_FREQUENCY_P / cr_frequency, also is triangle * (eg) 250
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // Internal signals
      osc_core_state         <= WAIT_FOR_CONFIGURATIONS_E;
      tri_enable_period      <= '0;
      sqr_enable_period      <= '0;
      sqr_duty_cycle         <= '0;
      multiplication_product <= '0;

      // Registers
      cr_frequency_d0        <= '0;
      cr_duty_cycle_d0       <= '0;
      enable_period          <= '0;
      duty_cycle             <= '0;

      // Ports
      div_egr_tvalid         <= '0;
      div_egr_tdata          <= '0;
      div_egr_tlast          <= '0;
      div_egr_tid            <= '0;
      div_ing_tready         <= '0;

    end
    else begin

      div_egr_tid <= AXI_ID_P;

      case (osc_core_state)

        WAIT_FOR_CONFIGURATIONS_E: begin

          // New frequency
          if (cr_frequency != cr_frequency_d0) begin
            cr_frequency_d0 <= cr_frequency;
            osc_core_state  <= SEND_DIVIDEND_PRIME_FREQUENCY_E;
          end

          // New duty cycle
          if (cr_duty_cycle != cr_duty_cycle_d0) begin
            osc_core_state  <= SEND_DIVIDEND_DUTY_CYCLE_STEP_E;
          end

        end


        SEND_DIVIDEND_PRIME_FREQUENCY_E: begin

          osc_core_state <= SEND_DIVISOR_CR_FREQUENCY_E;
          div_egr_tvalid <= '1;
          div_egr_tdata  <= PRIME_FREQUENCY_P << Q_BITS_P;
          div_egr_tlast  <= '0;
        end


        SEND_DIVISOR_CR_FREQUENCY_E: begin

          if (div_egr_tready) begin

            // Dividend was sent
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_frequency_d0;
              div_egr_tlast  <= '1;
            end
            // Divisor was sent
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              osc_core_state <= WAIT_QUOTIENT_PRIME_CR_E;
            end
          end
        end


        WAIT_QUOTIENT_PRIME_CR_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            div_ing_tready <= '0;
            // Truncating the decimals
            enable_period  <= div_ing_tdata >> Q_BITS_P;
            osc_core_state <= SEND_DIVIDEND_DUTY_CYCLE_STEP_E;
          end
        end

        // ---------------------------------------------------------------------
        // Duty cycle
        // ---------------------------------------------------------------------

        SEND_DIVIDEND_DUTY_CYCLE_STEP_E: begin

          osc_core_state <= SEND_DIVISOR_FREQUENCY_1_E;
          div_egr_tvalid <= '1;
          div_egr_tdata  <= DUTY_CYCLE_STEP_P;
          div_egr_tlast  <= '0;
        end


        SEND_DIVISOR_FREQUENCY_1_E: begin

          if (div_egr_tready) begin

            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_frequency_d0;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              osc_core_state <= WAIT_QUOTIENT_DUTY_CYCLE_STEP_FREQUENCY_E;
            end
          end
        end


        WAIT_QUOTIENT_DUTY_CYCLE_STEP_FREQUENCY_E: begin

          div_ing_tready <= '1;

          if (div_ing_tvalid) begin

            osc_core_state <= MULTIPLY_DUTY_CYCLE_E;
            div_ing_tready <= '0;

            if ((cr_duty_cycle <<< Q_BITS_P) > MAXIMUM_DUTY_CYCLE_C) begin
              multiplication_product <= div_ing_tdata * MAXIMUM_DUTY_CYCLE_C;
            end
            else if ((cr_duty_cycle <<< Q_BITS_P) < MINIMUM_DUTY_CYCLE_C) begin
              multiplication_product <= div_ing_tdata * MINIMUM_DUTY_CYCLE_C;
            end
            else begin
              multiplication_product <= div_ing_tdata * (cr_duty_cycle <<< Q_BITS_P);
            end

          end
        end


        MULTIPLY_DUTY_CYCLE_E: begin
          multiplication_product <= (multiplication_product >> Q_BITS_P);
          osc_core_state         <= WRITE_CONFIGURATION_E;
        end


        WRITE_CONFIGURATION_E: begin
          tri_enable_period <= enable_period;
          sqr_enable_period <= enable_period;
          sqr_duty_cycle    <= multiplication_product >> (Q_BITS_P); // Also, truncate the decimals
          osc_core_state    <= WAIT_FOR_CONFIGURATIONS_E;
        end

      endcase

    end
  end


  osc_square_top #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_P ),
    .PRIME_FREQUENCY_P   ( PRIME_FREQUENCY_P   ),
    .WAVE_WIDTH_P        ( WAVE_WIDTH_P        ),
    .N_BITS_P            ( N_BITS_P            )
  ) osc_square_top_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .osc_square          ( wave_square         ), // output
    .cr_clock_enable     ( sqr_enable_period   ), // input
    .cr_duty_cycle       ( sqr_duty_cycle      )  // input
  );


  osc_triangle_top #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_P ),
    .PRIME_FREQUENCY_P   ( PRIME_FREQUENCY_P   ),
    .WAVE_WIDTH_P        ( WAVE_WIDTH_P        )
  ) osc_triangle_top_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .osc_triangle        ( wave_triangle       ), // output
    .cr_clock_enable     ( tri_enable_period   )  // input
  );


  osc_saw_top #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_P ),
    .PRIME_FREQUENCY_P   ( PRIME_FREQUENCY_P   ),
    .WAVE_WIDTH_P        ( WAVE_WIDTH_P        )
  ) osc_saw_top_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .osc_saw             ( wave_saw            ), // output
    .cr_clock_enable     ( sqr_enable_period   )  // input
  );

  osc_sin_top #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_P ),
    .PRIME_FREQUENCY_P   ( PRIME_FREQUENCY_P   ),
    .AXI_DATA_WIDTH_P    ( AXI_DATA_WIDTH_P    ),
    .AXI_ID_WIDTH_P      ( AXI_ID_WIDTH_P      ),
    .AXI_ID_P            ( AXI_ID_P            ),
    .N_BITS_P            ( N_BITS_P            ),
    .Q_BITS_P            ( Q_BITS_P            )
  ) osc_sin_top_i0 (
    .clk                 ( clk                 ),
    .rst_n               ( rst_n               ),
    .osc_sine            ( wave_sin            ),
    .cr_clock_enable     ( tri_enable_period   ),
    .cordic_egr_tvalid   ( cordic_egr_tvalid   ),
    .cordic_egr_tready   ( cordic_egr_tready   ),
    .cordic_egr_tdata    ( cordic_egr_tdata    ),
    .cordic_egr_tlast    ( cordic_egr_tlast    ),
    .cordic_egr_tid      ( cordic_egr_tid      ),
    .cordic_egr_tuser    ( cordic_egr_tuser    ),
    .cordic_ing_tvalid   ( cordic_ing_tvalid   ),
    .cordic_ing_tready   ( cordic_ing_tready   ),
    .cordic_ing_tdata    ( cordic_ing_tdata    ),
    .cordic_ing_tlast    ( cordic_ing_tlast    )
  );


endmodule

`default_nettype wire
