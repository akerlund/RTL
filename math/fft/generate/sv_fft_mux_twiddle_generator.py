################################################################################
##
## Copyright (C) 2020 Fredrik Åkerlund
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
## Description:
##
################################################################################

import sv_fft_twiddle_factors_generator as twiddle_gen

def sv_fft_mux_twiddle_generator(N, nr_of_n_bits, nr_of_q_bits):

  # Generate all twiddle factors
  tf = twiddle_gen.get_twiddle_factors(N, nr_of_n_bits, nr_of_q_bits)
  tf_localparam, tf_fft_re, tf_fft_im, tf_ifft_re, tf_ifft_im = tf

  sv_tf_mux = '''\n\n  // Twiddle factor MUX
  always_ff @ (posedge clk or negedge rst_n) begin

    if (!rst_n) begin\n'''

  # Reset
  for i in range(N//2):
      sv_tf_mux += ('      fft_twiddle_re[' + str(i) + '] ').ljust(29) + '<= \'0;\n'
      sv_tf_mux += ('      fft_twiddle_im[' + str(i) + '] ').ljust(29) + '<= \'0;\n'
  sv_tf_mux += '    end\n'

  sv_tf_mux += '    else begin\n'
  sv_tf_mux += '      case (mux_state)\n'
  j = 0
  for stages in range(len(tf_fft_re)):
    sv_tf_mux += '        stage_' + str(j) + '_e: begin\n'
    if not j:
      sv_tf_mux += '          if (x_valid) begin\n'
    else:
      sv_tf_mux += '          if (fft_y_valid_0) begin\n'
    sv_tf_mux += '            if (!cr_fft_or_ifft) begin\n'
    for tf in range(len(tf_fft_re[stages])):
      n = str(tf)
      sv_tf_mux += ('              fft_twiddle_re[' + n + '] ').ljust(29) + '<= ' + tf_fft_re[stages][tf] + ';\n'
      sv_tf_mux += ('              fft_twiddle_im[' + n + '] ').ljust(29) + '<= ' + tf_fft_im[stages][tf] + ';\n'
    sv_tf_mux += '            end\n'
    sv_tf_mux += '            else begin\n'
    for tf in range(len(tf_ifft_re[stages])):
      n = str(tf)
      sv_tf_mux += ('              fft_twiddle_re[' + n + '] ').ljust(29) + '<= ' + tf_ifft_re[stages][tf] + ';\n'
      sv_tf_mux += ('              fft_twiddle_im[' + n + '] ').ljust(29) + '<= ' + tf_ifft_im[stages][tf] + ';\n'
    sv_tf_mux += '            end\n'
    sv_tf_mux += '          end\n'
    j += 1
    sv_tf_mux += '        end\n\n'

  # The default
  sv_tf_mux += '        default: begin\n'
  for i in range(N//2):
      sv_tf_mux += ('          fft_twiddle_re[' + str(i) + '] ').ljust(31) + ' <= fft_twiddle_re[' + str(i) + '];\n'
      sv_tf_mux += ('          fft_twiddle_im[' + str(i) + '] ').ljust(31) + ' <= fft_twiddle_im[' + str(i) + '];\n'
  sv_tf_mux +=  '        end\n\n'



  sv_tf_mux += '      endcase\n'
  sv_tf_mux += '    end\n'
  sv_tf_mux += '  end\n'


  return tf_localparam, sv_tf_mux

if __name__ == '__main__':
  N            = 8
  nr_of_n_bits = 24
  nr_of_q_bits = 16
  sv_tf_mux = sv_fft_mux_twiddle_generator(N, nr_of_n_bits, nr_of_q_bits)
  print(sv_tf_mux)