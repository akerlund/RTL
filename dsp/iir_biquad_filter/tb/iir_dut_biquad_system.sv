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
// This system is used for testing and contains:
//
//   - iir_biquad_top         // IIR filter
//   - iir_biquad_apb_slave   // IIR registers
//   - clock_enable           // Makes the IIR sample its input
//   - cordic_axi4s_if        // Sine/Cosine for the IIR
//   - long_division_axi4s_if // Division for the IIR
//   - oscillator_top         // Input signal for the IIR
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module iir_dut_biquad_system #(
  parameter int WAVE_WIDTH_P       = -1, // Resolution of the waves
  parameter int COUNTER_WIDTH_P    = -1, // Resolution of the counters
  parameter int N_BITS_P           = -1, // Fixed point resolution
  parameter int Q_BITS_P           = -1, // Fixed point resolution
  parameter int AXI_DATA_WIDTH_P   = -1,
  parameter int AXI_ID_WIDTH_P     = -1,
  parameter int APB_ADDR_WIDTH_P   = -1,
  parameter int APB_DATA_WIDTH_P   = -1,
  parameter int APB_NR_OF_SLAVES_P = -1
)(
  // Clock and reset
  input  wire                                                     clk,
  input  wire                                                     rst_n,

  // Waveform output
  output logic                               [WAVE_WIDTH_P-1 : 0] filtered_waveform,

  // APB interface
  input  wire                            [APB_ADDR_WIDTH_P-1 : 0] apb3_paddr,
  input  wire                          [APB_NR_OF_SLAVES_P-1 : 0] apb3_psel,
  input  wire                                                     apb3_penable,
  input  wire                                                     apb3_pwrite,
  input  wire                            [APB_DATA_WIDTH_P-1 : 0] apb3_pwdata,
  output logic                         [APB_NR_OF_SLAVES_P-1 : 0] apb3_pready,
  output logic [APB_NR_OF_SLAVES_P-1 : 0] [APB_DATA_WIDTH_P-1 : 0] apb3_prdata
);

  localparam int OSC_BASE_ADDR_C = 0;
  localparam int IIR_BASE_ADDR_C = 16;


  // Sampling enable period
  localparam logic [COUNTER_WIDTH_P-1 : 0] cr_enable_period = 200000000/48000;


  // Sampling enable
  logic                                   sampling_enable;

  // Configuration registers for IIR top
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_iir_f0;
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_iir_fs;
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_iir_q;
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_iir_type;
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_bypass;

  // AXI4-S signals betwwen the IIR top and the CORDIC
  logic                                   iir_cor_tvalid;
  logic                                   iir_cor_tready;
  logic signed   [AXI_DATA_WIDTH_P-1 : 0] iir_cor_tdata;
  logic                                   iir_cor_tlast;
  logic            [AXI_ID_WIDTH_P-1 : 0] iir_cor_tid;
  logic                                   iir_cor_tuser;
  logic                                   cor_iir_tvalid;
  logic                                   cor_iir_tready;
  logic signed [2*AXI_DATA_WIDTH_P-1 : 0] cor_iir_tdata;
  logic                                   cor_iir_tlast;
  logic            [AXI_ID_WIDTH_P-1 : 0] cor_iir_tid;

  // AXI4-S signals betwwen the IIR top and the divider
  logic                                   iir_div_tvalid;
  logic                                   iir_div_tready;
  logic          [AXI_DATA_WIDTH_P-1 : 0] iir_div_tdata;
  logic                                   iir_div_tlast;
  logic            [AXI_ID_WIDTH_P-1 : 0] iir_div_tid;
  logic                                   div_iir_tvalid;
  logic                                   div_iir_tready;
  logic          [AXI_DATA_WIDTH_P-1 : 0] div_iir_tdata;
  logic                                   div_iir_tlast;
  logic            [AXI_ID_WIDTH_P-1 : 0] div_iir_tid;
  logic                                   div_iir_tuser;

  // Oscillator
  logic            [WAVE_WIDTH_P-1 : 0] waveform;

  // No arbiter in place. CORDIC is always ready.
  assign iir_cor_tready = '1;

  iir_biquad_top #(
    .AXI_DATA_WIDTH_P  ( AXI_DATA_WIDTH_P  ),
    .AXI_ID_WIDTH_P    ( AXI_ID_WIDTH_P    ),
    .AXI4S_ID_P        ( 32'hBADC0FFE      ),
    .APB_DATA_WIDTH_P  ( APB_DATA_WIDTH_P  ),
    .N_BITS_P          ( N_BITS_P          ),
    .Q_BITS_P          ( Q_BITS_P          )
  ) iir_biquad_top_i0 (

    .clk               ( clk               ), // input
    .rst_n             ( rst_n             ), // input

    .cordic_egr_tvalid ( iir_cor_tvalid    ), // output
    .cordic_egr_tready ( iir_cor_tready    ), // input
    .cordic_egr_tdata  ( iir_cor_tdata     ), // output
    .cordic_egr_tlast  ( iir_cor_tlast     ), // output
    .cordic_egr_tid    ( iir_cor_tid       ), // output
    .cordic_egr_tuser  ( iir_cor_tuser     ), // output
    .cordic_ing_tvalid ( cor_iir_tvalid    ), // input
    .cordic_ing_tready ( cor_iir_tready    ), // output
    .cordic_ing_tdata  ( cor_iir_tdata     ), // input
    .cordic_ing_tlast  ( cor_iir_tlast     ), // input

    .div_egr_tvalid    ( iir_div_tvalid    ), // output
    .div_egr_tready    ( iir_div_tready    ), // input
    .div_egr_tdata     ( iir_div_tdata     ), // output
    .div_egr_tlast     ( iir_div_tlast     ), // output
    .div_egr_tid       ( iir_div_tid       ), // output
    .div_ing_tvalid    ( div_iir_tvalid    ), // input
    .div_ing_tready    ( div_iir_tready    ), // output
    .div_ing_tdata     ( div_iir_tdata     ), // input
    .div_ing_tlast     ( div_iir_tlast     ), // input
    .div_ing_tid       ( div_iir_tid       ), // input
    .div_ing_tuser     ( div_iir_tuser     ), // input

    .x_valid           ( sampling_enable   ), // input
    .x                 ( waveform          ), // input
    .y_valid           (                   ), // output
    .y                 ( filtered_waveform ), // output // N_BITS_P
    .cr_iir_f0         ( cr_iir_f0         ), // input
    .cr_iir_fs         ( cr_iir_fs         ), // input
    .cr_iir_q          ( cr_iir_q          ), // input
    .cr_iir_type       ( cr_iir_type       ), // input
    .cr_bypass         ( cr_bypass         )  // input
  );



  iir_biquad_apb_slave #(
    .APB_BASE_ADDR_P   ( IIR_BASE_ADDR_C   ),
    .APB_ADDR_WIDTH_P  ( APB_ADDR_WIDTH_P  ),
    .APB_DATA_WIDTH_P  ( APB_DATA_WIDTH_P  )
  ) iir_biquad_apb_slave_i0 (

    .clk               ( clk               ), // input
    .rst_n             ( rst_n             ), // input

    .apb3_paddr        ( apb3_paddr        ), // input
    .apb3_psel         ( apb3_psel[1]      ), // input
    .apb3_penable      ( apb3_penable      ), // input
    .apb3_pwrite       ( apb3_pwrite       ), // input
    .apb3_pwdata       ( apb3_pwdata       ), // input
    .apb3_pready       ( apb3_pready[1]    ), // output
    .apb3_prdata       ( apb3_prdata[1]    ), // output

    .cr_iir_f0         ( cr_iir_f0         ), // input
    .cr_iir_fs         ( cr_iir_fs         ), // input
    .cr_iir_q          ( cr_iir_q          ), // input
    .cr_iir_type       ( cr_iir_type       ), // input
    .cr_bypass         ( cr_bypass         )  // input
  );



  // Clock enable for triggering sampling
  clock_enable #(
    .COUNTER_WIDTH_P   ( COUNTER_WIDTH_P   )
  ) clock_enable_i0 (
    .clk               ( clk               ), // input
    .rst_n             ( rst_n             ), // input
    .enable            ( sampling_enable   ), // output
    .cr_enable_period  ( cr_enable_period  )  // input
  );



  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P  ( AXI_DATA_WIDTH_P  ),
    .AXI_ID_WIDTH_P    ( AXI_ID_WIDTH_P    ),
    .NR_OF_STAGES_P    ( 16                )
  ) cordic_axi4s_if_i0 (

    .clk               ( clk               ), // input
    .rst_n             ( rst_n             ), // input

    .ing_tvalid        ( iir_cor_tvalid    ), // input
    .ing_tdata         ( iir_cor_tdata     ), // input
    .ing_tid           ( iir_cor_tid       ), // input
    .ing_tuser         ( iir_cor_tuser     ), // input

    .egr_tvalid        ( cor_iir_tvalid    ), // output
    .egr_tdata         ( cor_iir_tdata     ), // output
    .egr_tid           ( cor_iir_tid       )  // output
  );



  long_division_axi4s_if #(
    .AXI_DATA_WIDTH_P  ( AXI_DATA_WIDTH_P  ),
    .AXI_ID_WIDTH_P    ( AXI_ID_WIDTH_P    ),
    .N_BITS_P          ( N_BITS_P          ),
    .Q_BITS_P          ( Q_BITS_P          )
  ) long_division_axi4s_if_i0 (

    .clk               ( clk               ), // input
    .rst_n             ( rst_n             ), // input

    .ing_tvalid        ( iir_div_tvalid    ), // input
    .ing_tready        ( iir_div_tready    ), // output
    .ing_tdata         ( iir_div_tdata     ), // input
    .ing_tlast         ( iir_div_tlast     ), // input
    .ing_tid           ( iir_div_tid       ), // input

    .egr_tvalid        ( div_iir_tvalid    ), // output
    .egr_tdata         ( div_iir_tdata     ), // output
    .egr_tlast         ( div_iir_tlast     ), // output
    .egr_tid           ( div_iir_tid       ), // output
    .egr_tuser         ( div_iir_tuser     )  // output
  );



  oscillator_top #(
    .WAVE_WIDTH_P      ( WAVE_WIDTH_P      ), // Resolution of the waves
    .COUNTER_WIDTH_P   ( COUNTER_WIDTH_P   ), // Resolution of the counters
    .APB3_BASE_ADDR_P  ( OSC_BASE_ADDR_C   ),
    .APB3_ADDR_WIDTH_P ( APB_ADDR_WIDTH_P  ),
    .APB3_DATA_WIDTH_P ( APB_DATA_WIDTH_P  )
  ) oscillator_top_i0 (

    .clk               ( clk               ), // input
    .rst_n             ( rst_n             ), // input

    .waveform          ( waveform          ), // output

    .apb3_paddr        ( apb3_paddr        ), // input
    .apb3_psel         ( apb3_psel[0]      ), // output
    .apb3_penable      ( apb3_penable      ), // output
    .apb3_pwrite       ( apb3_pwrite       ), // input
    .apb3_pwdata       ( apb3_pwdata       ), // input
    .apb3_pready       ( apb3_pready[0]    ), // input
    .apb3_prdata       ( apb3_prdata[0]    )  // input
  );

endmodule

`default_nettype wire
