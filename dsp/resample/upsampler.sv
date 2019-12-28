`default_nettype none

module upsampler #(
    parameter int  data_width_p       = -1,
    parameter int  interpolation_L_p  = -1,
    parameter real clk_frequency_p    = -1,
    parameter real sample_frequency_p = -1
  )(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     x_valid,
    input  wire  [data_width_p-1:0] x,
    output logic                    y_valid,
    output logic [data_width_p-1:0] y
  );

  localparam logic [$log2(T_upsample_counter_c)-1 : 0] T_upsample_counter_c = int'(clk_frequency_p / sample_frequency_p / interpolation_L_p);
  localparam logic [$log2(T_upsample_counter_c)-1 : 0] interpolation_L_c    = interpolation_L_p;

  logic [$log2(T_upsample_counter_c)-1 : 0] period_counter;
  logic [$log2(T_upsample_counter_c)-1 : 0] sample_counter;

  typedef enum {
    wait_for_sample_e = 0,
    upsampling_e
  } state_t;

  state_t upsampler_state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      y_valid          <= '0;
      y                <= '0;
      upsampler_state  <= wait_for_sample_e;
      upsample_counter <= '0;
      period_counter   <= '0;
      sample_counter   <= '0;
    end
    else begin

      y_valid <= '0;
      y       <= '0;

      case (upsampler_state)

        wait_for_sample_e: begin
          if (x_valid) begin
            upsampler_state <= upsampling_e;
            y_valid         <= '0;
            y               <= x;
            period_counter  <= period_counter + 1;
            sample_counter  <= sample_counter + 1;
          end
        end

        upsampling_e: begin
          if (period_counter == T_upsample_counter_c) begin
            period_counter    <= '0;
            y_valid           <= 1;
            if (sample_counter == interpolation_L_p) begin
              upsampler_state <= wait_for_sample_e;
              sample_counter  <= '0;
            end
            else begin
              sample_counter  <= sample_counter + 1;
            end
          end
          else begin
            period_counter    <= period_counter + 1;
          end
        end

      endcase
    end
  end

endmodule

`default_nettype wire