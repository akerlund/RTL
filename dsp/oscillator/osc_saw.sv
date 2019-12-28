`default_nettype none

module saw_square #(
    parameter int saw_width_p     = -1
    parameter int counter_width_p = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,

    output logic [saw_width_p-1:0]     saw_square,
    input  wire  [counter_width_p-1:0] cr_frequency
  );

  localparam logic [counter_width_p-1:0] saw_high_c = {1'b0,(counter_width_p-1){1'b1}};
  localparam logic [counter_width_p-1:0] saw_low_c  = {1'b1,(counter_width_p-1){1'b0}};

  typedef enum {
    reload_e = 0,
    counting_e
  } state_t;

  logic [counter_width_p-1:0] frequency;

  logic [counter_width_p-1:0] osc_counter;

  state_t state;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      saw_square  <= '0;
      frequency   <= '0;
      osc_counter <= '0;
      state       <= reload_e;
    end
    else begin

      case (state)

        reload_e: begin

          frequency   <= cr_frequency;
          saw_square  <= saw_high_c;
          state       <= counting_e;
          osc_counter <= '0;
        end


        counting_e: begin

          osc_counter <= osc_counter + 1;

          if (osc_counter == duty_cycle-1) begin
            saw_square <= saw_low_c;
          end
          else if (osc_counter == frequency-1) begin
            state      <= reload_e;
          end
          else begin
          end
        end

      endcase

    end
endmodule

`default_nettype wire