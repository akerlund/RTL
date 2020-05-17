`default_nettype none

module delay_enable #(
    parameter int CLK_PERIOD_P = -1,
    parameter int DELAY_NS_P   = -1
  )(
    input  wire  clk,
    input  wire  rst_n,
    input  wire  start,
    output logic delay_out
  );

  localparam int nr_of_clk_periods_c = DELAY_NS_P / CLK_PERIOD_P;
  localparam logic [$clog2(nr_of_clk_periods_c)-1 : 0] delay_counter;

  int delaying;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      delay_out     <= '0;
      delaying      <= '0;
      delay_counter <= '0;
    end
    else begin

      delay_out <= '0;

      if (delaying == '0 && start == 1) begin
        delaying      <= '1;
        delay_counter <= '0;
      end
      else begin
        if (delaying == '1) begin
          if (delay_counter >= nr_of_clk_periods_c-1) begin
            delaying  <= '0;
            delay_out <= '1;
          end
          else begin
            delay_counter <= delay_counter + 1;
          end
        end
      end
    end
  end

endmodule

`default_nettype wire
