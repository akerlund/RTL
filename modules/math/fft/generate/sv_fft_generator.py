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

import fft_get_butterfly_connections as b_fly_cons  # Returns the correct connection between the stage's butterflies
import sv_fft_mux_twiddle_generator  as fft_tf_mux  # Generates the twiddle factors and a MUX for them
import sv_tb_fft_generator           as tb_gen      # Test bench generator
import sv_tb_fft_data_generator      as tb_data_gen # Test bench generator

import math


def fft_generator(N, nr_of_integer_bits, nr_of_fractional_bits, butterfly_type):

  log_N = int(math.log(N,2))

  module_name = 'fft_N%s_Q%s_%s_core' % ( str(N), str(nr_of_integer_bits), str(nr_of_fractional_bits))

  # Module declaration
  fft_gen  = '`default_nettype none\n\n'
  fft_gen += 'module %s #(\n'                            % ( module_name )
  fft_gen += '    parameter int data_width_p    = %s,\n' % ( str(nr_of_integer_bits + nr_of_fractional_bits) )
  fft_gen += '    parameter int nr_of_samples_p = %s,\n' % ( str(N) )
  fft_gen += '    parameter int nr_of_q_bits_p  = %s\n'  % ( str(nr_of_fractional_bits) )
  fft_gen += '''  )(
    // Clock and reset
    input  wire                       clk,
    input  wire                       rst_n,

    // AXI4-S inspired control
    input  wire                       x_valid,
    output logic                      x_ready,
    output logic                      y_valid,

    // Inputs (x)
    input  wire  [data_width_p-1 : 0] x_re [nr_of_samples_p],
    input  wire  [data_width_p-1 : 0] x_im [nr_of_samples_p],

    // Output (y)
    output logic [data_width_p-1 : 0] y_re [nr_of_samples_p],
    output logic [data_width_p-1 : 0] y_im [nr_of_samples_p],

    input  wire                       cr_fft_or_ifft,
    output logic                      sr_overflow,
    output logic                      sr_underflow
  );\n\n'''


  # Generating the twiddle factors and the MUX stages
  tf_localparam, twiddle_factor_mux = fft_tf_mux.sv_fft_mux_twiddle_generator(N, nr_of_integer_bits, nr_of_fractional_bits)

  # Adding all localparam twiddle factors
  fft_gen += tf_localparam


  # Other constants
  fft_gen += '\n'
  fft_gen += '  localparam int N_c      = %s;\n'   % ( str(N)     )
  fft_gen += '  localparam int log2_N_c = %s;\n\n' % ( str(log_N) )


  # Generate the FSM declaration
  fft_gen += '  typedef enum {\n'
  fft_gen += '    stage_0_e = 0,\n'
  for i in range(1,log_N):
    fft_gen += '    stage_' + str(i) + '_e,\n'
  fft_gen += '    stage_output_e\n'
  fft_gen += '  } mux_state_t;\n\n'


  # Logics
  fft_gen += '''
  mux_state_t                mux_state;

  logic                      fft_x_valid;
  logic                      fft_x_ready [N_c/2];
  logic                      fft_y_valid [N_c/2];

  logic [data_width_p-1 : 0] fft_x_re [N_c];
  logic [data_width_p-1 : 0] fft_x_im [N_c];

  logic [data_width_p-1 : 0] fft_y_re [N_c];
  logic [data_width_p-1 : 0] fft_y_im [N_c];

  logic [data_width_p-1 : 0] fft_twiddle_re [N_c/2];
  logic [data_width_p-1 : 0] fft_twiddle_im [N_c/2];

  logic            [N_c-1:0] fft_overflow;
  logic            [N_c-1:0] fft_underflow;

  logic                      fft_y_valid_0;

  assign fft_y_valid_0 = fft_y_valid[0];\n'''


  # Generating the butterflies
  fft_gen += '''
  genvar i;
  generate
    for (i = 0; i < N_c/2; i++) begin
      %s #(
        .data_width_p   ( data_width_p      ),
        .nr_of_q_bits_p ( nr_of_q_bits_p    )
      ) %s_i (
        .clk            ( clk               ),
        .rst_n          ( rst_n             ),
        .x_valid        ( fft_x_valid       ),
        .x_ready        ( fft_x_ready[i]    ),
        .y_valid        ( fft_y_valid[i]    ),
        .x0_re          ( fft_x_re[2*i]     ),
        .x0_im          ( fft_x_im[2*i]     ),
        .x1_re          ( fft_x_re[2*i+1]   ),
        .x1_im          ( fft_x_im[2*i+1]   ),
        .y0_re          ( fft_y_re[2*i]     ),
        .y0_im          ( fft_y_im[2*i]     ),
        .y1_re          ( fft_y_re[2*i+1]   ),
        .y1_im          ( fft_y_im[2*i+1]   ),
        .cr_twiddle_re  ( fft_twiddle_re[i] ),
        .cr_twiddle_im  ( fft_twiddle_im[i] ),
        .sr_overflow    ( fft_overflow[i]   ),
        .sr_underflow   ( fft_underflow[i]  )
      );
    end
  endgenerate\n''' % (butterfly_type, butterfly_type)


  # The data routing MUX from butterflies y_out to x_in
  fft_gen += '''
  always_ff @ (posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      mux_state    <= stage_0_e;
      x_ready      <= '0;
      y_valid      <= '0;
      sr_overflow  <= '0;
      sr_underflow <= '0;
      fft_x_valid  <= '0;
      y_re         <= '{default:0};
      y_im         <= '{default:0};
      fft_x_re     <= '{default:0};
      fft_x_im     <= '{default:0};
    end
    else begin

      x_ready     <= '0;
      y_valid     <= '0;
      fft_x_valid <= '0;

      // Overflow and overflow detection
      if (mux_state != stage_0_e) begin
        if (fft_overflow) begin
          sr_overflow  <= 1;
        end
        if (fft_underflow) begin
          sr_underflow <= 1;
        end
      end
      else begin
        sr_overflow  <= '0;
        sr_underflow <= '0;
      end

      case (mux_state)\n'''


  # Adding the MUX's stage zero
  fft_gen += '''
        stage_0_e: begin

          x_ready       <= 1;
          sr_overflow   <= '0;
          sr_underflow  <= '0;

          if (x_valid) begin
            x_ready     <= '0;
            mux_state   <= stage_1_e;
            fft_x_valid <= 1;\n'''

  connections = b_fly_cons.fft_get_butterfly_connections_stage_0(N, log_N)

  for i in range(N):
    butter_wire = connections[i]
    fft_gen += ('            fft_x_re[' + str(i) + ']').ljust(22) + ' <= x_re[' + str(butter_wire) + '];\n'
    fft_gen += ('            fft_x_im[' + str(i) + ']').ljust(22) + ' <= x_im[' + str(butter_wire) + '];\n'

  fft_gen += '          end\n'
  fft_gen += '        end\n\n'


  # Generate all other butterflies data connections
  connections = []
  for i in range(1, log_N):
    connections.append(b_fly_cons.fft_make_butterfly_connections(N, i))


  # Generating the other data MUX stages
  for i in range(0,log_N-1):
    fft_gen += '        stage_%s_e: begin\n\n' % ( str(i+1) )
    fft_gen += '          if (fft_y_valid_0) begin\n'
    fft_gen += '            fft_x_valid <= 1;\n'
    if i+1 != log_N-1:
      fft_gen += '            mux_state   <= stage_%s_e;\n\n' % ( str(i+2) )
    else:
      fft_gen += '            mux_state   <= stage_output_e;\n\n'
    for j in range(N//2):
      fft_gen +=  '            // Butterfly %s\n' % str(j)
      fft_gen += ('            fft_x_re[' + str(2*j)   + ']').ljust(22) + ' <= fft_y_re[' + str(connections[i][2*j])   + '];\n'
      fft_gen += ('            fft_x_im[' + str(2*j)   + ']').ljust(22) + ' <= fft_y_im[' + str(connections[i][2*j])   + '];\n'
      fft_gen += ('            fft_x_re[' + str(2*j+1) + ']').ljust(22) + ' <= fft_y_re[' + str(connections[i][2*j+1]) + '];\n'
      fft_gen += ('            fft_x_im[' + str(2*j+1) + ']').ljust(22) + ' <= fft_y_im[' + str(connections[i][2*j+1]) + '];\n'
    fft_gen += '          end\n'
    fft_gen += '        end\n\n'


  # Generating the final stage
  connections = b_fly_cons.fft_get_butterfly_connections_stage_last(N)
  fft_gen += '        stage_output_e: begin\n'
  fft_gen += '          if (fft_y_valid_0) begin\n'
  fft_gen += '            mux_state <= stage_0_e;\n'
  fft_gen += '            y_valid   <= 1;\n'
  fft_gen += '            if (!cr_fft_or_ifft) begin\n'
  for j in range(N):
    fft_gen += ('              y_re[' + str(j)   + ']').ljust(22) + ' <= fft_y_re[' + str(connections[j])   + '];\n'
    fft_gen += ('              y_im[' + str(j)   + ']').ljust(22) + ' <= fft_y_im[' + str(connections[j])   + '];\n'
  fft_gen += '            end\n'
  fft_gen += '            else begin\n'
  for j in range(N):
    fft_gen += ('              y_re[' + str(j)   + ']').ljust(22) + ' <= fft_y_re[' + str(connections[j])   + '] >>> log2_N_c;\n'
    fft_gen += ('              y_im[' + str(j)   + ']').ljust(22) + ' <= fft_y_im[' + str(connections[j])   + '] >>> log2_N_c;\n'
  fft_gen += '            end\n'
  fft_gen += '          end\n'
  fft_gen += '        end\n\n'

  fft_gen += '      endcase\n'
  fft_gen += '    end\n'
  fft_gen += '  end\n'

  # Adding the twiddle factor data MUX
  fft_gen += twiddle_factor_mux

  # Done
  fft_gen += 'endmodule\n'
  fft_gen += '`default_nettype wire'


  file_name = '../rtl/%s.sv' % module_name
  with open(file_name, 'w+') as fft_file:
    fft_file.write(fft_gen)



if __name__ == '__main__':

  butterfly_types = [
    'fft_butterfly_lite_2',
    'fft_butterfly_lite_4'
    ]

  # FFT size
  N                     = 8
  # Nr of integer bits, including the sign bit
  nr_of_integer_bits    = 10
  # Nr of decimal bits
  nr_of_fractional_bits = 6

  # Used butterfly type
  butterfly_type        = butterfly_types[1]

  # How many test vectors to be generated
  tb_nr_of_test_data    = 64

  print('Generating System Verilog FFT with settings:')
  print('FFT size (N)    = %d' % N)
  print('Integer bits    = %d' % nr_of_integer_bits)
  print('Fractional bits = %d' % nr_of_fractional_bits)

  print('Generate the RTL file')
  fft_generator(N, nr_of_integer_bits, nr_of_fractional_bits, butterfly_type)

  print('Generate the TB file')
  tb_gen.fft_tb_generator(N, nr_of_integer_bits, nr_of_fractional_bits)

  print('Generate the TB data')
  tb_data_gen.generate_tb_fft_data(tb_nr_of_test_data, N, nr_of_integer_bits, nr_of_fractional_bits)