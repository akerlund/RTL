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

module oscillator_top #(
    parameter int SYS_CLK_FREQUENCY_P  = -1,
    parameter int PRIME_FREQUENCY_P    = -1,
    parameter int WAVE_WIDTH_P         = -1,
    parameter int DUTY_CYCLE_DIVIDER_P = -1, // Needs to be high so the vector will fit [N_BITS_P-1 : 0]
    parameter int N_BITS_P             = -1,
    parameter int Q_BITS_P             = -1,
    parameter int AXI_DATA_WIDTH_P     = -1,
    parameter int AXI_ID_WIDTH_P       = -1,
    parameter int AXI_ID_P             = -1
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

    // Configuration registers
    input  wire                            [1 : 0] cr_waveform_select,
    input  wire                   [N_BITS_P-1 : 0] cr_frequency,
    input  wire                   [N_BITS_P-1 : 0] cr_duty_cycle
  );

  // Waveform outputs from the core
  logic signed [WAVE_WIDTH_P-1 : 0] wave_square;
  logic signed [WAVE_WIDTH_P-1 : 0] wave_triangle;
  logic signed [WAVE_WIDTH_P-1 : 0] wave_saw;
  logic signed     [N_BITS_P-1 : 0] wave_sin;
  logic signed [WAVE_WIDTH_P-1 : 0] wave_sin_scaled;

  // Internal registers
  logic                         ready;
  logic                         update_frequency;
  logic                         update_duty_cycle;
  logic        [N_BITS_P-1 : 0] cr_frequency_r0;
  logic signed [N_BITS_P-1 : 0] cr_duty_cycle_r0;

  assign wave_sin_scaled = $signed(wave_sin) <<< (Q_BITS_P+1);

  always_comb begin
    waveform = '0;
    case (osc_waveform_type_t'(cr_waveform_select))

      OSC_SQUARE_E: begin
        waveform = wave_square;
      end

      OSC_TRIANGLE_E: begin
        waveform = wave_triangle;
      end

      OSC_SAW_E: begin
        waveform = wave_saw;
      end

      OSC_SINE_E: begin
        waveform = wave_sin_scaled;
      end

    endcase
  end


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cr_frequency_r0   <= '0;
      cr_duty_cycle_r0  <= '0;
      update_frequency  <= '0;
      update_duty_cycle <= '0;
    end
    else begin

      update_frequency  <= '0;
      update_duty_cycle <= '0;
      if (ready) begin
        if (cr_frequency != cr_frequency_r0) begin
          cr_frequency_r0  <= cr_frequency;
          update_frequency <= '1;
        end else if (cr_duty_cycle != cr_duty_cycle_r0 && !update_frequency) begin
          cr_duty_cycle_r0  <= cr_duty_cycle;
          update_duty_cycle <= '1;
        end
      end
    end
  end

  oscillator_core #(
    .SYS_CLK_FREQUENCY_P  ( SYS_CLK_FREQUENCY_P  ),
    .PRIME_FREQUENCY_P    ( PRIME_FREQUENCY_P    ),
    .WAVE_WIDTH_P         ( WAVE_WIDTH_P         ),
    .DUTY_CYCLE_DIVIDER_P ( DUTY_CYCLE_DIVIDER_P ),
    .N_BITS_P             ( N_BITS_P             ),
    .Q_BITS_P             ( Q_BITS_P             ),
    .AXI_DATA_WIDTH_P     ( AXI_DATA_WIDTH_P     ),
    .AXI_ID_WIDTH_P       ( AXI_ID_WIDTH_P       ),
    .AXI_ID_P             ( AXI_ID_P             )
  ) oscillator_core_i0 (
    .clk                  ( clk                  ), // input
    .rst_n                ( rst_n                ), // input
    .update_frequency     ( update_frequency     ), // input
    .update_duty_cycle    ( update_duty_cycle    ), // input
    .ready                ( ready                ), // output
    .wave_square          ( wave_square          ), // output
    .wave_triangle        ( wave_triangle        ), // output
    .wave_saw             ( wave_saw             ), // output
    .wave_sin             ( wave_sin             ), // output
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
    .cordic_egr_tvalid    ( egr_cor_tvalid       ), // output
    .cordic_egr_tready    ( egr_cor_tready       ), // input
    .cordic_egr_tdata     ( egr_cor_tdata        ), // output
    .cordic_egr_tlast     ( egr_cor_tlast        ), // output
    .cordic_egr_tid       ( egr_cor_tid          ), // output
    .cordic_egr_tuser     ( egr_cor_tuser        ), // output
    .cordic_ing_tvalid    ( cor_ing_tvalid       ), // input
    .cordic_ing_tready    ( cor_ing_tready       ), // output
    .cordic_ing_tdata     ( cor_ing_tdata        ), // input
    .cordic_ing_tlast     ( cor_ing_tlast        ), // input
    .cr_waveform_select   ( cr_waveform_select   ), // input
    .cr_frequency         ( cr_frequency         ), // input
    .cr_duty_cycle        ( cr_duty_cycle        )  // input
  );

endmodule

`default_nettype wire
