`default_nettype none

module iir_biquad_filter_6th_order #(
    parameter int data_width_p    = -1,
    parameter int nr_of_q_bits_p  = -1
  ) (
    // Clock and reset
    input  wire                              clk,
    input  wire                              rst_n,

    // Inputs (x)
    input  wire                              x_valid,
    input  wire  signed [data_width_p-1 : 0] x,

    // Output (y)
    output logic                             y_valid,
    output logic signed [data_width_p-1 : 0] y,

    // Filter coefficients
    input  wire  signed [data_width_p-1 : 0] cr_a1_section_0,
    input  wire  signed [data_width_p-1 : 0] cr_a2_section_0,
    input  wire  signed [data_width_p-1 : 0] cr_gain_k_section_0,
    input  wire  signed [data_width_p-1 : 0] cr_a1_section_1,
    input  wire  signed [data_width_p-1 : 0] cr_a2_section_1,
    input  wire  signed [data_width_p-1 : 0] cr_gain_k_section_1,
    input  wire  signed [data_width_p-1 : 0] cr_a1_section_2,
    input  wire  signed [data_width_p-1 : 0] cr_a2_section_2,
    input  wire  signed [data_width_p-1 : 0] cr_gain_k_section_2
  );

  iir_biquad_filter_2nd_order #(
    .data_width_p      ( data_width_p        ),
    .nr_of_q_bits_p    ( nr_of_q_bits_p      )
  ) iir_biquad_filter_2nd_order_i0 (
    .clk               ( clk                 ),
    .rst_n             ( rst_n               ),
    .x_valid           ( x_valid             ),
    .x                 ( x                   ),
    .y_valid           ( y_valid_section_0   ),
    .y                 ( y_section_0         ),
    .cr_denominator_a1 ( cr_a1_section_0     ),
    .cr_denominator_a2 ( cr_a2_section_0     ),
    .cr_gain_k         ( cr_gain_k_section_0 )
  );

  iir_biquad_filter_2nd_order #(
    .data_width_p      ( data_width_p        ),
    .nr_of_q_bits_p    ( nr_of_q_bits_p      )
  ) iir_biquad_filter_2nd_order_i1 (
    .clk               ( clk                 ),
    .rst_n             ( rst_n               ),
    .x_valid           ( y_valid_section_0   ),
    .x                 ( y_section_0         ),
    .y_valid           ( y_valid_section_1   ),
    .y                 ( y_section_1         ),
    .cr_denominator_a1 ( cr_a1_section_1     ),
    .cr_denominator_a2 ( cr_a2_section_1     ),
    .cr_gain_k         ( cr_gain_k_section_1 )
  );

  iir_biquad_filter_2nd_order #(
    .data_width_p      ( data_width_p        ),
    .nr_of_q_bits_p    ( nr_of_q_bits_p      )
  ) iir_biquad_filter_2nd_order_i2 (
    .clk               ( clk                 ),
    .rst_n             ( rst_n               ),
    .x_valid           ( y_valid_section_1   ),
    .x                 ( y_section_1         ),
    .y_valid           ( y_valid             ),
    .y                 ( y                   ),
    .cr_denominator_a1 ( cr_a1_section_2     ),
    .cr_denominator_a2 ( cr_a2_section_2     ),
    .cr_gain_k         ( cr_gain_k_section_2 )
  );

endmodule

`default_nettype wire