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
// The IIR Bi-Quad top module implements an FSM which calculates the filter
// coefficients from the values written in the configuration registers.
// It calls the the CORDIC and the divider for calculating the
// filter parameters. The parameters will be updated if any register's value
// is changed.
//
////////////////////////////////////////////////////////////////////////////////

import cordic_axi4s_types_pkg::*;
import cordic_atan_radian_table_pkg::*;

`default_nettype none

module iir_biquad_top #(
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI4S_ID_P       = -1,
    parameter int APB_DATA_WIDTH_P = -1,
    parameter int N_BITS_P         = -1,
    parameter int Q_BITS_P         = -1
  )(

    // Clock and reset
    input  wire                                    clk,
    input  wire                                    rst_n,

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
    input  wire                                    cordic_ing_tlast,

    // -------------------------------------------------------------------------
    // Long division interface
    // -------------------------------------------------------------------------

    output logic                                   div_egr_tvalid,
    input  wire                                    div_egr_tready,
    output logic          [AXI_DATA_WIDTH_P-1 : 0] div_egr_tdata,
    output logic                                   div_egr_tlast,
    output logic            [AXI_ID_WIDTH_P-1 : 0] div_egr_tid,

    input  wire                                    div_ing_tvalid,
    output logic                                   div_ing_tready,
    input  wire           [AXI_DATA_WIDTH_P-1 : 0] div_ing_tdata,     // Quotient
    input  wire                                    div_ing_tlast,
    input  wire             [AXI_ID_WIDTH_P-1 : 0] div_ing_tid,
    input  wire                                    div_ing_tuser,     // Overflow

    // -------------------------------------------------------------------------
    // Filter ports
    // -------------------------------------------------------------------------

    input  wire                                    x_valid,
    input  wire  signed           [N_BITS_P-1 : 0] x,
    output logic                                   y_valid,
    output logic signed           [N_BITS_P-1 : 0] y,

    // -------------------------------------------------------------------------
    // APB registers
    // -------------------------------------------------------------------------

    input  wire           [APB_DATA_WIDTH_P-1 : 0] cr_iir_f0,
    input  wire           [APB_DATA_WIDTH_P-1 : 0] cr_iir_fs,
    input  wire           [APB_DATA_WIDTH_P-1 : 0] cr_iir_q,
    input  wire           [APB_DATA_WIDTH_P-1 : 0] cr_iir_type,
    input  wire           [APB_DATA_WIDTH_P-1 : 0] cr_bypass,
    output logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_w0,
    output logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_alfa,
    output logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_zero_b0,
    output logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_zero_b1,
    output logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_zero_b2,
    output logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_pole_a0,
    output logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_pole_a1,
    output logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_pole_a2
  );

  localparam logic signed [N_BITS_P-1 : 0] ONE_C           = (1 << Q_BITS_P);
  localparam logic signed [N_BITS_P-1 : 0] PI2_C           = {'0, pi_8_4_pos_n4_q50[53 : 50-Q_BITS_P]};
  localparam int                           CORDIC_Q_BITS_C = AXI_DATA_WIDTH_P - 4;


  typedef enum {
    INITIALIZE_FILTER_E,
    // First states solves
    //  - w0   = 2 * pi * f0 /Fs
    //  - alfa = sin(w0) / 2Q
    SEND_DIVIDEND_F0_E,
    SEND_DIVISOR_FS_E,
    WAIT_QUOTIENT_F0_FS_E,
    SEND_DIVIDEND_W0_E,
    SEND_DIVISOR_2PI_E,
    WAIT_QUOTIENT_W0_2PI_E,
    SEND_SINE_OF_W0_E,
    HANDSHAKE_CORDIC_E,
    WAIT_FOR_CORDIC_E,
    SEND_DIVIDEND_SINE_W0_E,
    SEND_DIVISOR_2Q_E,
    WAIT_QUOTIENT_W0_SINE_2Q_E,
    // This state will use the results from the former states
    // and calculate coefficients depending on the filter type
    CALCULATE_COEFFICIENTS_E,
    // The following states are for normalizing to unity gain, i.e.,
    // divide the coefficients with a0
    SEND_DIVIDEND_B0_E,
    SEND_DIVISOR_A0_0_E,
    WAIT_QUOTIENT_B0_A0_E,
    SEND_DIVIDEND_B1_E,
    SEND_DIVISOR_A0_1_E,
    WAIT_QUOTIENT_B1_A0_E,
    SEND_DIVIDEND_B2_E,
    SEND_DIVISOR_A0_2_E,
    WAIT_QUOTIENT_B0_A2_E,
    SEND_DIVIDEND_A1_E,
    SEND_DIVISOR_A0_3_E,
    WAIT_QUOTIENT_A1_A0_E,
    SEND_DIVIDEND_A2_E,
    SEND_DIVISOR_A0_4_E,
    WAIT_QUOTIENT_A2_A0_E,
    WAIT_FOR_NEW_CONFIGURATION_E
  } top_state_t;

  top_state_t top_state;

  // CORDIC
  logic        [AXI_DATA_WIDTH_P-1 : 0] cordic_sine;
  logic        [AXI_DATA_WIDTH_P-1 : 0] cordic_cosine;

  // Configuration registers
  logic        [APB_DATA_WIDTH_P-1 : 0] iir_f0;
  logic        [APB_DATA_WIDTH_P-1 : 0] iir_fs;
  logic        [APB_DATA_WIDTH_P-1 : 0] iir_q;
  logic        [APB_DATA_WIDTH_P-1 : 0] iir_type;
  logic        [APB_DATA_WIDTH_P-1 : 0] bypass;

  // MVP coefficients
  logic signed         [N_BITS_P-1 : 0] w0;
  logic signed         [N_BITS_P-1 : 0] sine_of_w0;
  logic signed         [N_BITS_P-1 : 0] cosine_of_w0;
  logic signed         [N_BITS_P-1 : 0] alfa;

  // Zero and pole coefficients
  logic signed         [N_BITS_P-1 : 0] cr_zero_b0;
  logic signed         [N_BITS_P-1 : 0] cr_zero_b1;
  logic signed         [N_BITS_P-1 : 0] cr_zero_b2;
  logic signed         [N_BITS_P-1 : 0] cr_pole_a0;
  logic signed         [N_BITS_P-1 : 0] cr_pole_a1;
  logic signed         [N_BITS_P-1 : 0] cr_pole_a2;

  // Status registers to the APB slave
  assign sr_w0      = w0;
  assign sr_alfa    = alfa;
  assign sr_zero_b0 = cr_zero_b0;
  assign sr_zero_b1 = cr_zero_b1;
  assign sr_zero_b2 = cr_zero_b2;
  assign sr_pole_a0 = cr_pole_a0;
  assign sr_pole_a1 = cr_pole_a1;
  assign sr_pole_a2 = cr_pole_a2;

  // Internal signals of sine and cosine, result from the CORDIC
  assign {cordic_sine, cordic_cosine} = cordic_ing_tdata;



  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // Ports
      cordic_egr_tvalid <= '0;
      cordic_egr_tdata  <= '0;
      cordic_egr_tlast  <= '0;
      cordic_egr_tid    <= '0;
      cordic_egr_tuser  <= '0;
      cordic_ing_tready <= '0;
      div_egr_tvalid    <= '0;
      div_egr_tdata     <= '0;
      div_egr_tlast     <= '0;
      div_egr_tid       <= '0;
      div_ing_tready    <= '0;

      // FSM variables
      top_state         <= INITIALIZE_FILTER_E;
      iir_f0            <= '0;
      iir_fs            <= '0;
      iir_q             <= '0;
      iir_type          <= '0;
      bypass            <= '0;

      // MVP coefficients
      w0                <= '0;
      sine_of_w0        <= '0;
      cosine_of_w0      <= '0;
      alfa              <= '0;

      // Zero and pole coefficients
      cr_zero_b0        <= '0;
      cr_zero_b1        <= '0;
      cr_zero_b2        <= '0;
      cr_pole_a0        <= '0;
      cr_pole_a1        <= '0;
      cr_pole_a2        <= '0;

    end
    else begin

      case (top_state)

        INITIALIZE_FILTER_E: begin
          cr_zero_b0 <= ONE_C;
          if (cr_iir_q) begin
            // Q is configured last so we start after it has been written
            iir_f0    <= cr_iir_f0;
            iir_fs    <= cr_iir_fs;
            iir_q     <= cr_iir_q;
            iir_type  <= cr_iir_type;
            top_state <= SEND_DIVIDEND_F0_E;
          end
        end

        // ---------------------------------------------------------------------
        // Calculating first part of w0; (f0 / fs)
        // ---------------------------------------------------------------------


        // Sending the dividend (cut-off frequency f0) to the long divider
        SEND_DIVIDEND_F0_E: begin

          div_egr_tvalid <= '1;
          div_egr_tdata  <= cr_iir_f0;
          div_egr_tlast  <= '0;
          div_egr_tid    <= AXI4S_ID_P;
          // Wait for division
          top_state <= SEND_DIVISOR_FS_E;
        end

        // Handshaking the dividend and sending the divisior (sampling frequency fs) to the long divider
        SEND_DIVISOR_FS_E: begin
          if (div_egr_tready) begin
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_iir_fs;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              top_state      <= WAIT_QUOTIENT_F0_FS_E;
            end
          end
        end

        // ---------------------------------------------------------------------
        // Quoutient of (f0 / fs) is returned, multiply with 2*pi
        // ---------------------------------------------------------------------

        // Wait for the long divider's result of f0 over fs
        WAIT_QUOTIENT_F0_FS_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            w0             <= (div_ing_tdata * PI2_C) >>> Q_BITS_P;
            div_ing_tready <= '0;
            top_state      <= SEND_DIVIDEND_W0_E;
          end
        end

        // ---------------------------------------------------------------------
        // Calculating (w0 / (2*pi)) because the CORDIC only takes values +-2pi
        // ---------------------------------------------------------------------

        // Send dividend to the long divider
        SEND_DIVIDEND_W0_E: begin

          div_egr_tvalid <= '1;
          div_egr_tdata  <= w0;
          div_egr_tlast  <= '0;
          div_egr_tid    <= AXI4S_ID_P;
          top_state      <= SEND_DIVISOR_2PI_E;
        end

        // Send divisior to the long divider
        SEND_DIVISOR_2PI_E: begin
          if (div_egr_tready) begin
            if (!div_egr_tlast) begin
              div_egr_tdata  <= PI2_C;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              top_state      <= WAIT_QUOTIENT_W0_2PI_E;
            end
          end
        end

        // Wait for the long divider's result
        WAIT_QUOTIENT_W0_2PI_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            w0             <= (div_ing_tdata[Q_BITS_P-1 : 0] * PI2_C) >>> Q_BITS_P;
            div_ing_tready <= '0;
            top_state      <= SEND_SINE_OF_W0_E;
          end
        end

        // ---------------------------------------------------------------------
        // Calculating sin(w0) and cos(w0)
        // ---------------------------------------------------------------------

        // Send omega (w0) to the CORDIC
        SEND_SINE_OF_W0_E: begin

          cordic_egr_tvalid <= '1;
          cordic_egr_tdata  <= w0 << (AXI_DATA_WIDTH_P-4-Q_BITS_P);
          cordic_egr_tid    <= AXI4S_ID_P;
          cordic_egr_tuser  <= CORDIC_SINE_COSINE_E;     // Request both
          top_state         <= HANDSHAKE_CORDIC_E;
        end

        // Handshake with the CORDIC
        HANDSHAKE_CORDIC_E: begin
          if (cordic_egr_tready) begin
            cordic_egr_tvalid <= '0;
            top_state         <= WAIT_FOR_CORDIC_E;
          end
        end

        // Wait for the CORDIC's result of sin(w0) and cos(w0)
        WAIT_FOR_CORDIC_E: begin
          cordic_ing_tready <= '1;
          if (cordic_ing_tvalid) begin
            // CORDIC always returns +-1, the MSB is the sign, the rest are q-bits
            sine_of_w0        <= cordic_sine   >> (CORDIC_Q_BITS_C - Q_BITS_P);
            cosine_of_w0      <= cordic_cosine >> (CORDIC_Q_BITS_C - Q_BITS_P);
            cordic_ing_tready <= '0;
            top_state         <= SEND_DIVIDEND_SINE_W0_E;
          end
        end

        // ---------------------------------------------------------------------
        // Calculating alfa = sin(w0) / (2*Q)
        // ---------------------------------------------------------------------

        // Send dividend to the long divider
        SEND_DIVIDEND_SINE_W0_E: begin

          div_egr_tvalid <= '1;
          div_egr_tdata  <= sine_of_w0;
          div_egr_tlast  <= '0;
          div_egr_tid    <= AXI4S_ID_P;
          top_state      <= SEND_DIVISOR_2Q_E;
        end

        // Send divisior to the long divider
        SEND_DIVISOR_2Q_E: begin
          if (div_egr_tready) begin
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_iir_q << 1;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              top_state      <= WAIT_QUOTIENT_W0_SINE_2Q_E;
            end
          end
        end

        // Wait for the long divider's result
        WAIT_QUOTIENT_W0_SINE_2Q_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            alfa           <= div_ing_tdata;
            div_ing_tready <= '0;
            top_state      <= CALCULATE_COEFFICIENTS_E;
          end
        end

        // ---------------------------------------------------------------------
        // Now we have calculated
        //   sin(2*pi*f0/fs) / sin(w0)
        //   cos(2*pi*f0/fs)
        //   alfa = sin(w0) / (2*Q)
        //
        // We can calculate the coefficient for the selected filter type
        // ---------------------------------------------------------------------

        CALCULATE_COEFFICIENTS_E: begin

          top_state <= SEND_DIVIDEND_B0_E;

          iir_f0   <= cr_iir_f0;
          iir_fs   <= cr_iir_fs;
          iir_q    <= cr_iir_q;
          iir_type <= cr_iir_type;
          bypass   <= cr_bypass;

          cr_pole_a0 <= ONE_C + alfa;

          case (cr_iir_type)

            IIR_LOW_PASS_E: begin
              cr_zero_b0 <= (ONE_C - cosine_of_w0) >>> 1;  // b0 =  (1 - cos(w0)) / 2
              cr_zero_b1 <= (ONE_C - cosine_of_w0);        // b1 =   1 - cos(w0)
              cr_zero_b2 <= (ONE_C - cosine_of_w0) >>> 1;  // b2 =  (1 - cos(w0)) / 2
              cr_pole_a1 <= -(cosine_of_w0 << 1);          // a1 = -(2 * cos(w0))
              cr_pole_a2 <=  ONE_C - alfa;                 // a2 =   1 - alfa
            end

            IIR_HIGH_PASS_E: begin
              cr_zero_b0 <=  (ONE_C + cosine_of_w0) >>> 1; // b0 =  (1 + cos(w0)) / 2
              cr_zero_b1 <= -(ONE_C + cosine_of_w0);       // b1 = -(1 + cos(w0)
              cr_zero_b2 <=  (ONE_C + cosine_of_w0) >>> 1; // b2 =  (1 + cos(w0)) / 2
              cr_pole_a1 <= -(cosine_of_w0 << 1);          // a1 = -(2 * cos(w0))
              cr_pole_a2 <=  ONE_C - alfa;                 // a2 =   1 - alfa
            end

            IIR_BAND_PASS_E: begin
              cr_zero_b0 <=  sine_of_w0 >>> 1;             // b0 =  sin(w0) / 2
              cr_zero_b1 <= '0;                            // b1 = 0
              cr_zero_b2 <=  -sine_of_w0 >>> 1;            // b2 = -sin(w0) / 2
              cr_pole_a1 <= -(cosine_of_w0 << 1);          // a1 = -(2 * cos(w0))
              cr_pole_a2 <=  ONE_C - alfa;                 // a2 =   1 - alfa
            end

          endcase
        end

        // ---------------------------------------------------------------------
        // Next steps will normalize the response to unity gain, which means
        // we are scaling coefficients by a0, the output gain.
        // ---------------------------------------------------------------------

        // ---------------------------------------------------------------------
        // Normalizing b0 (divide with a0)
        // ---------------------------------------------------------------------

        SEND_DIVIDEND_B0_E: begin

          div_egr_tvalid <= '1;
          div_egr_tdata  <= cr_zero_b0;
          div_egr_tlast  <= '0;
          div_egr_tid    <= AXI4S_ID_P;
          top_state      <= SEND_DIVISOR_A0_0_E;
        end

        SEND_DIVISOR_A0_0_E: begin
          if (div_egr_tready) begin
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_pole_a0;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              top_state      <= WAIT_QUOTIENT_B0_A0_E;
            end
          end
        end

        WAIT_QUOTIENT_B0_A0_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            cr_zero_b0     <= div_ing_tdata;
            div_ing_tready <= '0;
            top_state      <= SEND_DIVIDEND_B1_E;
          end
        end

        // ---------------------------------------------------------------------
        // Normalizing b1 (divide with a0)
        // ---------------------------------------------------------------------

        SEND_DIVIDEND_B1_E: begin

          div_egr_tvalid <= '1;
          div_egr_tdata  <= cr_zero_b1;
          div_egr_tlast  <= '0;
          div_egr_tid    <= AXI4S_ID_P;
          top_state      <= SEND_DIVISOR_A0_1_E;
        end

        SEND_DIVISOR_A0_1_E: begin
          if (div_egr_tready) begin
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_pole_a0;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              top_state      <= WAIT_QUOTIENT_B1_A0_E;
            end
          end
        end

        WAIT_QUOTIENT_B1_A0_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            cr_zero_b1     <= div_ing_tdata;
            div_ing_tready <= '0;
            top_state      <= SEND_DIVIDEND_B2_E;
          end
        end

        // ---------------------------------------------------------------------
        // Normalizing b2 (divide with a0)
        // ---------------------------------------------------------------------

        SEND_DIVIDEND_B2_E: begin

          div_egr_tvalid <= '1;
          div_egr_tdata  <= cr_zero_b2;
          div_egr_tlast  <= '0;
          div_egr_tid    <= AXI4S_ID_P;
          top_state      <= SEND_DIVISOR_A0_2_E;
        end

        SEND_DIVISOR_A0_2_E: begin
          if (div_egr_tready) begin
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_pole_a0;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              top_state      <= WAIT_QUOTIENT_B0_A2_E;
            end
          end
        end

        WAIT_QUOTIENT_B0_A2_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            cr_zero_b2     <= div_ing_tdata;
            div_ing_tready <= '0;
            top_state      <= SEND_DIVIDEND_A1_E;
          end
        end

        // ---------------------------------------------------------------------
        // Normalizing a1 (divide with a0)
        // ---------------------------------------------------------------------

        SEND_DIVIDEND_A1_E: begin

          div_egr_tvalid <= '1;
          div_egr_tdata  <= cr_pole_a1;
          div_egr_tlast  <= '0;
          div_egr_tid    <= AXI4S_ID_P;
          top_state      <= SEND_DIVISOR_A0_3_E;
        end

        SEND_DIVISOR_A0_3_E: begin
          if (div_egr_tready) begin
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_pole_a0;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              top_state      <= WAIT_QUOTIENT_A1_A0_E;
            end
          end
        end

        WAIT_QUOTIENT_A1_A0_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            cr_pole_a1     <= div_ing_tdata;
            div_ing_tready <= '0;
            top_state      <= SEND_DIVIDEND_A2_E;
          end
        end

        // ---------------------------------------------------------------------
        // Normalizing a2 (divide with a0)
        // ---------------------------------------------------------------------

        SEND_DIVIDEND_A2_E: begin

          div_egr_tvalid <= '1;
          div_egr_tdata  <= cr_pole_a2;
          div_egr_tlast  <= '0;
          div_egr_tid    <= AXI4S_ID_P;
          top_state      <= SEND_DIVISOR_A0_4_E;
        end

        SEND_DIVISOR_A0_4_E: begin
          if (div_egr_tready) begin
            if (!div_egr_tlast) begin
              div_egr_tdata  <= cr_pole_a0;
              div_egr_tlast  <= '1;
            end
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              top_state      <= WAIT_QUOTIENT_A2_A0_E;
            end
          end
        end

        WAIT_QUOTIENT_A2_A0_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            cr_pole_a2     <= div_ing_tdata;
            div_ing_tready <= '0;
            top_state      <= WAIT_FOR_NEW_CONFIGURATION_E;
          end
        end


        WAIT_FOR_NEW_CONFIGURATION_E: begin

          // Recalculate omega
          if (cr_iir_f0 != iir_f0 || cr_iir_fs != iir_fs) begin
            top_state <= SEND_DIVIDEND_F0_E;
          end

          // Recalculate alfa
          else if (cr_iir_q != iir_q) begin
            top_state <= SEND_DIVIDEND_SINE_W0_E;
          end

          // Recalculate coefficients
          else if (cr_iir_type != iir_type) begin
            top_state <= CALCULATE_COEFFICIENTS_E;
          end

        end

      endcase

    end
  end


  iir_biquad_core #(

    .N_BITS_P   ( N_BITS_P   ),
    .Q_BITS_P   ( Q_BITS_P   )

  ) iir_biquad_core_i0 (

    .clk        ( clk        ), // input
    .rst_n      ( rst_n      ), // input

    .x0_valid   ( x_valid    ), // input
    .x0         ( x          ), // input
    .x0_ready   (            ), // output
    .y0_valid   ( y_valid    ), // output
    .y0         ( y          ), // output

    .cr_pole_a1 ( cr_pole_a1 ), // input
    .cr_pole_a2 ( cr_pole_a2 ), // input
    .cr_zero_b0 ( cr_zero_b0 ), // input
    .cr_zero_b1 ( cr_zero_b1 ), // input
    .cr_zero_b2 ( cr_zero_b2 )  // input
  );

endmodule

`default_nettype wire
