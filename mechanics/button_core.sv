`default_nettype none

module button_core #(
    parameter int nr_of_debounce_clks_p = 1000000,
    parameter     connection_type_p     = "OPEN"
  )(
    input  wire  clk,
    input  wire  rst_n,
    input  wire  button_in_pin,
    output logic button_press_toggle
  );

  logic synchronized_button;
  logic button_in;

  logic button_is_debounced;
  int   button_counter;

  io_synchronizer io_synchronizer_i0 (
    .clk         ( clk                 ),
    .rst_n       ( rst_n               ),
    .bit_ingress ( button_in_pin       ),
    .bit_egress  ( synchronized_button )
  );

  if ( connection_type_p == "OPEN" ) begin
    assign button_in = synchronized_button;
  end

  if ( connection_type_p == "CLOSED" ) begin
    assign button_in = ~synchronized_button;
  end

  // Debouncer
  always_ff @( posedge clk or negedge rst_n ) begin
    if (!rst_n) begin
      button_is_debounced <= '0;
      button_counter      <= '0;
      button_press_toggle <= '0;
    end
    else begin
      button_press_toggle <= '0;
     	if ( button_in && !button_is_debounced ) begin
        if ( button_counter == nr_of_debounce_clks_p ) begin
          button_is_debounced <= 1;
          button_counter      <= '0;
          button_press_toggle <= 1;
        end
        else begin
          button_counter <= button_counter + 1;
        end
      end
      else if ( !button_in && button_is_debounced ) begin
        button_is_debounced <= '0;
      end
    end
  end

endmodule

`default_nettype wire