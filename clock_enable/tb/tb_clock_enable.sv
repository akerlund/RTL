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
// Simple test bench used to develop the fixed point functions in the
// package file "vip_fixed_point_pkg".
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

