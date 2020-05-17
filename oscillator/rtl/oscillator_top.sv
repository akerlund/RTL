////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module oscillator_top #(
    parameter int WAVE_WIDTH_P      = -1, // Resolution of the waves
    parameter int COUNTER_WIDTH_P   = -1, // Resolution of the counters
    parameter int APB3_BASE_ADDR_P  = -1,
    parameter int APB3_ADDR_WIDTH_P = -1,
    parameter int APB3_DATA_WIDTH_P = -1
  )(
    // Clock and reset
    input  wire                            clk,
    input  wire                            rst_n,

    // Waveform output
    output logic      [WAVE_WIDTH_P-1 : 0] waveform,

    // APB interface
    input  wire                            apb3_psel,
    output logic                           apb3_pready,
    output logic [APB3_DATA_WIDTH_P-1 : 0] apb3_prdata,
    input  wire                            apb3_pwrite,
    input  wire                            apb3_penable,
    input  wire  [APB3_ADDR_WIDTH_P-1 : 0] apb3_paddr,
    input  wire  [APB3_DATA_WIDTH_P-1 : 0] apb3_pwdata
  );

  logic                  [1 : 0] cr_waveform_select;
  logic  [COUNTER_WIDTH_P-1 : 0] cr_frequency;
  logic  [COUNTER_WIDTH_P-1 : 0] cr_duty_cycle;


  oscillator_core #(
    .WAVE_WIDTH_P       ( WAVE_WIDTH_P       ), // Resolution of the waves
    .COUNTER_WIDTH_P    ( COUNTER_WIDTH_P    )  // Resolution of the counters
  ) oscillator_core_i0 (
    // Clock and reset
    .clk                ( clk                ),
    .rst_n              ( rst_n              ),

    // Waveform output
    .waveform           ( waveform           ),

    // Configuration registers
    .cr_waveform_select ( cr_waveform_select ), // Selected waveform
    .cr_frequency       ( cr_frequency       ), // Counter's max value
    .cr_duty_cycle      ( cr_duty_cycle      )  // Determines when the wave goes from highest to lowest
  );


  oscillator_apb3_slave #(
    .APB3_BASE_ADDR_P   ( APB3_BASE_ADDR_P   ),
    .APB3_ADDR_WIDTH_P  ( APB3_ADDR_WIDTH_P  ),
    .APB3_DATA_WIDTH_P  ( APB3_DATA_WIDTH_P  )
  ) oscillator_apb3_slave_i0 ( 
    .clk                ( clk                ),
    .rst_n              ( rst_n              ),
    .apb3_psel          ( apb3_psel          ),
    .apb3_pready        ( apb3_pready        ),
    .apb3_prdata        ( apb3_prdata        ),
    .apb3_pwrite        ( apb3_pwrite        ),
    .apb3_penable       ( apb3_penable       ),
    .apb3_paddr         ( apb3_paddr         ),
    .apb3_pwdata        ( apb3_pwdata        ),
    .cr_waveform_select ( cr_waveform_select ),
    .cr_frequency       ( cr_frequency       ),
    .cr_duty_cycle      ( cr_duty_cycle      )
  );

endmodule

`default_nettype wire
