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
    parameter int WAVE_WIDTH_P    = -1, // Resolution of the waves
    parameter int COUNTER_WIDTH_P = -1  // Resolution of the counters
  )(
    // Clock and reset
    input  wire                          clk,
    input  wire                          rst_n,

    // Waveform output
    output logic    [WAVE_WIDTH_P-1 : 0] waveform,

    // Configuration registers
    input  wire                  [1 : 0] cr_waveform_select, // Selected waveform
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_frequency,       // Counter's max value
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_duty_cycle       // Determines when the wave goes from highest to lowest
  );

  osc_waveform_type_t osc_selected_waveform;

  logic  [WAVE_WIDTH_P-1 : 0] wave_square;
  logic  [WAVE_WIDTH_P-1 : 0] wave_triangle;

  assign osc_selected_waveform = osc_waveform_type_t'(cr_waveform_select);


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

  osc_square #(
    .DATA_WIDTH_P    ( WAVE_WIDTH_P    ),
    .COUNTER_WIDTH_P ( COUNTER_WIDTH_P )
  ) osc_square_i0 (
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .osc_square      ( wave_square     ),
    .cr_frequency    ( cr_frequency    ),
    .cr_duty_cycle   ( cr_duty_cycle   )
  );

  localparam int F100000_HZ_IN_SYS_CLOCK_C = (200000000/100000);
  localparam int PERIOD_IN_SYS_CLKS_C      = F100000_HZ_IN_SYS_CLOCK_C;

  osc_triangle_top #(
    .DATA_WIDTH_P         ( WAVE_WIDTH_P         ),
    .PERIOD_IN_SYS_CLKS_P ( PERIOD_IN_SYS_CLKS_C ),
    .COUNTER_WIDTH_P      ( COUNTER_WIDTH_P      )
  ) osc_triangle_top_i0 (
    .clk                  ( clk                  ), // input
    .rst_n                ( rst_n                ), // input
    .osc_triangle         ( wave_triangle        ), // output
    .cr_enable_period     ( 1                    )  // input
  );

endmodule

`default_nettype wire
