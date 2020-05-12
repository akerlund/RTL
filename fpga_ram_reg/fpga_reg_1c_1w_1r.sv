`default_nettype none

module fpga_reg_1c_1w_1r #(
    parameter int DATA_WIDTH_P    = -1,
    parameter int ADDRESS_WIDTH_P = -1
  )(
    input  wire                          clk,

    input  wire                          port_a_write_en,
    input  wire  [ADDRESS_WIDTH_P-1 : 0] port_a_address,
    input  wire     [DATA_WIDTH_P-1 : 0] port_a_data_in,

    input  wire  [ADDRESS_WIDTH_P-1 : 0] port_b_address,
    output logic    [DATA_WIDTH_P-1 : 0] port_b_data_out
  );

  logic [DATA_WIDTH_P-1 : 0] fpga_reg [2**ADDRESS_WIDTH_P-1 : 0];

  assign port_b_data_out = fpga_reg[port_b_address];

  always_ff @ (posedge clk) begin
    if (port_a_write_en) begin
      fpga_reg[port_a_address] <= port_a_data_in;
    end
  end

endmodule

`default_nettype wire