`default_nettype none

module downsampler #(
    parameter int  data_width_p       = -1,
    parameter int  decimation_M_p     = -1
  )(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     x_valid,
    input  wire  [data_width_p-1:0] x,
    output logic                    y_valid,
    output logic [data_width_p-1:0] y
  );

  localparam logic [$log2(decimation_M_p)-1 : 0] decimation_M_c = decimation_M_p;

  logic [$log2(decimation_M_p)-1 : 0] sample_counter;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      y_valid        <= '0;
      y              <= '0;
      sample_counter <= '0;
    end
    else begin

      y_valid <= '0;
      y       <= '0;

      if (x_valid) begin
        if (sample_counter == 0) begin
          y_valid <= 1;
          y       <= x;
        end
        else if (sample_counter == decimation_M_p) begin
          sample_counter <= '0;
        end
        else begin
          sample_counter <= sample_counter + 1;
        end
      end
    end
  end

endmodule

`default_nettype wire