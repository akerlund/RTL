////////////////////////////////////////////////////////////////////////////////
//
// Description:
//
// Parameterized Fibonacci LFSR.
//
// TAPS_P is the characteristic polynomial bit mask for the feedback XOR.
// For the default 32-bit configuration, 32'h8000_0057 corresponds to:
//   x^32 + x^7 + x^5 + x^3 + x^2 + x^1 + 1
// with the implied x^0 term represented by the XOR feedback.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module lfsr #(
    parameter int                   WIDTH_P = 32,
    parameter logic [WIDTH_P-1 : 0] TAPS_P  = 32'h8000_0057,
    parameter logic [WIDTH_P-1 : 0] SEED_P  = 32'h0000_0001
  )(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  advance,
    input  wire                  cmd_load_seed,
    input  wire  [WIDTH_P-1 : 0] cr_seed,
    output logic [WIDTH_P-1 : 0] value,
    output logic                 bit_out
  );

  logic feedback;
  logic [WIDTH_P-1 : 0] next_state;

  function automatic logic [WIDTH_P-1 : 0] get_valid_seed(
      input logic [WIDTH_P-1 : 0] seed_in
    );
    begin
      if (seed_in == '0) begin
        if (SEED_P == '0) begin
          get_valid_seed = {{(WIDTH_P-1){1'b0}}, 1'b1};
        end
        else begin
          get_valid_seed = SEED_P;
        end
      end
      else begin
        get_valid_seed = seed_in;
      end
    end
  endfunction

  assign feedback   = ^(value & TAPS_P);
  assign next_state = {value[WIDTH_P-2 : 0], feedback};
  assign bit_out    = value[WIDTH_P-1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      value <= get_valid_seed(SEED_P);
    end
    else if (cmd_load_seed) begin
      value <= get_valid_seed(cr_seed);
    end
    else if (advance) begin
      if (value == '0) begin
        value <= get_valid_seed(SEED_P);
      end
      else begin
        value <= next_state;
      end
    end
  end

  initial begin
    if (WIDTH_P < 2) begin
      $error("WIDTH_P must be at least 2");
    end

    if (TAPS_P == '0) begin
      $error("TAPS_P must not be zero");
    end
  end

endmodule

`default_nettype wire
