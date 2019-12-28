`default_nettype none

module osc_square #(
    parameter int square_width_p  = -1
    parameter int counter_width_p = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,

    output logic [square_width_p-1:0]  osc_square,

    input  wire  [counter_width_p-1:0] cr_frequency,
    input  wire  [counter_width_p-1:0] cr_duty_cycle
  );

  localparam logic [counter_width_p-1:0] square_high_c = {1'b0,(counter_width_p-1){1'b1}};
  localparam logic [counter_width_p-1:0] square_low_c  = {1'b1,(counter_width_p-1){1'b0}};

  typedef enum {
    reload_e = 0,
    counting_e
  } state_t;

  logic [counter_width_p-1:0] frequency;
  logic [counter_width_p-1:0] duty_cycle;

  logic [counter_width_p-1:0] osc_counter;

  state_t state;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      osc_square  <= '0;
      frequency   <= '0;
      duty_cycle  <= '0;
      osc_counter <= '0;
      state       <= reload_e;
    end
    else begin

      case (state)

        reload_e: begin

          frequency   <= cr_frequency;
          duty_cycle  <= cr_duty_cycle;
          osc_square  <= square_high_c;
          state       <= counting_e;
          osc_counter <= '0;
        end


        counting_e: begin

          osc_counter <= osc_counter + 1;

          if (osc_counter == duty_cycle-1) begin
            osc_square <= square_low_c;
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