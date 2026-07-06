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

import cordic_axi4s_types_pkg::*;
import cordic_atan_radian_table_pkg::*;

`default_nettype none

module osc_sin_top #(
    parameter int SYS_CLK_FREQUENCY_P = -1, // System clock's frequency
    parameter int PRIME_FREQUENCY_P   = -1, // Output frequency then clock enable is always high
    parameter int AXI_DATA_WIDTH_P    = -1,
    parameter int AXI_ID_WIDTH_P      = -1,
    parameter int AXI_ID_P            = -1,
    parameter int N_BITS_P            = -1,
    parameter int Q_BITS_P            = -1,
    parameter int COUNTER_WIDTH_P     = $clog2(SYS_CLK_FREQUENCY_P)
  )(

    // Clock and reset
    input  wire                                    clk,
    input  wire                                    rst_n,

    // Waveform output
    output logic signed           [N_BITS_P-1 : 0] osc_sine,

    // The counter period of the Clock Enable, i.e., PRIME_FREQUENCY_P / frequency
    input  wire            [COUNTER_WIDTH_P-1 : 0] cr_clock_enable,

    // -------------------------------------------------------------------------
    // CORDIC interface
    // -------------------------------------------------------------------------

    output logic                                   cordic_egr_tvalid,
    input  wire                                    cordic_egr_tready,
    output logic signed   [AXI_DATA_WIDTH_P-1 : 0] cordic_egr_tdata,
    output logic                                   cordic_egr_tlast,
    output logic            [AXI_ID_WIDTH_P-1 : 0] cordic_egr_tid,
    output logic                                   cordic_egr_tuser,  // Vector selection
    input  wire                                    cordic_ing_tvalid,
    output logic                                   cordic_ing_tready,
    input  wire  signed [2*AXI_DATA_WIDTH_P-1 : 0] cordic_ing_tdata,
    input  wire                                    cordic_ing_tlast
  );

  localparam logic signed [N_BITS_P-1 : 0] ONE_C           = (1 << Q_BITS_P);
  localparam logic signed [N_BITS_P-1 : 0] PI2_C           = {'0, pi_8_4_pos_n54_q50[53 : 50-Q_BITS_P]};
  localparam int                           CORDIC_Q_BITS_C = AXI_DATA_WIDTH_P - 4;


  localparam int                    PERIOD_IN_SYS_CLKS_C = SYS_CLK_FREQUENCY_P / PRIME_FREQUENCY_P;
  localparam logic [N_BITS_P-1 : 0] ROTATION_INC_C       = ((PI2_C << Q_BITS_P) / (PERIOD_IN_SYS_CLKS_C-1)) >> Q_BITS_P;

  typedef enum {
    SEND_SINE_OF_THETA_E,
    HANDSHAKE_CORDIC_EGR_E,
    WAIT_FOR_CORDIC_E
  } sin_state_t;

  sin_state_t sin_state;

  logic                                      clock_enable;

  logic [$clog2(PERIOD_IN_SYS_CLKS_C)-1 : 0] counter;
  logic                     [N_BITS_P-1 : 0] theta;

  // CORDIC
  logic signed      [AXI_DATA_WIDTH_P-1 : 0] cordic_sine;
  logic signed      [AXI_DATA_WIDTH_P-1 : 0] cordic_cosine;

  // Internal signals of sine and cosine, result from the CORDIC
  assign {cordic_sine, cordic_cosine} = cordic_ing_tdata;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Ports
      osc_sine          <= '0;
      cordic_egr_tvalid <= '0;
      cordic_egr_tdata  <= '0;
      cordic_egr_tlast  <= '0;
      cordic_egr_tid    <= '0;
      cordic_egr_tuser  <= '0;
      cordic_ing_tready <= '0;

      sin_state         <= SEND_SINE_OF_THETA_E;
      counter           <= '0;
      theta             <= '0;
    end
    else begin


      case (sin_state)

        SEND_SINE_OF_THETA_E: begin

          if (clock_enable) begin

            counter <= counter + 1;

            if (counter == PERIOD_IN_SYS_CLKS_C-1) begin
              counter  <= '0;
              theta    <= '0;
            end
            else begin
              theta    <= theta + ROTATION_INC_C;
            end

            cordic_egr_tvalid <= '1;
            cordic_egr_tdata  <= theta << (AXI_DATA_WIDTH_P-4-Q_BITS_P);
            cordic_egr_tid    <= AXI_ID_P;
            cordic_egr_tuser  <= CORDIC_SINE_COSINE_E;     // Request both
            sin_state         <= HANDSHAKE_CORDIC_EGR_E;

          end
        end


        HANDSHAKE_CORDIC_EGR_E: begin
          if (cordic_egr_tready) begin
            cordic_egr_tvalid <= '0;
            sin_state         <= WAIT_FOR_CORDIC_E;
            cordic_ing_tready <= '1;
          end
        end


        WAIT_FOR_CORDIC_E: begin
          if (cordic_ing_tvalid && cordic_ing_tready) begin
            // CORDIC always returns +-1, the MSB is the sign, the rest are q-bits
            cordic_ing_tready <= '0;
            sin_state         <= SEND_SINE_OF_THETA_E;
            osc_sine          <= cordic_sine >>> (CORDIC_Q_BITS_C - Q_BITS_P);
          end
        end

      endcase

    end
  end



  clock_enable #(
    .COUNTER_WIDTH_P  ( COUNTER_WIDTH_P )
  ) clock_enable_i0 (
    .clk              ( clk             ), // input
    .rst_n            ( rst_n           ), // input
    .enable           ( clock_enable    ), // output
    .reset_counter_n  ( '1              ), // input
    .cr_enable_period ( cr_clock_enable )  // input
  );

`ifndef SYNTHESIS
  always_ff @(posedge clk) begin
    if (rst_n && cr_clock_enable < 16) begin
      assert (!clock_enable || sin_state == SEND_SINE_OF_THETA_E)
        else $error("cr_clock_enable is shorter than the CORDIC transaction latency");
    end
  end
`endif

endmodule

`default_nettype wire
