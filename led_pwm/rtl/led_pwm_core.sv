`default_nettype none

module led_pwm_core #(
    parameter int counter_width_p = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,
    output logic                       pwm_led,
    input  wire  [counter_width_p-1:0] cr_pwm_duty
  );

  logic [counter_width_p-1:0] pwm_counter;

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pwm_led     <= '0;
      pwm_counter <= '0;
    end
    else begin
      pwm_counter <= pwm_counter + 1;
      if (pwm_counter == '0) begin
        pwm_led <= 1;
      end
      else begin
        if (pwm_counter == cr_pwm_duty) begin
          pwm_led <= '0;
        end
      end
    end
  end

endmodule

`default_nettype wire