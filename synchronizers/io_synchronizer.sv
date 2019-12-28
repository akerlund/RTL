`default_nettype none

// By using a wrapper around the core we will always find any instance
// of 'io_synchronizer_core_i0' within a 'io_synchronizerX'.
// Thus, we can constraint them all with, e.g.,
// set_property -quiet ASYNC_REG TRUE [get_cells -hier -regexp .*io_synchronizer_core_i0/bit_egress.*]

module io_synchronizer (
    input  wire  clk,
    input  wire  rst_n,
    input  wire  bit_ingress,
    output logic bit_egress
  );

  io_synchronizer_core io_synchronizer_core_i0(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .bit_ingress ( bit_ingress ),
    .bit_egress  ( bit_egress  )
  );

endmodule

`default_nettype wire
