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
// TODO
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module cdc_vector_sync #(
    parameter int DATA_WIDTH_P = -1
  )(
    // Clock and reset (Source)
    input  wire                       clk_src,
    input  wire                       rst_src_n,

    // Clock and reset (Destination)
    input  wire                       clk_dst,
    input  wire                       rst_dst_n,

    // Data (Source)
    input  wire  [DATA_WIDTH_P-1 : 0] src_vector,
    input  wire  [DATA_WIDTH_P-1 : 0] src_valid,
    output logic [DATA_WIDTH_P-1 : 0] src_ready,

    // Data (Destination)
    output logic [DATA_WIDTH_P-1 : 0] dst_vector,
    output logic [DATA_WIDTH_P-1 : 0] dst_valid

  );

  // Source process states
  typedef enum {
    SRC_WAIT_VALID_E,
    SRC_WAIT_DST_ACK_E
  } src_sync_state_t;

  src_sync_state_t src_sync_state;

  // Buffered input
  logic [DATA_WIDTH_P-1 : 0] src_vector_d0;

  // To signal far end that reset is active
  logic                      src_dst_rst_n;
  logic                      dst_src_rst_n;

  // Toggles when there is a new input
  logic                      src_new_input;
  logic                      dst_new_input;
  logic                      dst_new_input_d0;

  // For the destination to ack data
  logic                      dst_input_ack;
  logic                      src_input_ack;
  logic                      src_input_ack_d0;

  // Source
  always_ff @ (posedge clk_src or negedge rst_src_n) begin
    if (!rst_src_n) begin

      src_sync_state   <= SRC_WAIT_VALID_E;
      src_input_ack_d0 <= '0;
      src_ready        <= '0;
      src_new_input    <= '0;
      src_vector_d0    <= '0;

    end
    else begin

      if (!src_dst_rst_n) begin

        src_sync_state   <= SRC_WAIT_VALID_E;
        src_input_ack_d0 <= '0;
        src_ready        <= '0;
        src_new_input    <= '0;
        src_vector_d0    <= '0;

      end
      else begin

        src_input_ack_d0 <= src_input_ack;

        case (src_sync_state)

          SRC_WAIT_VALID_E: begin

            src_ready <= '1;

            if (src_valid) begin
              src_sync_state <= SRC_WAIT_DST_ACK_E;
              src_new_input  <= ~src_new_input;
              src_vector_d0  <= src_vector;
              src_ready      <= '0;
            end
          end


          SRC_WAIT_DST_ACK_E: begin

            if (src_input_ack_d0 != src_input_ack) begin
              src_sync_state <= SRC_WAIT_VALID_E;
              src_ready      <= '1;
            end
          end

        endcase

      end
    end
  end


  // Destination
  always_ff @ (posedge clk_dst or negedge rst_dst_n) begin
    if (!rst_dst_n) begin

      dst_vec          <= '0;
      dst_new_input_d0 <= '0;
      dst_input_ack    <= '0;
      dst_valid        <= '0;

    end
    else begin

      if (!dst_src_rst_n) begin

        dst_vec          <= '0;
        dst_new_input_d0 <= '0;
        dst_input_ack    <= '0;
        dst_valid        <= '0;

      end
      else begin

        dst_new_input_d0 <= dst_new_input;
        dst_valid        <= '0;

        if (dst_new_input_d0 != dst_new_input) begin
          dst_vec       <= src_vector_d0;
          dst_input_ack <= ~dst_input_ack;
          dst_valid     <= '1;
        end

      end

    end
  end

  cdc_bit_sync cdc_bit_sync_i0 (

    .clk_src   ( clk_src       ),
    .rst_src_n ( rst_src_n     ),
    .clk_dst   ( clk_dst       ),
    .rst_dst_n ( rst_dst_n     ),
    .src_bit   ( '1            ),
    .dst_bit   ( dst_src_rst_n )
  );

  cdc_bit_sync cdc_bit_sync_i1 (

    .clk_src   ( clk_dst       ),
    .rst_src_n ( rst_dst_n     ),
    .clk_dst   ( clk_src       ),
    .rst_dst_n ( rst_src_n     ),
    .src_bit   ( '1            ),
    .dst_bit   ( src_dst_rst_n )
  );

  cdc_bit_sync cdc_bit_sync_i2 (

    .clk_src   ( clk_src       ),
    .rst_src_n ( rst_src_n     ),
    .clk_dst   ( clk_dst       ),
    .rst_dst_n ( rst_dst_n     ),
    .src_bit   ( src_new_input ),
    .dst_bit   ( dst_new_input )
  );

  cdc_bit_sync cdc_bit_sync_i3 (

    .clk_src   ( clk_dst       ),
    .rst_src_n ( rst_dst_n     ),
    .clk_dst   ( clk_src       ),
    .rst_dst_n ( rst_src_n     ),
    .src_bit   ( dst_input_ack ),
    .dst_bit   ( src_input_ack )
  );

endmodule

`default_nettype wire
