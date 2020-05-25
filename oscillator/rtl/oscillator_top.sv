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

module oscillator_top #(
    parameter int SYS_CLK_FREQUENCY_P = -1,
    parameter int PRIME_FREQUENCY_P   = -1,
    parameter int AXI_DATA_WIDTH_P    = -1,
    parameter int AXI_ID_WIDTH_P      = -1,
    parameter int AXI_ID_P            = -1,
    parameter int APB_BASE_ADDR_P     = -1,
    parameter int APB_ADDR_WIDTH_P    = -1,
    parameter int APB_DATA_WIDTH_P    = -1,
    parameter int WAVE_WIDTH_P        = -1,
    parameter int Q_BITS_P            = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // Waveform output
    output logic     [WAVE_WIDTH_P-1 : 0] waveform,

    // Long division interface
    output logic                          div_egr_tvalid,
    input  wire                           div_egr_tready,
    output logic [AXI_DATA_WIDTH_P-1 : 0] div_egr_tdata,
    output logic                          div_egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] div_egr_tid,

    input  wire                           div_ing_tvalid,
    output logic                          div_ing_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] div_ing_tdata,     // Quotient
    input  wire                           div_ing_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] div_ing_tid,
    input  wire                           div_ing_tuser,     // Overflow

    // APB interface
    input  wire                           apb3_psel,
    output logic                          apb3_pready,
    output logic [APB_DATA_WIDTH_P-1 : 0] apb3_prdata,
    input  wire                           apb3_pwrite,
    input  wire                           apb3_penable,
    input  wire  [APB_ADDR_WIDTH_P-1 : 0] apb3_paddr,
    input  wire  [APB_DATA_WIDTH_P-1 : 0] apb3_pwdata
  );

  logic  [APB_DATA_WIDTH_P-1 : 0] cr_waveform_select;
  logic  [APB_DATA_WIDTH_P-1 : 0] cr_frequency;
  logic  [APB_DATA_WIDTH_P-1 : 0] cr_duty_cycle;


  oscillator_core #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_P ),
    .PRIME_FREQUENCY_P   ( PRIME_FREQUENCY_P   ),
    .AXI_DATA_WIDTH_P    ( AXI_DATA_WIDTH_P    ),
    .AXI_ID_WIDTH_P      ( AXI_ID_WIDTH_P      ),
    .AXI_ID_P            ( AXI_ID_P            ),
    .APB_DATA_WIDTH_P    ( APB_DATA_WIDTH_P    ),
    .WAVE_WIDTH_P        ( WAVE_WIDTH_P        ),
    .Q_BITS_P            ( Q_BITS_P            )
  ) oscillator_core_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .waveform            ( waveform            ), // output
    .div_egr_tvalid      ( div_egr_tvalid      ), // output
    .div_egr_tready      ( div_egr_tready      ), // input
    .div_egr_tdata       ( div_egr_tdata       ), // output
    .div_egr_tlast       ( div_egr_tlast       ), // output
    .div_egr_tid         ( div_egr_tid         ), // output
    .div_ing_tvalid      ( div_ing_tvalid      ), // input
    .div_ing_tready      ( div_ing_tready      ), // output
    .div_ing_tdata       ( div_ing_tdata       ), // input
    .div_ing_tlast       ( div_ing_tlast       ), // input
    .div_ing_tid         ( div_ing_tid         ), // input
    .div_ing_tuser       ( div_ing_tuser       ), // input
    .cr_waveform_select  ( cr_waveform_select  ), // input
    .cr_frequency        ( cr_frequency        ), // input
    .cr_duty_cycle       ( cr_duty_cycle       )  // input
  );


  oscillator_apb3_slave #(
    .APB_BASE_ADDR_P     ( APB_BASE_ADDR_P     ),
    .APB_ADDR_WIDTH_P    ( APB_ADDR_WIDTH_P    ),
    .APB_DATA_WIDTH_P    ( APB_DATA_WIDTH_P    )
  ) oscillator_apb3_slave_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .apb3_psel           ( apb3_psel           ), // input
    .apb3_pready         ( apb3_pready         ), // output
    .apb3_prdata         ( apb3_prdata         ), // output
    .apb3_pwrite         ( apb3_pwrite         ), // input
    .apb3_penable        ( apb3_penable        ), // input
    .apb3_paddr          ( apb3_paddr          ), // input
    .apb3_pwdata         ( apb3_pwdata         ), // input
    .cr_waveform_select  ( cr_waveform_select  ), // output
    .cr_frequency        ( cr_frequency        ), // output
    .cr_duty_cycle       ( cr_duty_cycle       )  // output
  );

endmodule

`default_nettype wire
