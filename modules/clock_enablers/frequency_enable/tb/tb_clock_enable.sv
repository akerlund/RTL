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

module tb_clock_enable;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;


  localparam int SYS_CLK_FREQUENCY_C = 100000000;
  localparam int AXI_DATA_WIDTH_C    = 32;
  localparam int AXI_ID_WIDTH_C      = 2;
  localparam int N_BITS_C            = AXI_DATA_WIDTH_C;
  localparam int Q_BITS_C            = 4;
  localparam int AXI4S_ID_C          = 1;

  logic                                     enable;
  logic [$clog2(SYS_CLK_FREQUENCY_C)-1 : 0] cr_enable_frequency;
  logic                                     div_egr_tvalid;
  logic                                     div_egr_tready;
  logic            [AXI_DATA_WIDTH_C-1 : 0] div_egr_tdata;
  logic                                     div_egr_tlast;
  logic              [AXI_ID_WIDTH_C-1 : 0] div_egr_tid;
  logic                                     div_ing_tvalid;
  logic                                     div_ing_tready;
  logic            [AXI_DATA_WIDTH_C-1 : 0] div_ing_tdata;
  logic                                     div_ing_tlast;
  logic              [AXI_ID_WIDTH_C-1 : 0] div_ing_tid;
  logic                                     div_ing_tuser;

  frequency_enable #(
    .SYS_CLK_FREQUENCY_P ( SYS_CLK_FREQUENCY_C ),
    .AXI_DATA_WIDTH_P    ( AXI_DATA_WIDTH_C    ),
    .AXI_ID_WIDTH_P      ( AXI_ID_WIDTH_C      ),
    .Q_BITS_P            ( Q_BITS_C            ),
    .AXI4S_ID_P          ( AXI4S_ID_C          )
  ) frequency_enable_i0 (
    .clk                 ( clk                 ),
    .rst_n               ( rst_n               ),
    .enable              ( enable              ),
    .cr_enable_frequency ( cr_enable_frequency ),
    .div_egr_tvalid      ( div_egr_tvalid      ),
    .div_egr_tready      ( div_egr_tready      ),
    .div_egr_tdata       ( div_egr_tdata       ),
    .div_egr_tlast       ( div_egr_tlast       ),
    .div_egr_tid         ( div_egr_tid         ),
    .div_ing_tvalid      ( div_ing_tvalid      ),
    .div_ing_tready      ( div_ing_tready      ),
    .div_ing_tdata       ( div_ing_tdata       ),
    .div_ing_tlast       ( div_ing_tlast       ),
    .div_ing_tid         ( div_ing_tid         ),
    .div_ing_tuser       ( div_ing_tuser       )
  );


  long_division_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .N_BITS_P         ( N_BITS_C         ),
    .Q_BITS_P         ( Q_BITS_C         )
  ) long_division_axi4s_if_i0 (
    .clk              ( clk              ),
    .rst_n            ( rst_n            ),
    .ing_tvalid       ( div_egr_tvalid   ),
    .ing_tready       ( div_egr_tready   ),
    .ing_tdata        ( div_egr_tdata    ),
    .ing_tlast        ( div_egr_tlast    ),
    .ing_tid          ( div_egr_tid      ),
    .egr_tvalid       ( div_ing_tvalid   ),
    .egr_tdata        ( div_ing_tdata    ),
    .egr_tlast        ( div_ing_tlast    ),
    .egr_tid          ( div_ing_tid      ),
    .egr_tuser        ( div_ing_tuser    )
  );

  initial begin

    #(clk_period*20)
    @(posedge clk);
    cr_enable_frequency = 10000000;

    #1000ns;
    cr_enable_frequency = 20000000;

  end

  // Generate reset
  initial begin

    rst_n = 1'b1;

    #(clk_period*5)

    rst_n = 1'b0;

    #(clk_period*5)

    @(posedge clk);

    rst_n = 1'b1;

  end

  // Generate clock
  always begin
    #(clk_period/2)
    clk = ~clk;
  end

endmodule

