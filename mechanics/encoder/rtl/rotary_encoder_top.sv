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

module rotary_encoder_top #(
    parameter int button_debounce_clk_cnt_p = 1000000
  )(
    input  wire  clk,
    input  wire  rst_n,

    input  wire  encoder_pin_a,
    input  wire  encoder_pin_b,

    output logic egr_valid,
    output logic rotation_direction
  );

  logic encoder_a;
  logic encoder_b;


  io_synchronizer io_synchronizer_i0 (
    .clk         ( clk           ),
    .rst_n       ( rst_n         ),
    .bit_ingress ( encoder_pin_a ),
    .bit_egress  ( encoder_a     )
  );

  io_synchronizer io_synchronizer_i1 (
    .clk         ( clk           ),
    .rst_n       ( rst_n         ),
    .bit_ingress ( encoder_pin_B ),
    .bit_egress  ( encoder_b     )
  );

  rotary_encoder_core rotary_encoder_core_i0 (
    .clk                ( clk                ),
    .rst_n              ( rst_n              ),
    .encoder_pin_a      ( encoder_a          ),
    .encoder_pin_b      ( encoder_b          ),
    .valid_change       ( egr_valid          ),
    .rotation_direction ( rotation_direction )
  );

endmodule

`default_nettype wire