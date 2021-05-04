////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
// https://github.com/akerlund/RTL
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

import uvm_pkg::*;
import iir_tb_pkg::*;
import iir_tc_pkg::*;

module iir_tb_top;

  clk_rst_if                      clk_rst_vif();
  vip_axi4_if    #(VIP_REG_CFG_C) reg_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  axi4_reg_if  #(
    .AXI4_ID_WIDTH_P   ( VIP_REG_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI4_ADDR_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI4_DATA_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI4_STRB_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_STRB_WIDTH_P )
  ) osc_cfg_if (clk_rst_vif.clk, clk_rst_vif.rst_n);


  // Register slave
  assign osc_cfg_if.awaddr  = reg_vif.awaddr;
  assign osc_cfg_if.awvalid = reg_vif.awvalid;
  assign reg_vif.awready    = osc_cfg_if.awready;
  assign osc_cfg_if.wdata   = reg_vif.wdata;
  assign osc_cfg_if.wstrb   = reg_vif.wstrb;
  assign osc_cfg_if.wlast   = reg_vif.wlast;
  assign osc_cfg_if.wvalid  = reg_vif.wvalid;
  assign reg_vif.wready     = osc_cfg_if.wready;
  assign reg_vif.bresp      = osc_cfg_if.bresp;
  assign reg_vif.bvalid     = osc_cfg_if.bvalid;
  assign osc_cfg_if.bready  = reg_vif.bready;
  assign osc_cfg_if.araddr  = reg_vif.araddr;
  assign osc_cfg_if.arlen   = reg_vif.arlen;
  assign osc_cfg_if.arvalid = reg_vif.arvalid;
  assign reg_vif.arready    = osc_cfg_if.arready;
  assign reg_vif.rdata      = osc_cfg_if.rdata;
  assign reg_vif.rresp      = osc_cfg_if.rresp;
  assign reg_vif.rlast      = osc_cfg_if.rlast;
  assign reg_vif.rvalid     = osc_cfg_if.rvalid;
  assign osc_cfg_if.rready  = reg_vif.rready;

  logic                                   sampling_enable;

  // IIR - CORDIC
  logic                                   iir_cor_tvalid;
  logic                                   iir_cor_tready;
  logic signed           [N_BITS_C-1 : 0] iir_cor_tdata;
  logic                                   iir_cor_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] iir_cor_tid;
  logic                                   iir_cor_tuser;
  logic                                   cor_iir_tvalid;
  logic                                   cor_iir_tready;
  logic signed         [2*N_BITS_C-1 : 0] cor_iir_tdata;
  logic                                   cor_iir_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] cor_iir_tid;

  // IIR - Divider
  logic                                   iir_div_tvalid;
  logic                                   iir_div_tready;
  logic                  [N_BITS_C-1 : 0] iir_div_tdata;
  logic                                   iir_div_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] iir_div_tid;
  logic                                   div_iir_tvalid;
  logic                                   div_iir_tready;
  logic                  [N_BITS_C-1 : 0] div_iir_tdata;
  logic                                   div_iir_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] div_iir_tid;
  logic                                   div_iir_tuser;

  // Frequency Enable - Divider
  logic                                   fen_div_tvalid;
  logic                                   fen_div_tready;
  logic                  [N_BITS_C-1 : 0] fen_div_tdata;
  logic                                   fen_div_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] fen_div_tid;
  logic                                   div_fen_tvalid;
  logic                                   div_fen_tready;
  logic                  [N_BITS_C-1 : 0] div_fen_tdata;
  logic                                   div_fen_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] div_fen_tid;
  logic                                   div_fen_tuser;

  // Registers
  logic          [CFG_DATA_WIDTH_C-1 : 0] cr_iir_f0;
  logic          [CFG_DATA_WIDTH_C-1 : 0] cr_iir_fs;
  logic          [CFG_DATA_WIDTH_C-1 : 0] cr_iir_q;
  logic          [CFG_DATA_WIDTH_C-1 : 0] cr_iir_type;
  logic          [CFG_DATA_WIDTH_C-1 : 0] cr_iir_bypass;
  logic signed   [CFG_DATA_WIDTH_C-1 : 0] sr_iir_w0;
  logic signed   [CFG_DATA_WIDTH_C-1 : 0] sr_iir_alfa;
  logic signed   [CFG_DATA_WIDTH_C-1 : 0] sr_iir_zero_b0;
  logic signed   [CFG_DATA_WIDTH_C-1 : 0] sr_iir_zero_b1;
  logic signed   [CFG_DATA_WIDTH_C-1 : 0] sr_iir_zero_b2;
  logic signed   [CFG_DATA_WIDTH_C-1 : 0] sr_iir_pole_a0;
  logic signed   [CFG_DATA_WIDTH_C-1 : 0] sr_iir_pole_a1;
  logic signed   [CFG_DATA_WIDTH_C-1 : 0] sr_iir_pole_a2;

  assign iir_cor_tready = '1;
  assign mst_vif.tready = '1;

  iir_biquad_top #(
    .AXI_DATA_WIDTH_P  ( N_BITS_C         ),
    .AXI_ID_WIDTH_P    ( AXI_ID_WIDTH_C   ),
    .AXI4S_ID_P        ( '0               ),
    .APB_DATA_WIDTH_P  ( CFG_DATA_WIDTH_C ),
    .N_BITS_P          ( N_BITS_C         ),
    .Q_BITS_P          ( Q_BITS_C         )
  ) iir_biquad_top_i0 (

    // Clock and reset
    .clk               ( clk              ), // input
    .rst_n             ( rst_n            ), // input

    // Filter ports
    .x_valid           ( sampling_enable  ), // input
    .x                 ( mst_vif.tdata    ), // input
    .y_valid           (                  ), // output
    .y                 (                  ), // output

    // CORDIC interface
    .cordic_egr_tvalid ( iir_cor_tvalid   ), // output
    .cordic_egr_tready ( iir_cor_tready   ), // input
    .cordic_egr_tdata  ( iir_cor_tdata    ), // output
    .cordic_egr_tlast  ( iir_cor_tlast    ), // output
    .cordic_egr_tid    ( iir_cor_tid      ), // output
    .cordic_egr_tuser  ( iir_cor_tuser    ), // output
    .cordic_ing_tvalid ( cor_iir_tvalid   ), // input
    .cordic_ing_tready ( cor_iir_tready   ), // output
    .cordic_ing_tdata  ( cor_iir_tdata    ), // input
    .cordic_ing_tlast  ( cor_iir_tlast    ), // input

    // Long division interface
    .div_egr_tvalid    ( iir_div_tvalid   ), // output
    .div_egr_tready    ( iir_div_tready   ), // input
    .div_egr_tdata     ( iir_div_tdata    ), // output
    .div_egr_tlast     ( iir_div_tlast    ), // output
    .div_egr_tid       ( iir_div_tid      ), // output
    .div_ing_tvalid    ( div_iir_tvalid   ), // input
    .div_ing_tready    ( div_iir_tready   ), // output
    .div_ing_tdata     ( div_iir_tdata    ), // input
    .div_ing_tlast     ( div_iir_tlast    ), // input
    .div_ing_tid       ( div_iir_tid      ), // input
    .div_ing_tuser     ( div_iir_tuser    ), // input

    // Registers
    .cr_iir_f0         ( cr_iir_f0        ), // input
    .cr_iir_fs         ( cr_iir_fs        ), // input
    .cr_iir_q          ( cr_iir_q         ), // input
    .cr_iir_type       ( cr_iir_type      ), // input
    .cr_bypass         ( cr_iir_bypass    ), // input
    .sr_w0             ( sr_iir_w0        ), // output
    .sr_alfa           ( sr_iir_alfa      ), // output
    .sr_zero_b0        ( sr_iir_zero_b0   ), // output
    .sr_zero_b1        ( sr_iir_zero_b1   ), // output
    .sr_zero_b2        ( sr_iir_zero_b2   ), // output
    .sr_pole_a0        ( sr_iir_pole_a0   ), // output
    .sr_pole_a1        ( sr_iir_pole_a1   ), // output
    .sr_pole_a2        ( sr_iir_pole_a2   )  // output
  );



  iir_axi_slave #(
    .AXI_ADDR_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI_ID_P         ( '0                                  ),
    .N_BITS_C         ( N_BITS_C                            )
  ) iir_axi_slave_i0 (
    .cif              ( osc_cfg_if                          ), // interface
    .cr_iir_f0        ( cr_iir_f0                           ), // output
    .cr_iir_fs        ( cr_iir_fs                           ), // output
    .cr_iir_q         ( cr_iir_q                            ), // output
    .cr_iir_type      ( cr_iir_type                         ), // output
    .cr_iir_bypass    ( cr_iir_bypass                       ), // output
    .sr_iir_w0        ( sr_iir_w0                           ), // input
    .sr_iir_alfa      ( sr_iir_alfa                         ), // input
    .sr_iir_b0        ( sr_iir_zero_b0                      ), // input
    .sr_iir_b1        ( sr_iir_zero_b1                      ), // input
    .sr_iir_b2        ( sr_iir_zero_b2                      ), // input
    .sr_iir_a0        ( sr_iir_pole_a0                      ), // input
    .sr_iir_a1        ( sr_iir_pole_a1                      ), // input
    .sr_iir_a2        ( sr_iir_pole_a2                      )  // input
  );


  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P  ( N_BITS_C          ),
    .AXI_ID_WIDTH_P    ( AXI_ID_WIDTH_C    ),
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
    .AXI_DATA_WIDTH_P ( N_BITS_C         ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .N_BITS_P         ( N_BITS_C         ),
    .Q_BITS_P         ( Q_BITS_C         )
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


  frequency_enable #(
    .SYS_CLK_FREQUENCY_P ( 125000000           ),
    .AXI_DATA_WIDTH_P    ( N_BITS_C            ),
    .AXI_ID_WIDTH_P      ( AXI_ID_WIDTH_C      ),
    .Q_BITS_P            ( Q_BITS_C            ),
    .AXI4S_ID_P          ( 0                   )
  ) frequency_enable_i0 (
    .clk                 ( clk                 ),
    .rst_n               ( rst_n               ),
    .enable              ( sampling_enable     ),
    .cr_enable_frequency ( cr_iir_fs           ),
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
    .AXI_DATA_WIDTH_P ( N_BITS_C         ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .N_BITS_P         ( N_BITS_C         ),
    .Q_BITS_P         ( Q_BITS_C         )
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

  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",            "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4_if  #(VIP_REG_CFG_C))::set(uvm_root::get(),   "uvm_test_top.tb_env.reg_agent0*", "vif", reg_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent0*", "vif", mst_vif);
    run_test();
    $stop();
  end


  initial begin
    $timeformat(-9, 0, "", 11);  // units, precision, suffix, min field width
    if ($test$plusargs("RECORD")) begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_FULL);
    end else begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_NONE);
    end
  end

endmodule
