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
