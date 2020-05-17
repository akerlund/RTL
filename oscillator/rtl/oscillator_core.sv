////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
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

  // Square Oscillator
  logic  [WAVE_WIDTH_P-1 : 0] wave_square;


  assign osc_selected_waveform = osc_waveform_type_t'(cr_waveform_select);


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      waveform              <= '0;
      osc_selected_waveform <= OSC_SQUARE_E;
    end
    else begin

      case (osc_selected_waveform)

        OSC_SQUARE_E: begin
          waveform <= wave_square;
        end

        // OSC_TRIANGLE_E: begin

        // end

        // OSC_SAW_E: begin

        // end

        // OSC_SINE_E: begin

        // end

      endcase

    end

  end


  osc_square #(

    .SQUARE_WIDTH_P  ( WAVE_WIDTH_P    ),
    .COUNTER_WIDTH_P ( COUNTER_WIDTH_P )

  ) osc_square_i0 (

    // Clock and reset
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),

    // Waveform output
    .osc_square      ( wave_square     ),

    // Configuration registers
    .cr_frequency    ( cr_frequency    ),
    .cr_duty_cycle   ( cr_duty_cycle   )
  );
  
endmodule

`default_nettype wire
