`default_nettype none

module reset_synchronizer_core (
    input  wire  clk,
    input  wire  rst_async_n,
    output logic rst_sync_n
  );

  logic io_synchronized_rst;
  logic reset_origin_n;

  assign rst_sync_n = reset_origin_n;

  io_synchronizer io_synchronizer_i0 (
    .clk         ( clk                 ),
    .rst_n       ( rst_async_n         ),
    .bit_ingress ( 1'b1                ),
    .bit_egress  ( io_synchronized_rst )
  );

  always_ff @ (posedge clk or negedge rst_async_n) begin
    if (!rst_async_n) begin
      reset_origin_n <= '0;
    end
    else begin
      reset_origin_n <= io_synchronized_rst;
    end
  end

endmodule

`default_nettype wire
