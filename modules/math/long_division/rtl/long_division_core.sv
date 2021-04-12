////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
//
// Dividend
// -------- = Quotient + Remainder
//  Divisor
//
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module long_division_core #(
    parameter int N_BITS_P = -1,
    parameter int Q_BITS_P = -1
  )(
    input  wire                          clk,
    input  wire                          rst_n,

    input  wire                          ing_valid,
    output logic                         ing_ready,
    input  wire  signed [N_BITS_P-1 : 0] ing_dividend,
    input  wire  signed [N_BITS_P-1 : 0] ing_divisor,

    output logic                         egr_valid,
    output logic signed [N_BITS_P-1 : 0] egr_quotient,
    output logic signed [N_BITS_P-1 : 0] egr_remainder,
    output logic                         egr_overflow
  );

  localparam int DIVIDEND_SIZE_C =   N_BITS_P + Q_BITS_P - 1; // Sign bit is removed (below, too)
  localparam int DIVISOR_SIZE_C  = 2*N_BITS_P + Q_BITS_P - 2;
  localparam int QUOTIENT_SIZE_C = 2*N_BITS_P + Q_BITS_P - 2;

  logic         [DIVIDEND_SIZE_C-1 : 0] dividend;
  logic          [DIVISOR_SIZE_C-1 : 0] divisor;
  logic         [QUOTIENT_SIZE_C-1 : 0] quotient;

  logic [$clog2(DIVIDEND_SIZE_C)-1 : 0] counter;
  logic                                 sign_bit;
  logic                                 overflow;

  // The vectors are converted to positive if the were inverted, this is the opposite
  assign egr_quotient  = sign_bit ? -quotient : quotient;
  assign egr_remainder = sign_bit ? -dividend : dividend;
  assign egr_overflow  = overflow;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ing_ready <= '1;
      egr_valid <= '0;
      dividend  <= '0;
      divisor   <= '0;
      quotient  <= '0;
      overflow  <= '0;
      sign_bit  <= '0;
      counter   <= '0;
    end
    else begin

      ing_ready <= '1;
      egr_valid <= '0;

      if (ing_ready && ing_valid) begin

        ing_ready <= 1'b0;
        counter   <= DIVIDEND_SIZE_C;
        quotient  <= 0;
        dividend  <= 0;
        divisor   <= 0;
        overflow  <= 1'b0;

        // Left-alignment of the dividend and if (the removed) sign is negative the vector is inversed
        if (ing_dividend[N_BITS_P-1]) begin
          dividend[DIVIDEND_SIZE_C-1 : Q_BITS_P] <= -ing_dividend[N_BITS_P-2 : 0];
        end
        else begin
          dividend[DIVIDEND_SIZE_C-1 : Q_BITS_P] <=  ing_dividend[N_BITS_P-2 : 0];
        end

        // Left-alignment of the divisor and if (the removed) sign is negative the vector is inversed
        if (ing_divisor[N_BITS_P-1]) begin
          divisor[DIVISOR_SIZE_C-1 : DIVIDEND_SIZE_C] <= -ing_divisor[N_BITS_P-2 : 0];
        end
        else begin
          divisor[DIVISOR_SIZE_C-1 : DIVIDEND_SIZE_C] <=  ing_divisor[N_BITS_P-2 : 0];
        end

        // Sign is saved for converting the calculated quotient and dividend
        sign_bit <= ing_dividend[N_BITS_P-1] ^ ing_divisor[N_BITS_P-1];

      end
      else if (!ing_ready) begin

        ing_ready <= '0;

        if (dividend >= divisor) begin
          dividend <= dividend - divisor;
          quotient <= {quotient[QUOTIENT_SIZE_C-2 : 0], 1'b1};
        end
        else begin
          quotient <= {quotient[QUOTIENT_SIZE_C-2 : 0], 1'b0};
        end

        divisor <= divisor >> 1;

        if (counter == 0) begin

          ing_ready <= '1;
          egr_valid <= '1;

          if (quotient[QUOTIENT_SIZE_C-1 : N_BITS_P] > 0) begin
            overflow <= '1;
          end

        end
        else begin
          counter <= counter - 1;
        end

      end

    end
  end

endmodule

`default_nettype wire
