////////////////////////////////////////////////////////////////////////////////
// cocotb entry point for the examples/template module.
//
// `dummy` is a fully empty module (no ports, no signals) -- Verilator's VPI
// scope population can't find a root handle for a truly empty top (nothing
// visible via VPI), so this thin wrapper gives cocotb a top with at least a
// clk/rst_n pair to grab, and instantiates `dummy` inside it.
////////////////////////////////////////////////////////////////////////////////

module tb_top (
    input wire clk,
    input wire rst_n
  );

  dummy dummy_i0();

endmodule
