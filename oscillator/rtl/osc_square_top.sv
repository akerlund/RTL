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

module osc_square_top #(
    parameter int SYS_CLK_FREQUENCY_P = -1, // System clock's frequency
    parameter int PRIME_FREQUENCY_P   = -1, // Output frequency then clock enable is always high
    parameter int WAVE_WIDTH_P        = -1, // Width of the wave
    parameter int N_BITS_P            = -1
  )(
    // Clock and reset
    input  wire                               clk,
    input  wire                               rst_n,
    output logic signed  [WAVE_WIDTH_P-1 : 0] osc_square,

    // Configuration registers
    input  wire          [N_BITS_P-1 : 0] cr_duty_cycle,
    input  wire          [N_BITS_P-1 : 0] cr_clock_enable // For example; PRIME_FREQUENCY_P / cr_frequency
  );

  // The prime (or higest/base) frequency's period in system clock periods, e.g.,
  // 200MHz / 1MHz = 200
  localparam int PERIOD_IN_SYS_CLKS_C = SYS_CLK_FREQUENCY_P / PRIME_FREQUENCY_P;

  localparam int COUNTER_WIDTH_C = $ceil($clog2(SYS_CLK_FREQUENCY_P));

  logic sqr_enable;
  logic egr_prime_enable;
  logic frequency_enable;
  logic duty_cycle_enable;

  logic [N_BITS_P-1 : 0] cr_duty_cycle_d0;
  logic [N_BITS_P-1 : 0] cr_clock_enable_d0;
  logic                  reset_enable;

  // The prime frequency counter is enabled by either of these
  assign sqr_enable = egr_prime_enable || duty_cycle_enable;

  // Waveform output selection
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cr_duty_cycle_d0   <= '0;
      cr_clock_enable_d0 <= '0;
      reset_enable       <= '1;
    end
    else begin

      reset_enable <= '1;

      // Configurstion has changed
      if (cr_duty_cycle_d0 != cr_duty_cycle || cr_clock_enable_d0 != cr_clock_enable) begin

        // Update the registers on last clock of the negative flank
        if (sqr_enable && osc_square[WAVE_WIDTH_P-1]) begin
          cr_duty_cycle_d0   <= cr_duty_cycle;
          cr_clock_enable_d0 <= cr_clock_enable;
          reset_enable       <= '0;
        end
      end

    end

  end

  // ---------------------------------------------------------------------------
  // Square wave core
  // The core toggles the wave on every asserted "sqr_enable" signal.
  // ---------------------------------------------------------------------------

  osc_square_core #(
    .WAVE_WIDTH_P  ( WAVE_WIDTH_P     )
  ) osc_square_core_i0 (
    .clk           ( clk              ),
    .rst_n         ( rst_n            ),
    .clock_enable  ( sqr_enable       ),
    .osc_square    ( osc_square       )
  );


  // ---------------------------------------------------------------------------
  // Scaling clock enable
  // This scaling clock enable makes the prime frequency if enabled all the
  // time, i.e., its ingress port "ing_enable" is asserted every clock
  // cycle. This port controls the frequency and can be scaled down with another
  // clock enable module.
  // ---------------------------------------------------------------------------

  clock_enable_scaler #(
    .COUNTER_WIDTH_P  ( COUNTER_WIDTH_C      )
  ) clock_enable_scaler_i0 (
    .clk              ( clk                  ), // input
    .rst_n            ( rst_n                ), // input
    .reset_counter_n  ( reset_enable         ), // input
    .ing_enable       ( frequency_enable     ), // input
    .egr_enable       ( egr_prime_enable     ), // output
    .cr_enable_period ( PERIOD_IN_SYS_CLKS_C )  // input
  );


  // ---------------------------------------------------------------------------
  // Clock enable
  // This clock enable scales the prime frequency. If the prime frequency is
  // 100Mhz and this module counts to 1000, then the resulting frequency would
  // become 1kHz, assumin there is another clock module which controls the duty
  // cycle and toggles the wave, too.
  // ---------------------------------------------------------------------------

  clock_enable #(
    .COUNTER_WIDTH_P  ( COUNTER_WIDTH_C  )
  ) clock_enable_i0 (
    .clk              ( clk              ), // input
    .rst_n            ( rst_n            ), // input
    .reset_counter_n  ( reset_enable     ), // input
    .enable           ( frequency_enable ), // output
    .cr_enable_period ( cr_clock_enable  )  // input
  );


  // ---------------------------------------------------------------------------
  // Delay Enable
  // When the previous module's counter is at is highest and has the square core
  // to toggle, this delay enable module will start counting up to the value
  // in the configuration register for the duty cycle.
  // ---------------------------------------------------------------------------
  delay_enable #(
    .COUNTER_WIDTH_P ( COUNTER_WIDTH_C   )
  ) delay_enable_i0 (
    .clk             ( clk               ), // input
    .rst_n           ( rst_n             ), // input
    .reset_counter_n ( reset_enable      ), // input
    .start           ( egr_prime_enable  ), // input
    .delay_out       ( duty_cycle_enable ), // output
    .cr_delay_period ( cr_duty_cycle     )  // input
  );

endmodule

`default_nettype wire
