`default_nettype none

module io_synchronizer_core (
    input  wire  clk,
    input  wire  rst_n,
    input  wire  bit_ingress,
    output logic bit_egress
  );

  logic bit_meta;

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_meta   <= '0;
      bit_egress <= '0;
    end
    else begin
      bit_meta   <= bit_ingress;
      bit_egress <= bit_meta;
    end
  end

endmodule

`default_nettype wire
