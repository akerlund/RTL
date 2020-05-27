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
  parameter int WAVE_WIDTH_P        = -1, // Resolution of the waves
  parameter int COUNTER_WIDTH_P     = -1, // Resolution of the counters
  parameter int N_BITS_P            = -1, // Fixed point resolution
  parameter int Q_BITS_P            = -1, // Fixed point resolution
  parameter int AXI_DATA_WIDTH_P    = -1,
  parameter int AXI_ID_WIDTH_P      = -1,
  parameter int APB_ADDR_WIDTH_P    = -1,
  parameter int APB_DATA_WIDTH_P    = -1,
  parameter int APB_NR_OF_SLAVES_P  = -1,
  parameter int SYS_CLK_FREQUENCY_P = 250000000,
  parameter int PRIME_FREQUENCY_P   = 1000000,
  parameter int AXI_ID_P            = 1
)(
  // Clock and reset
  input  wire                                                        clk,
  input  wire                                                        rst_n,

  // Waveform output
  output logic                                  [WAVE_WIDTH_P-1 : 0] filtered_waveform,

  // APB interface
  input  wire                               [APB_ADDR_WIDTH_P-1 : 0] apb3_paddr,
  input  wire                             [APB_NR_OF_SLAVES_P-1 : 0] apb3_psel,
  input  wire                                                        apb3_penable,
  input  wire                                                        apb3_pwrite,
  input  wire                               [APB_DATA_WIDTH_P-1 : 0] apb3_pwdata,
  output logic                            [APB_NR_OF_SLAVES_P-1 : 0] apb3_pready,
  output logic [APB_NR_OF_SLAVES_P-1 : 0]   [APB_DATA_WIDTH_P-1 : 0] apb3_prdata
);

  localparam int OSC_BASE_ADDR_C = 0;
  localparam int IIR_BASE_ADDR_C = 16;



  // Sampling enable
  logic                                   sampling_enable;

  // Configuration registers for IIR top
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_iir_f0;
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_iir_fs;
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_iir_q;
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_iir_type;
  logic          [APB_DATA_WIDTH_P-1 : 0] cr_bypass;

  logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_zero_b0;
  logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_zero_b1;
  logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_zero_b2;
  logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_pole_a1;
  logic signed   [APB_DATA_WIDTH_P-1 : 0] sr_pole_a2;

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

  // AXI4-S signals betwwen the Oscillator top and the divider
  logic                                   osc_div_tvalid;
  logic                                   osc_div_tready;
  logic          [AXI_DATA_WIDTH_P-1 : 0] osc_div_tdata;
  logic                                   osc_div_tlast;
  logic            [AXI_ID_WIDTH_P-1 : 0] osc_div_tid;
  logic                                   div_osc_tvalid;
  logic                                   div_osc_tready;
  logic          [AXI_DATA_WIDTH_P-1 : 0] div_osc_tdata;
  logic                                   div_osc_tlast;
  logic            [AXI_ID_WIDTH_P-1 : 0] div_osc_tid;
  logic                                   div_osc_tuser;

  // AXI4-S signals betwwen the Frequency Enable and the divider
  logic                                   fen_div_tvalid;
  logic                                   fen_div_tready;
  logic          [AXI_DATA_WIDTH_P-1 : 0] fen_div_tdata;
  logic                                   fen_div_tlast;
  logic            [AXI_ID_WIDTH_P-1 : 0] fen_div_tid;
  logic                                   div_fen_tvalid;
  logic                                   div_fen_tready;
  logic          [AXI_DATA_WIDTH_P-1 : 0] div_fen_tdata;
  logic                                   div_fen_tlast;
  logic            [AXI_ID_WIDTH_P-1 : 0] div_fen_tid;
  logic                                   div_fen_tuser;

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
    .cr_bypass         ( cr_bypass         ), // input
    .sr_zero_b0        ( sr_zero_b0        ), // output
    .sr_zero_b1        ( sr_zero_b1        ), // output
    .sr_zero_b2        ( sr_zero_b2        ), // output
    .sr_pole_a1        ( sr_pole_a1        ), // output
    .sr_pole_a2        ( sr_pole_a2        )  // output
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

    .cr_iir_f0         ( cr_iir_f0         ), // output
    .cr_iir_fs         ( cr_iir_fs         ), // output
    .cr_iir_q          ( cr_iir_q          ), // output
    .cr_iir_type       ( cr_iir_type       ), // output
    .cr_bypass         ( cr_bypass         ), // output

    .sr_zero_b0        ( sr_zero_b0        ), // input
    .sr_zero_b1        ( sr_zero_b1        ), // input
    .sr_zero_b2        ( sr_zero_b2        ), // input
    .sr_pole_a1        ( sr_pole_a1        ), // input
    .sr_pole_a2        ( sr_pole_a2        )  // input
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
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
    .N_BITS_P         ( N_BITS_P         ),
    .Q_BITS_P         ( Q_BITS_P         )
  ) long_division_axi4s_if_i0 (

    .clk              ( clk              ), // input
    .rst_n            ( rst_n            ), // input

    .ing_tvalid       ( iir_div_tvalid   ), // input
    .ing_tready       ( iir_div_tready   ), // output
    .ing_tdata        ( iir_div_tdata    ), // input
    .ing_tlast        ( iir_div_tlast    ), // input
    .ing_tid          ( iir_div_tid      ), // input

    .egr_tvalid       ( div_iir_tvalid   ), // output
    .egr_tdata        ( div_iir_tdata    ), // output
    .egr_tlast        ( div_iir_tlast    ), // output
    .egr_tid          ( div_iir_tid      ), // output
    .egr_tuser        ( div_iir_tuser    )  // output
  );



  oscillator_top #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_P ),
    .PRIME_FREQUENCY_P   ( PRIME_FREQUENCY_P   ),
    .AXI_DATA_WIDTH_P    ( AXI_DATA_WIDTH_P    ),
    .AXI_ID_WIDTH_P      ( AXI_ID_WIDTH_P      ),
    .AXI_ID_P            ( AXI_ID_P            ),
    .APB_BASE_ADDR_P     ( OSC_BASE_ADDR_C     ),
    .APB_ADDR_WIDTH_P    ( APB_ADDR_WIDTH_P    ),
    .APB_DATA_WIDTH_P    ( APB_DATA_WIDTH_P    ),
    .WAVE_WIDTH_P        ( WAVE_WIDTH_P        ),
    .Q_BITS_P            ( Q_BITS_P            )
  ) oscillator_top_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .waveform            ( waveform            ), // output
    .div_egr_tvalid      ( osc_div_tvalid      ), // output
    .div_egr_tready      ( osc_div_tready      ), // input
    .div_egr_tdata       ( osc_div_tdata       ), // output
    .div_egr_tlast       ( osc_div_tlast       ), // output
    .div_egr_tid         ( osc_div_tid         ), // output
    .div_ing_tvalid      ( div_osc_tvalid      ), // input
    .div_ing_tready      ( div_osc_tready      ), // output
    .div_ing_tdata       ( div_osc_tdata       ), // input
    .div_ing_tlast       ( div_osc_tlast       ), // input
    .div_ing_tid         ( div_osc_tid         ), // input
    .div_ing_tuser       ( div_osc_tuser       ), // input
    .apb3_paddr          ( apb3_paddr          ), // input
    .apb3_psel           ( apb3_psel[0]        ), // output
    .apb3_penable        ( apb3_penable        ), // output
    .apb3_pwrite         ( apb3_pwrite         ), // input
    .apb3_pwdata         ( apb3_pwdata         ), // input
    .apb3_pready         ( apb3_pready[0]      ), // input
    .apb3_prdata         ( apb3_prdata[0]      )  // input
  );

  long_division_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
    .N_BITS_P         ( AXI_DATA_WIDTH_P ),
    .Q_BITS_P         ( Q_BITS_P         )
  ) long_division_axi4s_if_i1 (

    .clk              ( clk              ), // input
    .rst_n            ( rst_n            ), // input

    .ing_tvalid       ( osc_div_tvalid   ), // input
    .ing_tready       ( osc_div_tready   ), // output
    .ing_tdata        ( osc_div_tdata    ), // input
    .ing_tlast        ( osc_div_tlast    ), // input
    .ing_tid          ( osc_div_tid      ), // input

    .egr_tvalid       ( div_osc_tvalid   ), // output
    .egr_tdata        ( div_osc_tdata    ), // output
    .egr_tlast        ( div_osc_tlast    ), // output
    .egr_tid          ( div_osc_tid      ), // output
    .egr_tuser        ( div_osc_tuser    )  // output
  );



  frequency_enable #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_P ),
    .AXI_DATA_WIDTH_P    ( AXI_DATA_WIDTH_P    ),
    .AXI_ID_WIDTH_P      ( AXI_ID_WIDTH_P      ),
    .Q_BITS_P            ( 0                   ),
    .AXI4S_ID_P          ( 0                   )
  ) frequency_enable_i0 (
    .clk                 ( clk                 ),
    .rst_n               ( rst_n               ),
    .enable              ( sampling_enable     ),
    .cr_enable_frequency ( (cr_iir_fs >> Q_BITS_P) ),
    .div_egr_tvalid      ( fen_div_tvalid      ),
    .div_egr_tready      ( fen_div_tready      ),
    .div_egr_tdata       ( fen_div_tdata       ),
    .div_egr_tlast       ( fen_div_tlast       ),
    .div_egr_tid         ( fen_div_tid         ),
    .div_ing_tvalid      ( div_fen_tvalid      ),
    .div_ing_tready      ( div_fen_tready      ),
    .div_ing_tdata       ( div_fen_tdata       ),
    .div_ing_tlast       ( div_fen_tlast       ),
    .div_ing_tid         ( div_fen_tid         ),
    .div_ing_tuser       ( div_fen_tuser       )
  );

  long_division_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
    .N_BITS_P         ( AXI_DATA_WIDTH_P ),
    .Q_BITS_P         ( 0                )
  ) long_division_axi4s_if_i2 (

    .clk              ( clk              ), // input
    .rst_n            ( rst_n            ), // input

    .ing_tvalid       ( fen_div_tvalid   ), // input
    .ing_tready       ( fen_div_tready   ), // output
    .ing_tdata        ( fen_div_tdata    ), // input
    .ing_tlast        ( fen_div_tlast    ), // input
    .ing_tid          ( fen_div_tid      ), // input

    .egr_tvalid       ( div_fen_tvalid   ), // output
    .egr_tdata        ( div_fen_tdata    ), // output
    .egr_tlast        ( div_fen_tlast    ), // output
    .egr_tid          ( div_fen_tid      ), // output
    .egr_tuser        ( div_fen_tuser    )  // output
  );






endmodule

`default_nettype wire
