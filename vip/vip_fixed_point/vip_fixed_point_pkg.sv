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

`ifndef VIP_FIXED_POINT_PKG
`define VIP_FIXED_POINT_PKG

package vip_fixed_point_pkg;

  // Converts floating point numbers to fixed point
  // Does not work as wanted to, e.g., for N16Q1;
  // -1.420613 => 1111111111111101 = -1.500000
  // but desired is -1.0
  function int float_to_fixed_point(real float_number, int q);
    if (float_number < 0) begin
      float_to_fixed_point = -int'((-float_number) * (2**q)); // Left shift by Q bits
    end
    else begin
      float_to_fixed_point =  int'(float_number * (2**q)); // Left shift by Q bits
    end
  endfunction

  // Converts fixed point numbers to floating point
  function real fixed_point_to_float(int fixed_point, int n, int q);

    // Necessary to use the shift operator in order to be sure about the sign
    automatic int                   negative = (fixed_point >> (n+q-1)) > 0;
    automatic logic signed [63 : 0] operator = fixed_point; // Used for negative conversion

    if (negative) begin
      // Shift operations to make the operator variable signed
      operator = (operator <<  (64-n-q));
      operator = (operator >>> (64-n-q));
      fixed_point_to_float = (real'(operator) / (2**q)); // Typecasting to preserve the decimals
    end
    else begin
      fixed_point_to_float = real'(fixed_point) / (2**q);
    end
  endfunction

  // Returns the largest positive value some fixed point vector can have
  function real get_max_fixed_point(int n, int q);
    automatic real max_fixed_point = 2**(n-1)-1;
    for (int i = 0; i < q; i++) begin max_fixed_point += 2**(-i-1); end
    get_max_fixed_point = max_fixed_point;
  endfunction

  // Returns the smallest negative value some fixed point vector can have
  function real get_min_fixed_point(int n);
    get_min_fixed_point = -(1 << (n-1));
  endfunction

  // Checks if a real typed number can be stored using n and q bits
  function int check_if_overflow(real float_number, int n, int q);
    automatic real max_fixed_point = get_max_fixed_point(n, q);
    automatic real min_fixed_point = get_min_fixed_point(n);
    check_if_overflow    = !(float_number <= max_fixed_point && float_number >= min_fixed_point);
  endfunction

endpackage

`endif
