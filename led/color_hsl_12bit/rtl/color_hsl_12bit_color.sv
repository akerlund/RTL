////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import gamma_12bit_lut_pkg::*;

module color_hsl_12bit_color #(
    parameter int COLOR_WIDTH_P = 12
  )(
    input  wire                        clk,
    input  wire                        rst_n,

    output logic                       ready,
    input  wire                        valid_hue,

    input  wire  [COLOR_WIDTH_P-1 : 0] hue,
    input  wire  [COLOR_WIDTH_P-1 : 0] saturation,
    input  wire  [COLOR_WIDTH_P-1 : 0] brightness,

    output logic                       valid_rgb,
    output logic [COLOR_WIDTH_P-1 : 0] color_red,
    output logic [COLOR_WIDTH_P-1 : 0] color_green,
    output logic [COLOR_WIDTH_P-1 : 0] color_blue
  );

  localparam int MAX_COLOR_VALUE_C = 4095;
  localparam int MOD_COLOR_VALUE_C = 8191;

  typedef enum {
    CALCULATE_CHROMA_E,
    CALCULATE_X0_E,
    CALCULATE_X1_E,
    SET_HUE_E,
    ADJUST_GAMMA_E
  } state_t;

  state_t hsl_state;

  logic       signed [31 : 0] chroma_bright;
  logic              [31 : 0] hue_normalized;
  logic              [31 : 0] hue_prim;

  logic              [31 : 0] chroma;
  logic              [31 : 0] intermediate_value_x0;

  logic              [31 : 0] intermediate_value_x1;
  logic              [31 : 0] m_brightness;

  logic [COLOR_WIDTH_P-1 : 0] hue_red;
  logic [COLOR_WIDTH_P-1 : 0] hue_green;
  logic [COLOR_WIDTH_P-1 : 0] hue_blue;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hsl_state             <= CALCULATE_CHROMA_E;

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
        CALCULATE_CHROMA_E: begin

          ready <= 1;

          if (valid_hue) begin

            hsl_state <= CALCULATE_X0_E;
            ready     <= '0;

            // Chroma = 1 - |2L - 1| * saturation
            // |2L - 1| = ...
            if ( (brightness << 1) - MAX_COLOR_VALUE_C >= 0 ) begin
              chroma_bright <= (brightness << 1) - MAX_COLOR_VALUE_C;
            end
            else begin
              chroma_bright <= -(brightness << 1) + MAX_COLOR_VALUE_C;
            end

            hue_normalized <= 6*hue;
          end
        end

        // Step 2: Chroma (2/2) and x0
        CALCULATE_X0_E: begin

          hsl_state <= CALCULATE_X1_E;
          ready     <= '0;

          // H' = H / 60�
          // 4095 * 6 = 24570 and 24570 >> 12 = 5
          hue_prim <= hue_normalized >> 12; // Min 0, Max 5

          // Chroma = 1 - |2L - 1| * saturation
          chroma <= ((MAX_COLOR_VALUE_C - chroma_bright) * saturation) >> 12;

          if ( int'((hue_normalized % MOD_COLOR_VALUE_C) - MAX_COLOR_VALUE_C) >= 0 ) begin
            intermediate_value_x0 <= hue_normalized % MOD_COLOR_VALUE_C - MAX_COLOR_VALUE_C;
          end
          else begin
            intermediate_value_x0 <= -(hue_normalized % MOD_COLOR_VALUE_C) + MAX_COLOR_VALUE_C;
          end
        end

        // Step 3: x1 and m_brighness
        CALCULATE_X1_E: begin

          hsl_state <= SET_HUE_E;
          ready     <= '0;

          // X = chroma * (1 - |(H' mod 2) - 1|)
          intermediate_value_x1 <= (chroma * (MAX_COLOR_VALUE_C - intermediate_value_x0)) >> 12;

          // Match brightness
          // m = L - C/2
          // (R, G, B) = (R1 + m, G1 + m, B1 + m)
          m_brightness <= brightness - (chroma >> 1);
        end

        // Step 4: Set HUE
        SET_HUE_E: begin

          hsl_state <= ADJUST_GAMMA_E;
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
        ADJUST_GAMMA_E: begin

          hsl_state <= CALCULATE_CHROMA_E;
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
          hsl_state <= CALCULATE_CHROMA_E;
        end

      endcase
    end
  end

endmodule

`default_nettype wire
