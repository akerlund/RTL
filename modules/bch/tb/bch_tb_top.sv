////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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
import bch_tb_pkg::*;
import bch_tc_pkg::*;

module bch_tb_top;

  clk_rst_if                      clk_rst_vif();
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  logic [FIFO_USER_WIDTH_C-1 : 0] ing_tuser;
  logic [FIFO_USER_WIDTH_C-1 : 0] egr_tuser;

  assign ing_tuser = {mst_vif.tlast, mst_vif.tdata};
  assign {slv_vif.tlast, slv_vif.tdata} = egr_tuser;

  assign {slv_vif.tstrb, slv_vif.tkeep, slv_vif.tid, slv_vif.tdest} = '0;


  `include "bch_params.vh"

  parameter T         = 1;
  parameter DATA_BITS = 31;

  parameter OPTION    = "SERIAL";
  parameter REG_RATIO = 1;
  parameter SEED      = 1;

  // Syndrome, data_bits, t, k, n, p
  localparam logic [`BCH_PARAM_SZ-1:0] BCH_PARAMS = bch_params(DATA_BITS, T);


  localparam TCQ        = 1;

  logic [DATA_BITS-1:0] din = 0;
  logic [$clog2(T+2)-1:0] nerr = 0;
  logic [`BCH_CODE_BITS(BCH_PARAMS)-1:0] error = 0;

  logic [31:0] seed = SEED;
  logic encode_start = 0;
  logic wrong;
  logic ready;
  logic active = 0;

  function [DATA_BITS-1:0] randk;
    input [31:0] useless;
    integer i;
    begin
      for (i = 0; i < (31 + DATA_BITS) / 32; i = i + 1)
        if (i * 32 > DATA_BITS) begin
          if (DATA_BITS % 32)
            /* Placate isim */
            randk[i*32+:(DATA_BITS%32) ? (DATA_BITS%32) : 1] = $random(seed);
        end else
          randk[i*32+:32] = $random(seed);
    end
  endfunction

  function integer n_errors;
    input [31:0] useless;
    integer i;
    begin
      n_errors = (32'h7fff_ffff & $random(seed)) % (T + 1);
    end
  endfunction

  function [`BCH_CODE_BITS(BCH_PARAMS)-1:0] rande;
    input [31:0] nerr;
    integer i;
    begin
      rande = 0;
      while (nerr) begin
        i = (32'h7fff_ffff & $random(seed)) % (`BCH_CODE_BITS(BCH_PARAMS));
        if (!((1 << i) & rande)) begin
          rande = rande | (1 << i);
          nerr = nerr - 1;
        end
      end
    end
  endfunction


  sim #(
    .P            ( BCH_PARAMS      ),
    .OPTION       ( OPTION          ),
    .BITS         ( DATA_BITS       ),
    .REG_RATIO    ( REG_RATIO       )
  ) u_sim(
    .clk          ( clk_rst_vif.clk ),
    .reset        ( 1'b0            ),
    .data_in      ( din             ),
    .error        ( error           ),
    .ready        ( ready           ),
    .encode_start ( active          ),
    .wrong        ( wrong           )
  );

  always @(posedge wrong)
    #10 $finish;

  logic [31:0] s;

  always @(posedge clk_rst_vif.clk) begin
    if (ready) begin
      s = seed;
      @(posedge clk_rst_vif.clk);
      din <= randk(0);
      @(posedge clk_rst_vif.clk);
      nerr <= n_errors(0);
      @(posedge clk_rst_vif.clk);
      error <= rande(nerr);
      @(posedge clk_rst_vif.clk);
      active <= 1;
      $display("%b %d flips - %b (seed = %d)", din, nerr, error, s);
    end
  end


  initial begin
    $display("GF(2^M=2^%1d)\nN=%1d\nK=%1d\nT=%1d\nD=%1d\nECC=%1d\nS=%1d\nOPTION=%s",
    `BCH_M(BCH_PARAMS),
    `BCH_N(BCH_PARAMS),
    `BCH_K(BCH_PARAMS),
    `BCH_T(BCH_PARAMS),
    `BCH_DATA_BITS(BCH_PARAMS),
    `BCH_ECC_BITS(BCH_PARAMS),
    `BCH_SYNDROMES_SZ(BCH_PARAMS),
    OPTION);
  end


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",            "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent0*", "vif", mst_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.slv_agent0*", "vif", slv_vif);
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
