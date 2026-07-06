////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module rotary_encoder_fsm (
    input  wire  clk,
    input  wire  rst_n,

    input  wire  encoder_pin_a,
    input  wire  encoder_pin_b,
    output logic valid_change,
    output logic rotation_direction
  );

  typedef enum {
    IDLE_E,
    R1_E,
    R2_E,
    R3_E,
    RIGHT_E,
    L1_E,
    L2_E,
    L3_E,
    LEFT_E
  } state_t;

  state_t enc_state;

  // Encoder FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      enc_state          <= IDLE_E;
      valid_change       <= '0;
      rotation_direction <= '0;
    end
    else begin

      enc_state <= enc_state;
      valid_change  <= '0;

      case (enc_state)

        IDLE_E: begin
          if (!encoder_pin_b) begin
            enc_state <= R1_E;
          end
          else if (!encoder_pin_a) begin
            enc_state <= L1_E;
          end
          else begin
            enc_state <= IDLE_E;
          end
        end

        R1_E: begin
          if (encoder_pin_b) begin
            enc_state <= IDLE_E;
          end
          else if (!encoder_pin_a) begin
            enc_state <=  R2_E;
          end
          else begin
            enc_state <= R1_E;
          end
        end

        R2_E: begin
          if (encoder_pin_a) begin
            enc_state <= R1_E;
          end
          else if (encoder_pin_b) begin
            enc_state <= R3_E;
          end
          else begin
            enc_state <= R2_E;
          end
        end

        R3_E: begin
          if (!encoder_pin_b) begin
            enc_state <= R2_E;
          end
          else if (encoder_pin_a) begin
            enc_state <= RIGHT_E;
          end
          else begin
            enc_state <= R3_E;
          end
        end

        RIGHT_E: begin
          rotation_direction <= 1;
          valid_change       <= 1;
          enc_state         <= IDLE_E;
        end

        L1_E: begin
          if (encoder_pin_a) begin
            enc_state <= IDLE_E;
          end
          else if (!encoder_pin_b) begin
            enc_state <= L2_E;
          end
          else begin
            enc_state <= L1_E;
          end
        end

        L2_E: begin
          if (encoder_pin_b) begin
            enc_state <= L1_E;
          end
          else if (encoder_pin_a) begin
            enc_state <= L3_E;
          end
          else begin
            enc_state <= L2_E;
          end
        end

        L3_E: begin
          if (!encoder_pin_a) begin
            enc_state <= L2_E;
          end
          else if (encoder_pin_b) begin
            enc_state <= LEFT_E;
          end
          else begin
            enc_state <= L3_E;
          end
        end

        LEFT_E: begin
          rotation_direction <= '0;
          valid_change       <= 1;
          enc_state         <= IDLE_E;
        end

        default: begin
          enc_state <= enc_state;
          valid_change  <= '0;
        end

      endcase
    end
  end

endmodule

`default_nettype wire
