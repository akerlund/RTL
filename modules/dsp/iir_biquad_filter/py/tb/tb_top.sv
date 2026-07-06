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

module tb_top;

  localparam int AXI_DATA_WIDTH_C = 32;
  localparam int AXI_ID_WIDTH_C   = 4;
  localparam int AXI4S_ID_C       = 1;
  localparam int N_BITS_C         = 32;
  localparam int Q_BITS_C         = 17;

  logic                                  clk;
  logic                                  rst_n;
  logic                                  x_valid;
  logic signed       [N_BITS_C-1 : 0]    x;
  logic                                  y_valid;
  logic signed       [N_BITS_C-1 : 0]    y;
  logic             [N_BITS_C-1 : 0]     cr_iir_f0;
  logic             [N_BITS_C-1 : 0]     cr_iir_fs;
  logic             [N_BITS_C-1 : 0]     cr_iir_q;
  logic             [N_BITS_C-1 : 0]     cr_iir_type;
  logic             [N_BITS_C-1 : 0]     cr_bypass;
  logic signed      [N_BITS_C-1 : 0]     sr_w0;
  logic signed      [N_BITS_C-1 : 0]     sr_alfa;
  logic signed      [N_BITS_C-1 : 0]     sr_zero_b0;
  logic signed      [N_BITS_C-1 : 0]     sr_zero_b1;
  logic signed      [N_BITS_C-1 : 0]     sr_zero_b2;
  logic signed      [N_BITS_C-1 : 0]     sr_pole_a0;
  logic signed      [N_BITS_C-1 : 0]     sr_pole_a1;
  logic signed      [N_BITS_C-1 : 0]     sr_pole_a2;

  logic                                  osc_cor_tvalid;
  logic signed   [AXI_DATA_WIDTH_C-1 : 0] osc_cor_tdata;
  logic            [AXI_ID_WIDTH_C-1 : 0] osc_cor_tid;
  logic                                  osc_cor_tuser;
  logic                                  cor_osc_tvalid;
  logic signed [2*AXI_DATA_WIDTH_C-1 : 0] cor_osc_tdata;
  logic            [AXI_ID_WIDTH_C-1 : 0] cor_osc_tid;
  logic                                  osc_div_tvalid;
  logic                                  osc_div_tready;
  logic          [AXI_DATA_WIDTH_C-1 : 0] osc_div_tdata;
  logic                                  osc_div_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] osc_div_tid;
  logic                                  div_osc_tvalid;
  logic                                  div_osc_tready;
  logic          [AXI_DATA_WIDTH_C-1 : 0] div_osc_tdata;
  logic                                  div_osc_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] div_osc_tid;
  logic                                  div_osc_tuser;

  iir_biquad_top #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .AXI4S_ID_P       ( AXI4S_ID_C       ),
    .N_BITS_P         ( N_BITS_C         ),
    .Q_BITS_P         ( Q_BITS_C         )
  ) dut (
    .clk                ( clk            ),
    .rst_n              ( rst_n          ),
    .x_valid            ( x_valid        ),
    .x                  ( x              ),
    .y_valid            ( y_valid        ),
    .y                  ( y              ),
    .cordic_egr_tvalid  ( osc_cor_tvalid ),
    .cordic_egr_tready  ( '1             ),
    .cordic_egr_tdata   ( osc_cor_tdata  ),
    .cordic_egr_tlast   (                ),
    .cordic_egr_tid     ( osc_cor_tid    ),
    .cordic_egr_tuser   ( osc_cor_tuser  ),
    .cordic_ing_tvalid  ( cor_osc_tvalid ),
    .cordic_ing_tready  (                ),
    .cordic_ing_tdata   ( cor_osc_tdata  ),
    .cordic_ing_tlast   ( '1             ),
    .div_egr_tvalid     ( osc_div_tvalid ),
    .div_egr_tready     ( osc_div_tready ),
    .div_egr_tdata      ( osc_div_tdata  ),
    .div_egr_tlast      ( osc_div_tlast  ),
    .div_egr_tid        ( osc_div_tid    ),
    .div_ing_tvalid     ( div_osc_tvalid ),
    .div_ing_tready     ( div_osc_tready ),
    .div_ing_tdata      ( div_osc_tdata  ),
    .div_ing_tlast      ( div_osc_tlast  ),
    .div_ing_tid        ( div_osc_tid    ),
    .div_ing_tuser      ( div_osc_tuser  ),
    .cr_iir_f0          ( cr_iir_f0      ),
    .cr_iir_fs          ( cr_iir_fs      ),
    .cr_iir_q           ( cr_iir_q       ),
    .cr_iir_type        ( cr_iir_type    ),
    .cr_bypass          ( cr_bypass      ),
    .sr_w0              ( sr_w0          ),
    .sr_alfa            ( sr_alfa        ),
    .sr_zero_b0         ( sr_zero_b0     ),
    .sr_zero_b1         ( sr_zero_b1     ),
    .sr_zero_b2         ( sr_zero_b2     ),
    .sr_pole_a0         ( sr_pole_a0     ),
    .sr_pole_a1         ( sr_pole_a1     ),
    .sr_pole_a2         ( sr_pole_a2     )
  );

  long_division_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .N_BITS_P         ( AXI_DATA_WIDTH_C ),
    .Q_BITS_P         ( Q_BITS_C         )
  ) long_division_axi4s_if_i0 (
    .clk              ( clk              ),
    .rst_n            ( rst_n            ),
    .ing_tvalid       ( osc_div_tvalid   ),
    .ing_tready       ( osc_div_tready   ),
    .ing_tdata        ( osc_div_tdata    ),
    .ing_tlast        ( osc_div_tlast    ),
    .ing_tid          ( osc_div_tid      ),
    .egr_tvalid       ( div_osc_tvalid   ),
    .egr_tdata        ( div_osc_tdata    ),
    .egr_tlast        ( div_osc_tlast    ),
    .egr_tid          ( div_osc_tid      ),
    .egr_tuser        ( div_osc_tuser    )
  );

  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .NR_OF_STAGES_P   ( 16               )
  ) cordic_axi4s_if_i0 (
    .clk              ( clk              ),
    .rst_n            ( rst_n            ),
    .ing_tvalid       ( osc_cor_tvalid   ),
    .ing_tdata        ( osc_cor_tdata    ),
    .ing_tid          ( osc_cor_tid      ),
    .ing_tuser        ( osc_cor_tuser    ),
    .egr_tvalid       ( cor_osc_tvalid   ),
    .egr_tdata        ( cor_osc_tdata    ),
    .egr_tid          ( cor_osc_tid      )
  );

endmodule

`default_nettype wire
