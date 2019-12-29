`default_nettype none

module rgb_led_pwm_core #(
    parameter int counter_width_p = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,
    output logic                       pwm_red,
    output logic                       pwm_green,
    output logic                       pwm_blue,
    input  wire  [counter_width_p-1:0] cr_pwm_duty_red,
    input  wire  [counter_width_p-1:0] cr_pwm_duty_green,
    input  wire  [counter_width_p-1:0] cr_pwm_duty_blue
  );

  logic [counter_width_p-1:0] pwm_counter;

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pwm_red     <= '0;
      pwm_green   <= '0;
      pwm_blue    <= '0;
      pwm_counter <= '0;
    end
    else begin
      pwm_counter <= pwm_counter + 1;
      if (pwm_counter == '0) begin
        pwm_red   <= 1;
        pwm_green <= 1;
        pwm_blue  <= 1;
      end
      else begin
        if (pwm_counter == cr_pwm_duty_red) begin
          pwm_red <= '0;
        end
        if (pwm_counter == cr_pwm_duty_green) begin
          pwm_green <= '0;
        end
        if (pwm_counter == cr_pwm_duty_blue) begin
          pwm_blue <= '0;
        end
      end
    end
  end

endmodule

`default_nettype wire