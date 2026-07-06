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
    input  wire  [DATA_WIDTH_P-1 : 0] ing_vector,
    input  wire                       ing_valid,
    output logic                      ing_ready,

    // Data (Destination)
    output logic [DATA_WIDTH_P-1 : 0] egr_vector,
    output logic                      egr_valid,
    input  wire                       egr_ready
  );

  // Source process states
  typedef enum {
    SRC_WAIT_VALID_E,
    SRC_WAIT_DST_ACK_E
  } src_sync_state_t;

  // Destination process states
  typedef enum {
    DST_WAIT_VALID_E,
    DST_WAIT_READY_E
  } dst_sync_state_t;

  src_sync_state_t src_sync_state;
  dst_sync_state_t dst_sync_state;

  // Buffered input
  logic [DATA_WIDTH_P-1 : 0] src_vector_d0;

  // To signal the other clock comain that the reset is active
  logic                      src_dst_rst_n;
  logic                      dst_src_rst_n;

  // Toggles when there is a new input
  logic                      src_valid;
  logic                      dst_valid;
  logic                      dst_valid_d0;

  // For the destination to ack data
  logic                      dst_valid_ack;
  logic                      src_valid_ack;
  logic                      src_valid_ack_d0;

`ifndef SYNTHESIS
  logic [DATA_WIDTH_P-1 : 0] src_vector_assert_d0;
  logic [DATA_WIDTH_P-1 : 0] egr_vector_assert_d0;
`endif

  // Source
  always_ff @ (posedge clk_src or negedge rst_src_n) begin
    if (!rst_src_n) begin

      src_sync_state   <= SRC_WAIT_VALID_E;
      src_valid_ack_d0 <= '0;
      ing_ready        <= '0;
      src_valid        <= '0;
      src_vector_d0    <= '0;

    end
    else begin

      if (!src_dst_rst_n) begin

        src_sync_state   <= SRC_WAIT_VALID_E;
        src_valid_ack_d0 <= '0;
        ing_ready        <= '0;
        src_valid        <= '0;
        src_vector_d0    <= '0;

      end
      else begin

        src_valid_ack_d0 <= src_valid_ack;

        case (src_sync_state)

          SRC_WAIT_VALID_E: begin

            ing_ready <= '1;

            if (ing_valid && ing_ready) begin
              src_sync_state <= SRC_WAIT_DST_ACK_E;
              src_valid      <= ~src_valid;
              src_vector_d0  <= ing_vector;
              ing_ready      <= '0;
            end
          end


          SRC_WAIT_DST_ACK_E: begin

            if (src_valid_ack_d0 != src_valid_ack) begin
              src_sync_state <= SRC_WAIT_VALID_E;
              ing_ready      <= '1;
            end
          end

        endcase

      end
    end
  end

  // Destination
  always_ff @ (posedge clk_dst or negedge rst_dst_n) begin
    if (!rst_dst_n) begin

      dst_sync_state <= DST_WAIT_VALID_E;
      egr_vector     <= '0;
      egr_valid      <= '0;
      dst_valid_d0   <= '0;
      dst_valid_ack  <= '0;

    end
    else begin

      if (!dst_src_rst_n) begin

        dst_sync_state <= DST_WAIT_VALID_E;
        egr_vector     <= '0;
        egr_valid      <= '0;
        dst_valid_d0   <= '0;
        dst_valid_ack  <= '0;

      end
      else begin

        dst_valid_d0 <= dst_valid;

        case (dst_sync_state)

          DST_WAIT_VALID_E: begin

            if (dst_valid_d0 != dst_valid) begin
              dst_sync_state <= DST_WAIT_READY_E;
              egr_vector     <= src_vector_d0;
              egr_valid      <= '1;
            end
          end


          DST_WAIT_READY_E: begin

            if (egr_ready) begin
              dst_sync_state <= DST_WAIT_VALID_E;
              egr_valid     <= '0;
              dst_valid_ack <= ~dst_valid_ack;
            end
          end

        endcase

      end

    end
  end

  cdc_bit_sync cdc_bit_sync_i0 (

    .clk_src   ( clk_src       ), // input
    .rst_src_n ( rst_src_n     ), // input
    .clk_dst   ( clk_dst       ), // input
    .rst_dst_n ( rst_dst_n     ), // input
    .src_bit   ( '1            ), // input
    .dst_bit   ( dst_src_rst_n )  // output
  );

  cdc_bit_sync cdc_bit_sync_i1 (

    .clk_src   ( clk_dst       ), // input
    .rst_src_n ( rst_dst_n     ), // input
    .clk_dst   ( clk_src       ), // input
    .rst_dst_n ( rst_src_n     ), // input
    .src_bit   ( '1            ), // input
    .dst_bit   ( src_dst_rst_n )  // output
  );

  cdc_bit_sync cdc_bit_sync_i2 (

    .clk_src   ( clk_src       ), // input
    .rst_src_n ( rst_src_n     ), // input
    .clk_dst   ( clk_dst       ), // input
    .rst_dst_n ( rst_dst_n     ), // input
    .src_bit   ( src_valid     ), // input
    .dst_bit   ( dst_valid     )  // output
  );

  cdc_bit_sync cdc_bit_sync_i3 (

    .clk_src   ( clk_dst       ), // input
    .rst_src_n ( rst_dst_n     ), // input
    .clk_dst   ( clk_src       ), // input
    .rst_dst_n ( rst_src_n     ), // input
    .src_bit   ( dst_valid_ack ), // input
    .dst_bit   ( src_valid_ack )  // output
  );

`ifndef SYNTHESIS
  always_ff @(posedge clk_src or negedge rst_src_n) begin
    if (!rst_src_n) begin
      src_vector_assert_d0 <= '0;
    end else begin
      if (src_dst_rst_n && src_sync_state == SRC_WAIT_DST_ACK_E) begin
        assert (src_vector_d0 == src_vector_assert_d0)
          else $error("src_vector_d0 changed before destination acknowledge returned");
      end
      src_vector_assert_d0 <= src_vector_d0;
    end
  end

  always_ff @(posedge clk_dst or negedge rst_dst_n) begin
    if (!rst_dst_n) begin
      egr_vector_assert_d0 <= '0;
    end else begin
      if (dst_src_rst_n && egr_valid && !egr_ready) begin
        assert (egr_vector == egr_vector_assert_d0)
          else $error("egr_vector changed while egr_valid was waiting for egr_ready");
      end
      egr_vector_assert_d0 <= egr_vector;
    end
  end
`endif

endmodule

`default_nettype wire
