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
    parameter int WAVE_WIDTH_P     = -1,
    parameter int COUNTER_WIDTH_P  = -1,
    parameter int APB_DATA_WIDTH_P = -1
  )(
    // Clock and reset
    input  wire                                  clk,
    input  wire                                  rst_n,
    output logic signed     [WAVE_WIDTH_P-1 : 0] osc_square,

    // Configuration registers
    input  wire         [APB_DATA_WIDTH_P-1 : 0] cr_duty_cycle,
    input  wire          [COUNTER_WIDTH_P-1 : 0] cr_clock_enable // For example; SYS_CLK_FREQUENCY_P / cr_frequency
  );

  logic sqr_enable;
  logic clock_enable;
  logic delay_enable;


  assign sqr_enable = clock_enable;// || delay_enable;

  osc_square_core #(
    .WAVE_WIDTH_P ( WAVE_WIDTH_P )
  ) osc_square_core_i0 (
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),
    .clock_enable ( sqr_enable   ),
    .osc_square   ( osc_square   )
  );


  clock_enable #(
    .COUNTER_WIDTH_P  ( COUNTER_WIDTH_P )
  ) clock_enable_i0 (
    .clk              ( clk             ), // input
    .rst_n            ( rst_n           ), // input
    .enable           ( clock_enable    ), // output
    .cr_enable_period ( cr_clock_enable )  // input
  );


  // Duty cycle enable

  // Range? (1-100)?

  // Delay = cr_enable_period / range * cr_duty_cycle

  // delay_enable #(
  //   .CLK_PERIOD_P (              ),
  //   .DELAY_NS_P   (              ),
  // ) delay_enable_i0 (
  //   .clk          ( clk          ),
  //   .rst_n        ( rst_n        ),
  //   .start        ( clock_enable ),
  //   .delay_out    ( delay_enable )
  // );

endmodule

`default_nettype wire
