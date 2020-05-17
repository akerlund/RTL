`timescale 1ns/1ps

module tb_color_hsl_12bit_color;

  logic clk_125;
  logic res_n;

  logic        valid_hue;
  logic [11:0] hue;
  logic [11:0] saturation;
  logic [11:0] brightness;
  logic        valid_rgb;
  logic [11:0] color_red;
  logic [11:0] color_green;
  logic [11:0] color_blue;

  // Clock generation
  initial begin
    clk_125 = 1'b0;
    forever clk_125 = #4.0 ~clk_125;
  end

  // Reset logic
  initial begin
    res_n       = 1'b0;
    #10ns res_n = 1'b1;
  end


  initial begin

    valid_hue  <= '0;
    hue        <= '0;
    saturation <= '0;
    brightness <= '0;

    @(posedge res_n);

    $display("Reset complete");


    // Test 1
    $display("Test 1");
    valid_hue  <= 1'b1;
    hue        <= 12'd2000;
    saturation <= 12'd2500;
    brightness <= 12'd2500;

    @(posedge valid_rgb);
    valid_hue  <= 1'b0;

    if ( color_red == 12'd280 ) begin
      $display("Red is correct");
    end else begin
      $error("Red is %0d, but should be 280", color_red);
    end

    if ( color_green == 12'd2618 ) begin
      $display("Green is correct");
    end else begin
      $error("Green is %0d, but should be 2618", color_green);
    end

    if ( color_blue == 12'd2347 ) begin
      $display("Blue is correct");
    end else begin
      $error("Blue is %0d, but should be 2347", color_blue);
    end

    @(negedge valid_rgb);

    // Test 2
    $display("Test 2");
    valid_hue  <= 1'b1;
    hue        <= 12'd4095;
    saturation <= 12'd4095;
    brightness <= 12'd2500;

    @(posedge valid_rgb);
    valid_hue  <= 1'b0;

    if ( color_red == 12'd4095) begin
      $display("Red is correct");
    end else begin
      $error("Red is %0d, but should be 4095", color_red);
    end

    if ( color_green == 12'd67 ) begin
      $display("Green is correct");
    end else begin
      $error("Green is %0d, but should be 67", color_green);
    end

    if ( color_blue == 12'd68 ) begin
      $display("Blue is correct");
    end else begin
      $error("Blue is %0d, but should be 68", color_blue);
    end


    @(negedge valid_rgb);

    // Test 3
    $display("Test 3");
    valid_hue  <= 1'b1;
    hue        <= 12'd1333;
    saturation <= 12'd2895;
    brightness <= 12'd3333;

    @(posedge valid_rgb);
    valid_hue  <= 1'b0;

    if ( color_red == 12'd1521 ) begin
      $display("Red is correct");
    end else begin
      $error("Red is %0d, but should be 1521", color_red);
    end

    if ( color_green == 12'd3516 ) begin
      $display("Green is correct");
    end else begin
      $error("Green is %0d, but should be 3516", color_green);
    end

    if ( color_blue == 12'd1449 ) begin
      $display("Blue is correct");
    end else begin
      $error("Blue is %0d, but should be 1449", color_blue);
    end

    $display("Finished");
    $finish;
  end


   // DUT instantiation
  color_hsl_12bit_color color_hsl_12bit_color_i0 (
    .clk         ( clk_125     ),
    .rst_n       ( res_n       ),
    .ready       (             ),
    .valid_hue   ( valid_hue   ),
    .hue         ( hue         ),
    .saturation  ( saturation  ),
    .brightness  ( brightness  ),
    .valid_rgb   ( valid_rgb   ),
    .color_red   ( color_red   ),
    .color_green ( color_green ),
    .color_blue  ( color_blue  )
  );

endmodule
