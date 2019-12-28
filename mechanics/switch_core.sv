`default_nettype none

module switch_core #(
    parameter int nr_of_debounce_clks_p = 1000000
  )(
    input  wire  clk,
    input  wire  rst_n,
    input  wire  switch_in_pin,
    output logic switch_out
  );

  logic synchronized_switch;
  logic synchronized_switch_d0;

  io_synchronizer io_synchronizer_i0 (
    .clk         ( clk                 ),
    .rst_n       ( rst_n               ),
    .bit_ingress ( switch_in_pin       ),
    .bit_egress  ( synchronized_switch )
  );

  // Debouncer
  always_ff @( posedge clk or negedge rst_n ) begin
    int debounce_counter_v;
    if (!rst_n) begin
      switch_out             <= '0;
      synchronized_switch_d0 <= '0;
      debounce_counter_v     <= '0;
    end
    else begin
      debounce_counter_v <= '0;
     	if ( synchronized_switch_d0 != synchronized_switch ) begin
        if ( debounce_counter_v == nr_of_debounce_clks_p ) begin
          synchronized_switch_d0 <= switch_out;
          debounce_counter_v     <= '0;
          switch_out             <= switch_out;
        end
        else begin
          debounce_counter_v     <= debounce_counter_v + 1;
        end
      end
    end
  end

endmodule

`default_nettype wire