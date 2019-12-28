`default_nettype none

module led_pwm #(
    parameter int counter_width_p = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,
    output logic                       pwm,
    input  wire  [counter_width_p-1:0] cr_pwm_duty
  );

  led_pwm_core  #(
    .counter_width_p ( counter_width_p )
  ) led_pwm_core_i0  (
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .pwm             ( pwm             ),
    .cr_pwm_duty     ( cr_pwm_duty     )
  );

endmodule

`default_nettype wire