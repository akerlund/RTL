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
// The value of "cr_clock_enable" must be lower than the CORDIC's parameter
// NR_OF_STAGES_P, so that there are enough time to perform calculations.
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
  logic signed      [AXI_DATA_WIDTH_P-1 : 0] cordic_sine_cp;
  logic signed      [AXI_DATA_WIDTH_P-1 : 0] cordic_cosine;

  // Internal signals of sine and cosine, result from the CORDIC
  assign {cordic_sine, cordic_cosine} = cordic_ing_tdata;

  logic period_debug;
  assign period_debug = !osc_sine ? '1 : '0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Ports
      osc_sine          <= '0;
      cordic_sine_cp    <= '0;
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
            cordic_sine_cp    <= cordic_sine >>> (CORDIC_Q_BITS_C - Q_BITS_P);
          end
          else if (!cordic_ing_tready) begin
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

endmodule

`default_nettype wire
