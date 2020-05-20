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

package iir_biquad_filter_6th_order_coefficients_pkg;


  typedef enum {
    stage0_a1_e = 0,
    stage0_a2_e,
    stage0_k_e,
    stage1_a1_e,
    stage1_a2_e,
    stage1_k_e,
    stage2_a1_e,
    stage2_a2_e,
    stage2_k_e
  } coef_pos_t;

logic [1:0] iir6_Q12_6_Fs48000_Fc20000 = '0;

1.53358969708019721
0.770836848871376934
0.82610663648789362

1.27963242499780905
0.477592250072517155
0.689306168767581551

1.16796636801669385
0.348651393957735423
0.629154440493607359

endpackage