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

import vip_dsp_pkg::*;

module tb_vip_dsp_pkg;

  real      f0;
  real      fs;
  real      q;
  bq_type_t bq_type;
  biquad_coefficients_t coef;

  initial begin

    f0      = 5000.0;
    fs      = 48000.0;
    q       = 1;
    bq_type = BQ_LP_E;

    coef = biquad_coefficients(f0, fs, q, bq_type);

    $display("--------------------------------------------------------------------------------");
    $display("- Bi-Quad Parameters");
    $display("--------------------------------------------------------------------------------");
    $display("f0 = %f", f0);
    $display("fs = %f", fs);
    $display("q  = %f", q);

    $display("\n\n");
    $display("--------------------------------------------------------------------------------");
    $display("- Bi-Quad Coefficients");
    $display("--------------------------------------------------------------------------------");

    $display("w0 = %f", coef.w0);
    $display("a  = %f", coef.alfa);
    $display("b0 = %f", coef.b0);
    $display("b1 = %f", coef.b1);
    $display("b2 = %f", coef.b2);
    $display("a0 = %f", coef.a0);
    $display("a1 = %f", coef.a1);
    $display("a2 = %f", coef.a2);

  end

endmodule