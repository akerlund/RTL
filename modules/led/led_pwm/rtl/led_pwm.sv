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
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module led_pwm #(
    parameter int COUNTER_WIDTH_P = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,
    output logic                       pwm_led,
    input  wire  [COUNTER_WIDTH_P-1:0] cr_pwm_duty
  );

  led_pwm_core  #(
    .COUNTER_WIDTH_P ( COUNTER_WIDTH_P )
  ) led_pwm_core_i0  (
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .pwm_led         ( pwm_led         ),
    .cr_pwm_duty     ( cr_pwm_duty     )
  );

endmodule

`default_nettype wire