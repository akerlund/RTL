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
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module nq_multiplier #(
    parameter N_BITS_P = 32,
    parameter Q_BITS_P = 15
  )(
    input  wire                   clk,
    input  wire                   rst_n,

    input  wire                   ing_valid,
    output logic                  ing_ready,
    input  wire  [N_BITS_P-1 : 0] ing_multiplicand,
    input  wire  [N_BITS_P-1 : 0] ing_multiplier,

    output logic                  egr_valid,
    output logic [N_BITS_P-1 : 0] egr_product,
    output logic                  egr_overflow
  );

  logic       [2*N_BITS_P-2 : 0] multiplier_r0;
  logic         [N_BITS_P-1 : 0] multiplicand_r0;
  logic       [2*N_BITS_P-2 : 0] product_r0;
  logic   [$clog2(N_BITS_P) : 0] counter;

  logic                          sign_bit;
  logic                          is_multiplying;


  assign egr_product[N_BITS_P-2:0] = product_r0[(N_BITS_P + Q_BITS_P)-2 : Q_BITS_P];
  assign egr_product[N_BITS_P-1]   = sign_bit;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // Ports
      ing_ready       <= '0;
      egr_valid       <= '0;
      egr_overflow    <= '0;

      // Registers
      multiplier_r0   <= '0;
      multiplicand_r0 <= '0;
      product_r0      <= '0;
      counter         <= '0;
      sign_bit        <= '0;
      ing_ready       <= '0;
      is_multiplying  <= '0;

    end
    else begin

      ing_ready <= '1;
      egr_valid <= '0;

      if (!is_multiplying && ing_valid) begin

        egr_valid  <= '0;
        ing_ready  <= '0;
        counter    <= '0;
        product_r0 <= '0;

        // Remove sign bit
        multiplicand_r0 <= ing_multiplicand[N_BITS_P-2 : 0];
        multiplier_r0   <= ing_multiplier[N_BITS_P-2 : 0];

        if (!(|ing_multiplicand) || !(|ing_multiplier)) begin // Approximately 19 LUT logic
          egr_valid <= '1;
          sign_bit  <= '0;
        end else begin
          is_multiplying <= '1;
          sign_bit       <= ing_multiplicand[N_BITS_P-1] ^ ing_multiplier[N_BITS_P-1];
        end
      end
      else if (is_multiplying) begin

        ing_ready  <= '0;

        if (multiplicand_r0[counter]) begin
          product_r0 <= product_r0 + multiplier_r0;
        end

        multiplier_r0 <= multiplier_r0 << 1;
        counter       <= counter + 1;

        if (counter == N_BITS_P-1) begin

          egr_valid      <= 1'b1;
          ing_ready      <= '1;
          is_multiplying <= '0;

          if (product_r0[2*N_BITS_P-2 : N_BITS_P-1 + Q_BITS_P] > 0) begin
            egr_overflow <= 1'b1;
          end

        end
      end
    end
  end

endmodule

`default_nettype wire
