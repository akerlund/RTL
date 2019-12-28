`default_nettype none
// Description:

module fft_butterfly_lite_2 #(
    parameter int data_width_p   = -1,
    parameter int nr_of_q_bits_p = -1
  )(
    // Clock and reset
    input  wire                            clk,
    input  wire                            rst_n,
    // AXI4-S inspired control
    input  wire                            x_valid,
    output logic                           x_ready,
    output logic                           y_valid,
    input  wire         [data_width_p-1:0] cr_twiddle_re,
    input  wire         [data_width_p-1:0] cr_twiddle_im,
    // Inputs (x) 'a' and 'b', real and imaginary vectors
    input  wire  signed [data_width_p-1:0] xa_re,
    input  wire  signed [data_width_p-1:0] xa_im,
    input  wire  signed [data_width_p-1:0] xb_re,
    input  wire  signed [data_width_p-1:0] xb_im,
    // Output (y) 'a' and 'b', real and imaginary vectors
    output logic signed [data_width_p-1:0] ya_re,
    output logic signed [data_width_p-1:0] ya_im,
    output logic signed [data_width_p-1:0] yb_re,
    output logic signed [data_width_p-1:0] yb_im
  );

  localparam int mul_high_c = 2*data_width_p - nr_of_q_bits_p;
  localparam int mul_low_c  = nr_of_q_bits_p;

  typedef enum {
    stage_0_e = 0,
    stage_1_e,
    stage_2_e,
    stage_3_e
  } state_t;

  state_t state;

  logic signed [2*data_width_p-1:0] mul_reg_xb_0;
  logic signed [2*data_width_p-1:0] mul_reg_xb_1;

  logic signed     [data_width_p:0] shift_sub_re;
  logic signed     [data_width_p:0] shift_add_im;

  logic          [data_width_p-1:0] shift_sub_re_dbg;
  logic          [data_width_p-1:0] shift_add_im_dbg;

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state        <= stage_0_e;
      x_ready      <= '0;
      y_valid      <= '0;
      ya_re        <= '0;
      ya_im        <= '0;
      yb_re        <= '0;
      yb_im        <= '0;
      mul_reg_xb_0 <= '0;
      mul_reg_xb_1 <= '0;
      shift_sub_re <= '0;
      shift_add_im <= '0;
    end
    else begin

      x_ready <= '0;
      y_valid <= '0;

      case (state)

        stage_0_e: begin
          x_ready <= 1;
          if (x_valid) begin
            state        <= stage_1_e;
            x_ready      <= '0;
            ya_re        <= '0;
            yb_re        <= '0;
            ya_im        <= '0;
            yb_im        <= '0;
            // Real product, sign extending 2-complement factors
            mul_reg_xb_0 <= {{data_width_p{xb_re[data_width_p-1]}}, xb_re} * {{data_width_p{cr_twiddle_re[data_width_p-1]}}, cr_twiddle_re};
            mul_reg_xb_1 <= {{data_width_p{xb_im[data_width_p-1]}}, xb_im} * {{data_width_p{cr_twiddle_im[data_width_p-1]}}, cr_twiddle_im};
          end
        end


        stage_1_e: begin
          state        <= stage_2_e;
          // Imaginary product, sign extending 2-complement factors
          mul_reg_xb_0 <= {{data_width_p{xb_re[data_width_p-1]}}, xb_re} * {{data_width_p{cr_twiddle_im[data_width_p-1]}}, cr_twiddle_im};
          mul_reg_xb_1 <= {{data_width_p{xb_im[data_width_p-1]}}, xb_im} * {{data_width_p{cr_twiddle_re[data_width_p-1]}}, cr_twiddle_re};
          shift_sub_re <= mul_reg_xb_0[mul_high_c-1:mul_low_c] - mul_reg_xb_1[mul_high_c-1:mul_low_c];
        end


        stage_2_e: begin
          state        <= stage_3_e;
          ya_re        <= xa_re + shift_sub_re[data_width_p-1:0];
          yb_re        <= xa_re - shift_sub_re[data_width_p-1:0];
          shift_add_im <= mul_reg_xb_0[mul_high_c-1:mul_low_c] + mul_reg_xb_1[mul_high_c-1:mul_low_c];

        end


        stage_3_e: begin
          state   <= stage_0_e;
          y_valid <= 1;
          ya_im   <= xa_im + shift_add_im[data_width_p-1:0];
          yb_im   <= xa_im - shift_add_im[data_width_p-1:0];
        end

      endcase

    end
  end

endmodule

`default_nettype wire