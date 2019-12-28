`default_nettype none

module clock_enable #(
    parameter int clk_frequency_p = -1,
    parameter int ena_frequency_p = -1
  )(
    input  wire  clk,
    input  wire  rst_n,
    output logic enable
  );

  localparam int nr_of_clk_periods_c = clk_frequency_p / ena_frequency_p;

  localparam logic [$clog2(nr_of_clk_periods_c)-1 : 0] clock_enable_counter;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      enable               <= '0;
      clock_enable_counter <= '0;
    end
    else begin
      enable <= '0;
      if (clock_enable_counter >= nr_of_clk_periods_c-1) begin
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
