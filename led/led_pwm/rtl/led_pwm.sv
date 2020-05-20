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

module led_pwm #(
    parameter int counter_width_p = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,
    output logic                       pwm,
    input  wire  [counter_width_p-1:0] cr_pwm_duty
  );

  led_pwm_core  #(
    .counter_width_p ( counter_width_p )
  ) led_pwm_core_i0  (
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .pwm             ( pwm             ),
    .cr_pwm_duty     ( cr_pwm_duty     )
  );

endmodule

`default_nettype wire