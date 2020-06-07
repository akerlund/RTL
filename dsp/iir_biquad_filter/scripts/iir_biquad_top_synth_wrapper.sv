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

`default_nettype none

module iir_biquad_top_synth_wrapper #(
    parameter int AXI_DATA_WIDTH_P = 32,
    parameter int AXI_ID_WIDTH_P   = 2,
    parameter int AXI4S_ID_P       = 0,
    parameter int APB_DATA_WIDTH_P = 32,
    parameter int N_BITS_P         = 32,
    parameter int Q_BITS_P         = 11
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


  iir_biquad_top #(
    .AXI_DATA_WIDTH_P  ( AXI_DATA_WIDTH_P  ),
    .AXI_ID_WIDTH_P    ( AXI_ID_WIDTH_P    ),
    .AXI4S_ID_P        ( AXI4S_ID_P        ),
    .APB_DATA_WIDTH_P  ( APB_DATA_WIDTH_P  ),
    .N_BITS_P          ( N_BITS_P          ),
    .Q_BITS_P          ( Q_BITS_P          )
  ) iir_biquad_top_i0 (

    // Clock and reset
    .clk               ( clk               ), // input
    .rst_n             ( rst_n             ), // input

    // CORDIC interface
    .cordic_egr_tvalid ( cordic_egr_tvalid ), // output
    .cordic_egr_tready ( cordic_egr_tready ), // input
    .cordic_egr_tdata  ( cordic_egr_tdata  ), // output
    .cordic_egr_tlast  ( cordic_egr_tlast  ), // output
    .cordic_egr_tid    ( cordic_egr_tid    ), // output
    .cordic_egr_tuser  ( cordic_egr_tuser  ), // output
    .cordic_ing_tvalid ( cordic_ing_tvalid ), // input
    .cordic_ing_tready ( cordic_ing_tready ), // output
    .cordic_ing_tdata  ( cordic_ing_tdata  ), // input
    .cordic_ing_tlast  ( cordic_ing_tlast  ), // input

    // Long division interface
    .div_egr_tvalid    ( div_egr_tvalid    ), // output
    .div_egr_tready    ( div_egr_tready    ), // input
    .div_egr_tdata     ( div_egr_tdata     ), // output
    .div_egr_tlast     ( div_egr_tlast     ), // output
    .div_egr_tid       ( div_egr_tid       ), // output
    .div_ing_tvalid    ( div_ing_tvalid    ), // input
    .div_ing_tready    ( div_ing_tready    ), // output
    .div_ing_tdata     ( div_ing_tdata     ), // input
    .div_ing_tlast     ( div_ing_tlast     ), // input
    .div_ing_tid       ( div_ing_tid       ), // input
    .div_ing_tuser     ( div_ing_tuser     ), // input

    // Filter ports
    .x_valid           ( x_valid           ), // input
    .x                 ( x                 ), // input
    .y_valid           ( y_valid           ), // output
    .y                 ( y                 ), // output

    // APB registers
    .cr_iir_f0         ( cr_iir_f0         ), // input
    .cr_iir_fs         ( cr_iir_fs         ), // input
    .cr_iir_q          ( cr_iir_q          ), // input
    .cr_iir_type       ( cr_iir_type       ), // input
    .cr_bypass         ( cr_bypass         ), // input
    .sr_w0             ( sr_w0             ), // output
    .sr_alfa           ( sr_alfa           ), // output
    .sr_zero_b0        ( sr_zero_b0        ), // output
    .sr_zero_b1        ( sr_zero_b1        ), // output
    .sr_zero_b2        ( sr_zero_b2        ), // output
    .sr_pole_a0        ( sr_pole_a0        ), // output
    .sr_pole_a1        ( sr_pole_a1        ), // output
    .sr_pole_a2        ( sr_pole_a2        )  // output
  );


endmodule

`default_nettype wire
