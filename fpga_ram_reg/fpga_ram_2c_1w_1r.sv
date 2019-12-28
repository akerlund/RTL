`default_nettype none

module fpga_ram_2c_1w_1r #(
    parameter int data_width_p    = -1,
    parameter int address_width_p = -1
  )(
    input  wire                        clk_port_a,
    input  wire                        port_a_write_en,
    input  wire  [address_width_p-1:0] port_a_address,
    input  wire     [data_width_p-1:0] port_a_data_in,

    input  wire                        clk_port_b,
    input  wire  [address_width_p-1:0] port_b_address,
    output logic    [data_width_p-1:0] port_b_data_out
  );

  logic [data_width_p-1:0] fpga_ram [2**address_width_p-1:0];

  always_ff @ (posedge clk_port_a) begin
    if (port_a_write_en) begin
      fpga_ram[port_a_address] <= port_a_data_in;
    end
  end

  always_ff @ (posedge clk_port_b) begin
    port_b_data_out <= fpga_ram[port_b_address];
    // Simulating collisions
    // synthesis translate_off
    if (port_a_write_en && (port_a_address == port_b_address)) begin
      port_b_data_out <= {data_width_p{1'bx}};
    end
    // synthesis translate_on
  end


endmodule

`default_nettype wire