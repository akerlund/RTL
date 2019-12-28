`default_nettype none

module fft_N8_Q10_6_core #(
    parameter int data_width_p    = 16,
    parameter int nr_of_samples_p = 8,
    parameter int nr_of_q_bits_p  = 6
  )(
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
  );

  localparam logic [15 : 0] pos_1_000000000_c = 16'b0000000001000000;
  localparam logic [15 : 0] pos_0_703125000_c = 16'b0000000000101101;
  localparam logic [15 : 0] pos_0_000000000_c = 16'b0000000000000000;
  localparam logic [15 : 0] neg_0_703125000_c = 16'b1111111111010011;
  localparam logic [15 : 0] neg_1_000000000_c = 16'b1111111111000000;

  localparam int N_c      = 8;
  localparam int log2_N_c = 3;

  typedef enum {
    stage_0_e = 0,
    stage_1_e,
    stage_2_e,
    stage_output_e
  } mux_state_t;


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

  assign fft_y_valid_0 = fft_y_valid[0];

  genvar i;
  generate
    for (i = 0; i < N_c/2; i++) begin
      fft_butterfly_lite_4 #(
        .data_width_p   ( data_width_p      ),
        .nr_of_q_bits_p ( nr_of_q_bits_p    )
      ) fft_butterfly_lite_4_i (
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
  endgenerate

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

      case (mux_state)

        stage_0_e: begin

          x_ready       <= 1;
          sr_overflow   <= '0;
          sr_underflow  <= '0;

          if (x_valid) begin
            x_ready     <= '0;
            mux_state   <= stage_1_e;
            fft_x_valid <= 1;
            fft_x_re[0] <= x_re[0];
            fft_x_im[0] <= x_im[0];
            fft_x_re[1] <= x_re[4];
            fft_x_im[1] <= x_im[4];
            fft_x_re[2] <= x_re[2];
            fft_x_im[2] <= x_im[2];
            fft_x_re[3] <= x_re[6];
            fft_x_im[3] <= x_im[6];
            fft_x_re[4] <= x_re[1];
            fft_x_im[4] <= x_im[1];
            fft_x_re[5] <= x_re[5];
            fft_x_im[5] <= x_im[5];
            fft_x_re[6] <= x_re[3];
            fft_x_im[6] <= x_im[3];
            fft_x_re[7] <= x_re[7];
            fft_x_im[7] <= x_im[7];
          end
        end

        stage_1_e: begin

          if (fft_y_valid_0) begin
            fft_x_valid <= 1;
            mux_state   <= stage_2_e;

            // Butterfly 0
            fft_x_re[0] <= fft_y_re[0];
            fft_x_im[0] <= fft_y_im[0];
            fft_x_re[1] <= fft_y_re[2];
            fft_x_im[1] <= fft_y_im[2];
            // Butterfly 1
            fft_x_re[2] <= fft_y_re[1];
            fft_x_im[2] <= fft_y_im[1];
            fft_x_re[3] <= fft_y_re[3];
            fft_x_im[3] <= fft_y_im[3];
            // Butterfly 2
            fft_x_re[4] <= fft_y_re[4];
            fft_x_im[4] <= fft_y_im[4];
            fft_x_re[5] <= fft_y_re[6];
            fft_x_im[5] <= fft_y_im[6];
            // Butterfly 3
            fft_x_re[6] <= fft_y_re[5];
            fft_x_im[6] <= fft_y_im[5];
            fft_x_re[7] <= fft_y_re[7];
            fft_x_im[7] <= fft_y_im[7];
          end
        end

        stage_2_e: begin

          if (fft_y_valid_0) begin
            fft_x_valid <= 1;
            mux_state   <= stage_output_e;

            // Butterfly 0
            fft_x_re[0] <= fft_y_re[0];
            fft_x_im[0] <= fft_y_im[0];
            fft_x_re[1] <= fft_y_re[4];
            fft_x_im[1] <= fft_y_im[4];
            // Butterfly 1
            fft_x_re[2] <= fft_y_re[2];
            fft_x_im[2] <= fft_y_im[2];
            fft_x_re[3] <= fft_y_re[6];
            fft_x_im[3] <= fft_y_im[6];
            // Butterfly 2
            fft_x_re[4] <= fft_y_re[1];
            fft_x_im[4] <= fft_y_im[1];
            fft_x_re[5] <= fft_y_re[5];
            fft_x_im[5] <= fft_y_im[5];
            // Butterfly 3
            fft_x_re[6] <= fft_y_re[3];
            fft_x_im[6] <= fft_y_im[3];
            fft_x_re[7] <= fft_y_re[7];
            fft_x_im[7] <= fft_y_im[7];
          end
        end

        stage_output_e: begin
          if (fft_y_valid_0) begin
            mux_state <= stage_0_e;
            y_valid   <= 1;
            if (!cr_fft_or_ifft) begin
              y_re[0]  <= fft_y_re[0];
              y_im[0]  <= fft_y_im[0];
              y_re[1]  <= fft_y_re[2];
              y_im[1]  <= fft_y_im[2];
              y_re[2]  <= fft_y_re[4];
              y_im[2]  <= fft_y_im[4];
              y_re[3]  <= fft_y_re[6];
              y_im[3]  <= fft_y_im[6];
              y_re[4]  <= fft_y_re[1];
              y_im[4]  <= fft_y_im[1];
              y_re[5]  <= fft_y_re[3];
              y_im[5]  <= fft_y_im[3];
              y_re[6]  <= fft_y_re[5];
              y_im[6]  <= fft_y_im[5];
              y_re[7]  <= fft_y_re[7];
              y_im[7]  <= fft_y_im[7];
            end
            else begin
              y_re[0]  <= fft_y_re[0] >>> log2_N_c;
              y_im[0]  <= fft_y_im[0] >>> log2_N_c;
              y_re[1]  <= fft_y_re[2] >>> log2_N_c;
              y_im[1]  <= fft_y_im[2] >>> log2_N_c;
              y_re[2]  <= fft_y_re[4] >>> log2_N_c;
              y_im[2]  <= fft_y_im[4] >>> log2_N_c;
              y_re[3]  <= fft_y_re[6] >>> log2_N_c;
              y_im[3]  <= fft_y_im[6] >>> log2_N_c;
              y_re[4]  <= fft_y_re[1] >>> log2_N_c;
              y_im[4]  <= fft_y_im[1] >>> log2_N_c;
              y_re[5]  <= fft_y_re[3] >>> log2_N_c;
              y_im[5]  <= fft_y_im[3] >>> log2_N_c;
              y_re[6]  <= fft_y_re[5] >>> log2_N_c;
              y_im[6]  <= fft_y_im[5] >>> log2_N_c;
              y_re[7]  <= fft_y_re[7] >>> log2_N_c;
              y_im[7]  <= fft_y_im[7] >>> log2_N_c;
            end
          end
        end

      endcase
    end
  end


  // Twiddle factor MUX
  always_ff @ (posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      fft_twiddle_re[0]      <= '0;
      fft_twiddle_im[0]      <= '0;
      fft_twiddle_re[1]      <= '0;
      fft_twiddle_im[1]      <= '0;
      fft_twiddle_re[2]      <= '0;
      fft_twiddle_im[2]      <= '0;
      fft_twiddle_re[3]      <= '0;
      fft_twiddle_im[3]      <= '0;
    end
    else begin
      case (mux_state)
        stage_0_e: begin
          if (x_valid) begin
            if (!cr_fft_or_ifft) begin
              fft_twiddle_re[0] <= pos_1_000000000_c;
              fft_twiddle_im[0] <= pos_0_000000000_c;
              fft_twiddle_re[1] <= pos_1_000000000_c;
              fft_twiddle_im[1] <= pos_0_000000000_c;
              fft_twiddle_re[2] <= pos_1_000000000_c;
              fft_twiddle_im[2] <= pos_0_000000000_c;
              fft_twiddle_re[3] <= pos_1_000000000_c;
              fft_twiddle_im[3] <= pos_0_000000000_c;
            end
            else begin
              fft_twiddle_re[0] <= pos_1_000000000_c;
              fft_twiddle_im[0] <= pos_0_000000000_c;
              fft_twiddle_re[1] <= pos_1_000000000_c;
              fft_twiddle_im[1] <= pos_0_000000000_c;
              fft_twiddle_re[2] <= pos_1_000000000_c;
              fft_twiddle_im[2] <= pos_0_000000000_c;
              fft_twiddle_re[3] <= pos_1_000000000_c;
              fft_twiddle_im[3] <= pos_0_000000000_c;
            end
          end
        end

        stage_1_e: begin
          if (fft_y_valid_0) begin
            if (!cr_fft_or_ifft) begin
              fft_twiddle_re[0] <= pos_1_000000000_c;
              fft_twiddle_im[0] <= pos_0_000000000_c;
              fft_twiddle_re[1] <= pos_0_000000000_c;
              fft_twiddle_im[1] <= neg_1_000000000_c;
              fft_twiddle_re[2] <= pos_1_000000000_c;
              fft_twiddle_im[2] <= pos_0_000000000_c;
              fft_twiddle_re[3] <= pos_0_000000000_c;
              fft_twiddle_im[3] <= neg_1_000000000_c;
            end
            else begin
              fft_twiddle_re[0] <= pos_1_000000000_c;
              fft_twiddle_im[0] <= pos_0_000000000_c;
              fft_twiddle_re[1] <= pos_0_000000000_c;
              fft_twiddle_im[1] <= pos_1_000000000_c;
              fft_twiddle_re[2] <= pos_1_000000000_c;
              fft_twiddle_im[2] <= pos_0_000000000_c;
              fft_twiddle_re[3] <= pos_0_000000000_c;
              fft_twiddle_im[3] <= pos_1_000000000_c;
            end
          end
        end

        stage_2_e: begin
          if (fft_y_valid_0) begin
            if (!cr_fft_or_ifft) begin
              fft_twiddle_re[0] <= pos_1_000000000_c;
              fft_twiddle_im[0] <= pos_0_000000000_c;
              fft_twiddle_re[1] <= pos_0_703125000_c;
              fft_twiddle_im[1] <= neg_0_703125000_c;
              fft_twiddle_re[2] <= pos_0_000000000_c;
              fft_twiddle_im[2] <= neg_1_000000000_c;
              fft_twiddle_re[3] <= neg_0_703125000_c;
              fft_twiddle_im[3] <= neg_0_703125000_c;
            end
            else begin
              fft_twiddle_re[0] <= pos_1_000000000_c;
              fft_twiddle_im[0] <= pos_0_000000000_c;
              fft_twiddle_re[1] <= pos_0_703125000_c;
              fft_twiddle_im[1] <= pos_0_703125000_c;
              fft_twiddle_re[2] <= pos_0_000000000_c;
              fft_twiddle_im[2] <= pos_1_000000000_c;
              fft_twiddle_re[3] <= neg_0_703125000_c;
              fft_twiddle_im[3] <= pos_0_703125000_c;
            end
          end
        end

        default: begin
          fft_twiddle_re[0]     <= fft_twiddle_re[0];
          fft_twiddle_im[0]     <= fft_twiddle_im[0];
          fft_twiddle_re[1]     <= fft_twiddle_re[1];
          fft_twiddle_im[1]     <= fft_twiddle_im[1];
          fft_twiddle_re[2]     <= fft_twiddle_re[2];
          fft_twiddle_im[2]     <= fft_twiddle_im[2];
          fft_twiddle_re[3]     <= fft_twiddle_re[3];
          fft_twiddle_im[3]     <= fft_twiddle_im[3];
        end

      endcase
    end
  end
endmodule
`default_nettype wire