`default_nettype none

module rotary_encoder (
    input  wire  clk,
    input  wire  rst_n,

    input  wire  encoder_pin_A,
    input  wire  encoder_pin_B,
    output logic valid_change,
    output logic rotation_direction
  );

  typedef enum {
    idle_e = 0,
    r1_e,
    r2_e,
    r3_e,
    right_e,
    l1_e,
    l2_e,
    l3_e,
    left_e
  } state_t;

  state_t current_state;
  state_t next_state;

  logic encoder_A;
  logic encoder_B;

  // Encoder FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state      <= idle_e;
      next_state         <= idle_e;
      valid_change       <= '0;
      rotation_direction <= '0;
    end
    else begin

      current_state <= next_state;
      valid_change  <= '0;

      case (current_state)

        idle_e: begin
          if (!encoder_pin_B) begin
            next_state <= r1_e;
          end
          else if (!encoder_pin_A) begin
            next_state <= l1_e;
          end
          else begin
            next_state <= idle_e;
          end
        end

        r1_e: begin
          if (encoder_pin_B) begin
            next_state <= idle_e;
          end
          else if (!encoder_pin_A) begin
            next_state <=  r2_e;
          end
          else begin
            next_state <= r1_e;
          end
        end

        r2_e: begin
          if (encoder_pin_A) begin
            next_state <= r1_e;
          end
          else if (encoder_pin_B) begin
            next_state <= r3_e;
          end
          else begin
            next_state <= r2_e;
          end
        end

        r3_e: begin
          if (!encoder_pin_B) begin
            next_state <= r2_e;
          end
          else if (encoder_pin_A) begin
            next_state <= right_e;
          end
          else begin
            next_state <= r3_e;
          end
        end

        right_e: begin
          rotation_direction <= 1;
          valid_change       <= 1;
          next_state         <= idle_e;
        end

        l1_e: begin
          if (encoder_pin_A) begin
            next_state <= idle_e;
          end
          else if (!encoder_pin_B) begin
            next_state <= l2_e;
          end
          else begin
            next_state <= l1_e;
          end
        end

        l2_e: begin
          if (encoder_pin_B) begin
            next_state <= l1_e;
          end
          else if (encoder_pin_A) begin
            next_state <= l3_e;
          end
          else begin
            next_state <= l2_e;
          end
        end

        l3_e: begin
          if (!encoder_pin_A) begin
            next_state <= l2_e;
          end
          else if (encoder_pin_B) begin
            next_state <= left_e;
          end
          else begin
            next_state <= l3_e;
          end
        end

        left_e: begin
          rotation_direction <= '0;
          valid_change       <= 1;
          next_state         <= idle_e;
        end

        default: begin
          current_state <= next_state;
          valid_change  <= '0;
        end

      endcase
    end
  end

endmodule

`default_nettype wire