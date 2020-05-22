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
// Simple test bench used to develop the fixed point functions in the
// package file "vip_fixed_point_pkg".
//
////////////////////////////////////////////////////////////////////////////////

import vip_fixed_point_pkg::*;

module tb_fixed_point;

  localparam int n_bits = 8; // Total number of bits, one is for the sign
  localparam int q_bits = 4; // Fractional bits

  // For testing the minimum and maximum function
  real max_fixed_point_value;
  real min_fixed_point_value;

  real                 float_number;   // Test number to convert
  int                  overflow;       // Used to test if a convertion would overflow
  int                  fixed_number;   // Return value of the conversions
  logic [n_bits-1 : 0] fixed_number_b; // Converting the return value logic


  initial begin

    $display("\nMAX");
    max_fixed_point_value = get_max_fixed_point(n_bits-q_bits, q_bits);
    $display("max_fixed_point_value = %f", max_fixed_point_value);

    $display("\nMIN");
    min_fixed_point_value = get_min_fixed_point(n_bits-q_bits);
    $display("min_fixed_point_value = %f", min_fixed_point_value);

    // -------------------------------------------------------------------------

    $display("\nTEST 1");
    float_number   = -1.0;
    overflow       = check_if_overflow(float_number, n_bits-q_bits, q_bits);
    fixed_number   = float_to_fixed_point(float_number, q_bits);
    fixed_number_b = fixed_number;

    $display("float_number = %f",  float_number);
    $display("overflow     = %0d", overflow);
    $display("fixed_number = %b",  fixed_number_b);
    $display("convert back = %f",  fixed_point_to_float(fixed_number_b, n_bits-q_bits, q_bits));

    // -------------------------------------------------------------------------

    $display("\nTEST 2");
    float_number   = -2.0;
    overflow       = check_if_overflow(float_number, n_bits-q_bits, q_bits);
    fixed_number   = float_to_fixed_point(float_number, q_bits);
    fixed_number_b = fixed_number;

    $display("float_number = %f",  float_number);
    $display("overflow     = %0d", overflow);
    $display("fixed_number = %b",  fixed_number_b);
    $display("convert back = %f",  fixed_point_to_float(fixed_number_b, n_bits-q_bits, q_bits));

    // -------------------------------------------------------------------------

    $display("\nTEST 3");
    float_number   = -0.5;
    overflow       = check_if_overflow(float_number, n_bits-q_bits, q_bits);
    fixed_number   = float_to_fixed_point(float_number, q_bits);
    fixed_number_b = fixed_number;

    $display("float_number = %f",  float_number);
    $display("overflow     = %0d", overflow);
    $display("fixed_number = %b",  fixed_number_b);
    $display("convert back = %f",  fixed_point_to_float(fixed_number_b, n_bits-q_bits, q_bits));

    // -------------------------------------------------------------------------

    $display("\nTEST 4");
    float_number   = -0.75;
    overflow       = check_if_overflow(float_number, n_bits-q_bits, q_bits);
    fixed_number   = float_to_fixed_point(float_number, q_bits);
    fixed_number_b = fixed_number;

    $display("float_number = %f",  float_number);
    $display("overflow     = %0d", overflow);
    $display("fixed_number = %b",  fixed_number_b);
    $display("convert back = %f",  fixed_point_to_float(fixed_number_b, n_bits-q_bits, q_bits));

    // -------------------------------------------------------------------------

    $display("\nTEST 5");
    float_number   = -8.0;
    overflow       = check_if_overflow(float_number, n_bits-q_bits, q_bits);
    fixed_number   = float_to_fixed_point(float_number, q_bits);
    fixed_number_b = fixed_number;

    $display("float_number = %f",  float_number);
    $display("overflow     = %0d", overflow);
    $display("fixed_number = %b",  fixed_number_b);
    $display("convert back = %f",  fixed_point_to_float(fixed_number_b, n_bits-q_bits, q_bits));

    // -------------------------------------------------------------------------

    $display("\nTEST 6");
    float_number   = -3.14;
    overflow       = check_if_overflow(float_number, n_bits-q_bits, q_bits);
    fixed_number   = float_to_fixed_point(float_number, q_bits);
    fixed_number_b = fixed_number;

    $display("float_number = %f",  float_number);
    $display("overflow     = %0d", overflow);
    $display("fixed_number = %b",  fixed_number_b);
    $display("convert back = %f",  fixed_point_to_float(fixed_number_b, n_bits-q_bits, q_bits));

    // -------------------------------------------------------------------------

    $display("\nTEST 7");
    float_number   = -2.718;
    overflow       = check_if_overflow(float_number, n_bits-q_bits, q_bits);
    fixed_number   = float_to_fixed_point(float_number, q_bits);
    fixed_number_b = fixed_number;

    $display("float_number = %f",  float_number);
    $display("overflow     = %0d", overflow);
    $display("fixed_number = %b",  fixed_number_b);
    $display("convert back = %f",  fixed_point_to_float(fixed_number_b, n_bits-q_bits, q_bits));

    // -------------------------------------------------------------------------

    $display("\nTEST 8");
    float_number   = 7;
    overflow       = check_if_overflow(float_number, n_bits-q_bits, q_bits);
    fixed_number   = float_to_fixed_point(float_number, q_bits);
    fixed_number_b = fixed_number;

    $display("float_number = %f",  float_number);
    $display("overflow     = %0d", overflow);
    $display("fixed_number = %b",  fixed_number_b);
    $display("convert back = %f",  fixed_point_to_float(fixed_number_b, n_bits-q_bits, q_bits));

  end

endmodule