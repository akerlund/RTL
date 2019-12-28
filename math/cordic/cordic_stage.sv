`default_nettype none

module cordic_stage #(
    parameter int width_p = 16
  )(
    input  wire                clk,
    input  wire                rst,
    input  wire                enable,
    input  wire  [width_p-1:0] x_vector_i,
    input  wire  [width_p-1:0] y_vector_i,
    input  wire         [31:0] angle_i,
    output logic [width_p-1:0] sine_o,
    output logic [width_p-1:0] cosine_o
 );

  // Generate table of atan values
  logic signed [31:0] atan_table [0:30];

  assign atan_table[00] = 'b00100000000000000000000000000000; // 45.000 degrees -> atan(2^0)
  assign atan_table[01] = 'b00010010111001000000010100011101; // 26.565 degrees -> atan(2^-1)
  assign atan_table[02] = 'b00001001111110110011100001011011; // 14.036 degrees -> atan(2^-2)
  assign atan_table[03] = 'b00000101000100010001000111010100; // atan(2^-3)
  assign atan_table[04] = 'b00000010100010110000110101000011;
  assign atan_table[05] = 'b00000001010001011101011111100001;
  assign atan_table[06] = 'b00000000101000101111011000011110;
  assign atan_table[07] = 'b00000000010100010111110001010101;
  assign atan_table[08] = 'b00000000001010001011111001010011;
  assign atan_table[09] = 'b00000000000101000101111100101110;
  assign atan_table[10] = 'b00000000000010100010111110011000;
  assign atan_table[11] = 'b00000000000001010001011111001100;
  assign atan_table[12] = 'b00000000000000101000101111100110;
  assign atan_table[13] = 'b00000000000000010100010111110011;
  assign atan_table[14] = 'b00000000000000001010001011111001;
  assign atan_table[15] = 'b00000000000000000101000101111100;
  assign atan_table[16] = 'b00000000000000000010100010111110;
  assign atan_table[17] = 'b00000000000000000001010001011111;
  assign atan_table[18] = 'b00000000000000000000101000101111;
  assign atan_table[19] = 'b00000000000000000000010100010111;
  assign atan_table[20] = 'b00000000000000000000001010001011;
  assign atan_table[21] = 'b00000000000000000000000101000101;
  assign atan_table[22] = 'b00000000000000000000000010100010;
  assign atan_table[23] = 'b00000000000000000000000001010001;
  assign atan_table[24] = 'b00000000000000000000000000101000;
  assign atan_table[25] = 'b00000000000000000000000000010100;
  assign atan_table[26] = 'b00000000000000000000000000001010;
  assign atan_table[27] = 'b00000000000000000000000000000101;
  assign atan_table[28] = 'b00000000000000000000000000000010;
  assign atan_table[29] = 'b00000000000000000000000000000001;
  assign atan_table[30] = 'b00000000000000000000000000000000;

  logic signed [width_p:0] x_vector [0:width_p-1];
  logic signed [width_p:0] y_vector [0:width_p-1];
  logic signed      [31:0] z_vector [0:width_p-1];
  logic              [1:0] quadrant;

  assign quadrant = angle_i[31:30];

  always @(posedge clk)
  begin
    // Make sure the rotation angle is in the -pi/2 to pi/2 range
    case(quadrant)
      2'b00, 2'b11:
      begin
        // No changes needed for these quadrants
        x_vector[0] <= x_vector_i;
        y_vector[0] <= y_vector_i;
        z_vector[0] <= angle_i;
      end

      2'b01:
      begin
        x_vector[0] <= -y_vector_i;
        y_vector[0] <=  x_vector_i;
        z_vector[0] <= {2'b00, angle_i[29:0]}; // Subtract pi/2 for angle in this quadrant
      end

      2'b10:
      begin
        x_vector[0] <=  y_vector_i;
        y_vector[0] <= -x_vector_i;
        z_vector[0] <= {2'b11, angle_i[29:0]}; // Add pi/2 to angles in this quadrant
      end
    endcase
  end

  genvar i;
  generate
    for (i = 0; i < (width_p-1); i = i + 1) begin: cordic_pipeline

      logic                    z_sign;
      logic signed [width_p:0] x_shr;
      logic signed [width_p:0] y_shr;

      // Arithmetic right shift (>>>) fills with value of sign bit if expression is signed
      assign x_shr = x_vector[i] >>> i;
      assign y_shr = y_vector[i] >>> i;

      // The sign of the current rotation angle
      assign z_sign = z_vector[i][31];

      always @(posedge clk)
      begin
        x_vector[i+1] <= z_sign ? x_vector[i] + y_shr         : x_vector[i] - y_shr;
        y_vector[i+1] <= z_sign ? y_vector[i] - x_shr         : y_vector[i] + x_shr;
        z_vector[i+1] <= z_sign ? z_vector[i] + atan_table[i] : z_vector[i] - atan_table[i];
      end
    end
  endgenerate

  assign sine_o   = y_vector[width_p-1];
  assign cosine_o = x_vector[width_p-1];

endmodule

`default_nettype wire