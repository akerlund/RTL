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

module osc_square #(
    parameter int SQUARE_WIDTH_P  = -1, // Resolution of the wave
    parameter int COUNTER_WIDTH_P = -1  // Resolution of the counter
  )(
    // Clock and reset
    input  wire                          clk,
    input  wire                          rst_n,

    // Waveform output
    output logic  [SQUARE_WIDTH_P-1 : 0] osc_square,

    // Configuration registers
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_frequency, // Counter's max value
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_duty_cycle // Determines when the wave goes from highest to lowest
  );

  localparam logic [SQUARE_WIDTH_P-1 : 0] SQUARE_HIGH_C = {1'b0, {(SQUARE_WIDTH_P-1){1'b1}}}; // Highest signed integer
  localparam logic [SQUARE_WIDTH_P-1 : 0] SQUARE_LOW_C  = {1'b1, {(SQUARE_WIDTH_P-1){1'b0}}}; // Lowest signed integer

  logic [COUNTER_WIDTH_P-1 : 0] osc_counter;



  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      osc_square  <= SQUARE_HIGH_C;
      osc_counter <= '0;
    end
    else begin

      osc_counter <= osc_counter + 1;

      // Toggle the wave's duty cycle
      if (osc_counter == cr_duty_cycle-1) begin
        osc_square <= SQUARE_LOW_C;
      end

      // Reload when the period is over
      if (osc_counter >= cr_frequency-1) begin
        osc_counter <= '0;
        osc_square  <= SQUARE_HIGH_C;
      end

    end
  end

endmodule

`default_nettype wire
