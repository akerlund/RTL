`default_nettype none

module template #(
    parameter para_p = -1
  )(
    input  wire                 clk,
    input  wire                 rst_n,
    output logic [para_p-1 : 0] out_data
  );

  localparam logic [para_p-1 : 0] constant_c = '0;

  typedef enum {
    state_0_e = 0,
    state_1_e
  } state_t;

  state_t state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ;
    end
    else begin
      ;
    end
  end

endmodule

`default_nettype wire
