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