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

import oscillator_types_pkg::*;

`default_nettype none

module oscillator_top_synth_wrapper #(
    parameter int SYS_CLK_FREQUENCY_P  = 200000000,
    parameter int PRIME_FREQUENCY_P    = 1000000,
    parameter int WAVE_WIDTH_P         = 24,
    parameter int DUTY_CYCLE_DIVIDER_P = 1000, // Needs to be high so the vector will fit [N_BITS_P-1 : 0]
    parameter int N_BITS_P             = 32,
    parameter int Q_BITS_P             = 22,
    parameter int AXI_DATA_WIDTH_P     = 32,
    parameter int AXI_ID_WIDTH_P       = 4,
    parameter int AXI_ID_P             = 0,
    parameter int APB_BASE_ADDR_P      = 0,
    parameter int APB_ADDR_WIDTH_P     = 32,
    parameter int APB_DATA_WIDTH_P     = 32
  )(
    // Clock and reset
    input  wire                                    clk,
    input  wire                                    rst_n,

    // Waveform output
    output logic signed       [WAVE_WIDTH_P-1 : 0] waveform,

    // Long division interface
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

    // CORDIC interface
    output logic                                   egr_cor_tvalid,
    input  wire                                    egr_cor_tready,
    output logic signed   [AXI_DATA_WIDTH_P-1 : 0] egr_cor_tdata,
    output logic                                   egr_cor_tlast,
    output logic            [AXI_ID_WIDTH_P-1 : 0] egr_cor_tid,
    output logic                                   egr_cor_tuser,     // Vector selection
    input  wire                                    cor_ing_tvalid,
    output logic                                   cor_ing_tready,
    input  wire  signed [2*AXI_DATA_WIDTH_P-1 : 0] cor_ing_tdata,
    input  wire                                    cor_ing_tlast,

    // APB interface
    input  wire                                    apb3_psel,
    output logic                                   apb3_pready,
    output logic          [APB_DATA_WIDTH_P-1 : 0] apb3_prdata,
    input  wire                                    apb3_pwrite,
    input  wire                                    apb3_penable,
    input  wire           [APB_ADDR_WIDTH_P-1 : 0] apb3_paddr,
    input  wire           [APB_DATA_WIDTH_P-1 : 0] apb3_pwdata
  );


  oscillator_top #(
    .SYS_CLK_FREQUENCY_P  ( SYS_CLK_FREQUENCY_P  ),
    .PRIME_FREQUENCY_P    ( PRIME_FREQUENCY_P    ),
    .WAVE_WIDTH_P         ( WAVE_WIDTH_P         ),
    .DUTY_CYCLE_DIVIDER_P ( DUTY_CYCLE_DIVIDER_P ),
    .N_BITS_P             ( N_BITS_P             ),
    .Q_BITS_P             ( Q_BITS_P             ),
    .AXI_DATA_WIDTH_P     ( AXI_DATA_WIDTH_P     ),
    .AXI_ID_WIDTH_P       ( AXI_ID_WIDTH_P       ),
    .AXI_ID_P             ( AXI_ID_P             ),
    .APB_BASE_ADDR_P      ( APB_BASE_ADDR_P      ),
    .APB_ADDR_WIDTH_P     ( APB_ADDR_WIDTH_P     ),
    .APB_DATA_WIDTH_P     ( APB_DATA_WIDTH_P     )
  ) oscillator_top_i0 (
    .clk                  ( clk                  ), // input
    .rst_n                ( rst_n                ), // input

    // Long division interface
    .waveform             ( waveform             ), // output
    .div_egr_tvalid       ( div_egr_tvalid       ), // output
    .div_egr_tready       ( div_egr_tready       ), // input
    .div_egr_tdata        ( div_egr_tdata        ), // output
    .div_egr_tlast        ( div_egr_tlast        ), // output
    .div_egr_tid          ( div_egr_tid          ), // output
    .div_ing_tvalid       ( div_ing_tvalid       ), // input
    .div_ing_tready       ( div_ing_tready       ), // output
    .div_ing_tdata        ( div_ing_tdata        ), // input
    .div_ing_tlast        ( div_ing_tlast        ), // input
    .div_ing_tid          ( div_ing_tid          ), // input
    .div_ing_tuser        ( div_ing_tuser        ), // input

    // CORDIC interface
    .egr_cor_tvalid       ( egr_cor_tvalid       ), // output
    .egr_cor_tready       ( egr_cor_tready       ), // input
    .egr_cor_tdata        ( egr_cor_tdata        ), // output
    .egr_cor_tlast        ( egr_cor_tlast        ), // output
    .egr_cor_tid          ( egr_cor_tid          ), // output
    .egr_cor_tuser        ( egr_cor_tuser        ), // output
    .cor_ing_tvalid       ( cor_ing_tvalid       ), // input
    .cor_ing_tready       ( cor_ing_tready       ), // output
    .cor_ing_tdata        ( cor_ing_tdata        ), // input
    .cor_ing_tlast        ( cor_ing_tlast        ), // input

    // APB interface
    .apb3_paddr           ( apb3_paddr           ), // input
    .apb3_psel            ( apb3_psel            ), // output
    .apb3_penable         ( apb3_penable         ), // output
    .apb3_pwrite          ( apb3_pwrite          ), // input
    .apb3_pwdata          ( apb3_pwdata          ), // input
    .apb3_pready          ( apb3_pready          ), // input
    .apb3_prdata          ( apb3_prdata          )  // input
  );

endmodule

`default_nettype wire
