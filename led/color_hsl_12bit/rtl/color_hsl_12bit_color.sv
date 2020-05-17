`default_nettype none

import gamma_12bit_lut_pkg::*;

module color_hsl_12bit_color #(
    parameter int color_width = 12
  )(
    input  wire                      clk,
    input  wire                      rst_n,

    output logic                     ready,
    input  wire                      valid_hue,

    input  wire  [color_width-1 : 0] hue,
    input  wire  [color_width-1 : 0] saturation,
    input  wire  [color_width-1 : 0] brightness,

    output logic                     valid_rgb,
    output logic [color_width-1 : 0] color_red,
    output logic [color_width-1 : 0] color_green,
    output logic [color_width-1 : 0] color_blue
  );

  localparam int max_color_value_c = 4095;
  localparam int mod_color_value_c = 8191;

  typedef enum {
    calculate_chroma_e = 0,
    calculate_x0_e,
    calculate_x1_e,
    set_hue_e,
    adjust_gamma_e
  } state_t;

  state_t                   hsl_state;

  logic     signed [31 : 0] chroma_bright;
  logic            [31 : 0] hue_normalized;
  logic            [31 : 0] hue_prim;

  logic            [31 : 0] chroma;
  logic            [31 : 0] intermediate_value_x0;

  logic            [31 : 0] intermediate_value_x1;
  logic            [31 : 0] m_brightness;

  logic [color_width-1 : 0] hue_red;
  logic [color_width-1 : 0] hue_green;
  logic [color_width-1 : 0] hue_blue;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hsl_state             <= calculate_chroma_e;

      hue_normalized        <= '0;
      chroma_bright         <= '0;
      hue_prim              <= '0;
      chroma                <= '0;

      intermediate_value_x0 <= '0;
      intermediate_value_x1 <= '0;
      m_brightness          <= '0;

      hue_red               <= '0;
      hue_green             <= '0;
      hue_blue              <= '0;

      ready                 <= '0;
      valid_rgb             <= '0;
      color_red             <= '0;
      color_green           <= '0;
      color_blue            <= '0;
    end
    else begin

      valid_rgb <= '0;

      case (hsl_state)
        // Step 1: Chroma (1/2) and H'
        calculate_chroma_e: begin

          ready <= 1;

          if (valid_hue) begin

            hsl_state <= calculate_x0_e;
            ready     <= '0;

            // Chroma = 1 - |2L - 1| * saturation
            // |2L - 1| = ...
            if ( (brightness << 1) - max_color_value_c >= 0 ) begin
              chroma_bright <= (brightness << 1) - max_color_value_c;
            end
            else begin
              chroma_bright <= -(brightness << 1) + max_color_value_c;
            end

            hue_normalized <= 6*hue;
          end
        end

        // Step 2: Chroma (2/2) and x0
        calculate_x0_e: begin

          hsl_state <= calculate_x1_e;
          ready     <= '0;

          // H' = H / 60�
          // 4095 * 6 = 24570 and 24570 >> 12 = 5
          hue_prim <= hue_normalized >> 12; // Min 0, Max 5

          // Chroma = 1 - |2L - 1| * saturation
          chroma <= ((max_color_value_c - chroma_bright) * saturation) >> 12;

          if ( int'((hue_normalized % mod_color_value_c) - max_color_value_c) >= 0 ) begin
            intermediate_value_x0 <= hue_normalized % mod_color_value_c - max_color_value_c;
          end
          else begin
            intermediate_value_x0 <= -(hue_normalized % mod_color_value_c) + max_color_value_c;
          end
        end

        // Step 3: x1 and m_brighness
        calculate_x1_e: begin

          hsl_state <= set_hue_e;
          ready     <= '0;

          // X = chroma * (1 - |(H' mod 2) - 1|)
          intermediate_value_x1 <= (chroma * (max_color_value_c - intermediate_value_x0)) >> 12;

          // Match brightness
          // m = L - C/2
          // (R, G, B) = (R1 + m, G1 + m, B1 + m)
          m_brightness <= brightness - (chroma >> 1);
        end

        // Step 4: Set HUE
        set_hue_e: begin

          hsl_state <= adjust_gamma_e;
          ready     <= '0;

          case (hue_prim)
            0: begin
                hue_red   <= m_brightness + chroma;
                hue_green <= m_brightness + intermediate_value_x1;
                hue_blue  <= m_brightness;
            end
            1: begin
                hue_red   <= m_brightness + intermediate_value_x1;
                hue_green <= m_brightness + chroma;
                hue_blue  <= m_brightness;
              end
            2: begin
                hue_red   <= m_brightness;
                hue_green <= m_brightness + chroma;
                hue_blue  <= m_brightness + intermediate_value_x1;
              end
            3: begin
                hue_red   <= m_brightness;
                hue_green <= m_brightness + intermediate_value_x1;
                hue_blue  <= m_brightness + chroma;
              end
            4: begin
                hue_red   <= m_brightness + intermediate_value_x1;
                hue_green <= m_brightness;
                hue_blue  <= m_brightness + chroma;
              end
            5: begin
                hue_red   <= m_brightness + chroma;
                hue_green <= m_brightness;
                hue_blue  <= m_brightness + intermediate_value_x1;
              end
          endcase
        end

        // Step 5: Adjust gamma
        adjust_gamma_e: begin

          hsl_state <= calculate_chroma_e;
          ready     <= 1;

          valid_rgb   <= 1;
          color_red   <= gamma_lut_table_c[hue_red];
          color_green <= gamma_lut_table_c[hue_green];
          color_blue  <= gamma_lut_table_c[hue_blue];
          //color_red   <= hue_red;
          //color_green <= hue_green;
          //color_blue  <= hue_blue;
        end

        default: begin
          hsl_state <= calculate_chroma_e;
        end

      endcase
    end
  end

endmodule

`default_nettype wire
