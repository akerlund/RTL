`default_nettype none

module clock_enable #(
    parameter int CLK_FREQUENCY_P = -1,
    parameter int ENA_FREQUENCY_P = -1
  )(
    input  wire  clk,
    input  wire  rst_n,
    output logic enable
  );

  localparam int NR_OF_CLK_PERIODS_C = CLK_FREQUENCY_P / ENA_FREQUENCY_P;

  localparam logic [$clog2(NR_OF_CLK_PERIODS_C)-1 : 0] clock_enable_counter;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      enable               <= '0;
      clock_enable_counter <= '0;
    end
    else begin
      enable <= '0;
      if (clock_enable_counter >= NR_OF_CLK_PERIODS_C-1) begin
        enable               <= 1;
        clock_enable_counter <= '0;
      end
      else begin
        clock_enable_counter <= clock_enable_counter + 1;
      end
    end
  end

endmodule

`default_nettype wire
