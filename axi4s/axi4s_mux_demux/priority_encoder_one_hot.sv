////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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

module priority_encoder_one_hot (
    input   wire [7:0] uncoded,
    output logic [2:0] encoded,
    output logic [2:0] encoded_valid
  );

  always_comb begin
    case(uncoded)

      8'b00000001: begin
        encoded       <= 3'b000;
        encoded_valid <= 1'b1;
      end

      8'b0000001x: begin
        encoded       <= 3'b001;
        encoded_valid <= 1'b1;
      end

      8'b000001xx: begin
        encoded       <= 3'b010;
        encoded_valid <= 1'b1;
      end

      8'b00001xxx: begin
        encoded       <= 3'b011;
        encoded_valid <= 1'b1;
      end

      8'b0001xxxx: begin
        encoded       <= 3'b100;
        encoded_valid <= 1'b1;
      end

      8'b001xxxxx: begin
        encoded       <= 3'b101;
        encoded_valid <= 1'b1;
      end

      8'b01xxxxxx: begin
        encoded       <= 3'b110;
        encoded_valid <= 1'b1;
      end

      8'b1xxxxxxx: begin
        encoded       <= 3'b111;
        encoded_valid <= 1'b1;
      end

      default: begin
        encoded       <= 3'b000;
        encoded_valid <= 1'b0;
      end

    endcase
  end

endmodule

`default_nettype wire
