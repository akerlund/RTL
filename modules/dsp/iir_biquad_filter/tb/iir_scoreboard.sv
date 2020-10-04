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

import vip_fixed_point_pkg::*;
import vip_math_pkg::*;
import vip_dsp_pkg::*;

`uvm_analysis_imp_decl(_apb_write_port)
`uvm_analysis_imp_decl(_apb_read_port)

class iir_scoreboard extends uvm_scoreboard;

  //`include "biquad_coefficients.svh"
  `uvm_component_utils(iir_scoreboard)

  uvm_analysis_imp_apb_write_port #(vip_apb3_item #(vip_apb3_cfg), iir_scoreboard) apb_write_port;
  uvm_analysis_imp_apb_read_port  #(vip_apb3_item #(vip_apb3_cfg), iir_scoreboard) apb_read_port;

  // Storage for comparison
  vip_apb3_item #(vip_apb3_cfg) apb_write_items [$];
  vip_apb3_item #(vip_apb3_cfg) apb_read_items  [$];

  // Debug storage
  vip_apb3_item #(vip_apb3_cfg) all_apb_write_items [$];
  vip_apb3_item #(vip_apb3_cfg) all_apb_read_items  [$];

  // For raising objections
  uvm_phase current_phase;

  int number_of_apb_write_items;
  int number_of_apb_read_items;

  // Statistics
  int number_of_compared;
  int number_of_passed;
  int number_of_failed;

  // DSP Bi-Quad parameters
  real              iir_f0;
  real              iir_fs;
  real              iir_q;
  iir_biquad_type_t iir_type;

  // DSP Bi-Quad coefficients
  real zero_b0;
  real zero_b1;
  real zero_b2;
  real pole_a1;
  real pole_a2;
  biquad_coefficients_t bq_coef;
  biquad_coefficients_t dut_bq_coef;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    apb_write_port = new("apb_write_port", this);
    apb_read_port  = new("apb_read_port", this);

  endfunction



  function void connect_phase(uvm_phase phase);

    current_phase = phase;
    super.connect_phase(current_phase);

  endfunction



  virtual task run_phase(uvm_phase phase);

    current_phase = phase;
    super.run_phase(current_phase);

  endtask



  function void check_phase(uvm_phase phase);

    current_phase = phase;
    super.check_phase(current_phase);

    // if (apb_write_items.size() > 0) begin
    //   `uvm_error(get_name(), $sformatf("There are still items in the Master queue"))
    // end

    // if (apb_read_items.size() > 0) begin
    //   `uvm_error(get_name(), $sformatf("There are still items in the Slave queue"))
    // end

    if (number_of_failed != 0) begin
      `uvm_error(get_name(), $sformatf("Test failed! (%0d) mismatches", number_of_failed))
    end
    else begin
      `uvm_info(get_name(), $sformatf("Test passed (%0d)/(%0d) finished transfers", number_of_passed, number_of_compared), UVM_LOW)
    end
  endfunction

  //----------------------------------------------------------------------------
  // APB writes
  //----------------------------------------------------------------------------

  virtual function void write_apb_write_port(vip_apb3_item #(vip_apb3_cfg) trans);

    iir_biquad_type_t t;
    number_of_apb_write_items++;
    apb_write_items.push_back(trans);
    all_apb_write_items.push_back(trans);

    if (trans.paddr == IIR_BASE_ADDR_C + CR_IIR_F0_ADDR_C) begin
      iir_f0 = real'($signed(trans.pwdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + CR_IIR_FS_ADDR_C) begin
      iir_fs = real'($signed(trans.pwdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + CR_IIR_Q_ADDR_C) begin
      iir_q = real'($signed(trans.pwdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + CR_IIR_TYPE_ADDR_C) begin
      iir_type = iir_biquad_type_t'(trans.pwdata);
    end

  endfunction

  //----------------------------------------------------------------------------
  // APB reads
  //----------------------------------------------------------------------------

  virtual function void write_apb_read_port(vip_apb3_item #(vip_apb3_cfg) trans);

    number_of_apb_read_items++;
    apb_read_items.push_back(trans);
    all_apb_read_items.push_back(trans);

    if (trans.paddr == IIR_BASE_ADDR_C + SR_W0_ADDR_C) begin
      dut_bq_coef.w0 = real'($signed(trans.prdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + SR_ALFA_ADDR_C) begin
      dut_bq_coef.alfa = real'($signed(trans.prdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + SR_ZERO_B0_ADDR_C) begin
      dut_bq_coef.b0 = real'($signed(trans.prdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + SR_ZERO_B1_ADDR_C) begin
      dut_bq_coef.b1 = real'($signed(trans.prdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + SR_ZERO_B2_ADDR_C) begin
      dut_bq_coef.b2 = real'($signed(trans.prdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + SR_POLE_A0_ADDR_C) begin
      dut_bq_coef.a0 = real'($signed(trans.prdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + SR_POLE_A1_ADDR_C) begin
      dut_bq_coef.a1 = real'($signed(trans.prdata))/2**Q_BITS_C;
    end

    else if (trans.paddr == IIR_BASE_ADDR_C + SR_POLE_A2_ADDR_C) begin
      dut_bq_coef.a2 = real'($signed(trans.prdata))/2**Q_BITS_C;
      `uvm_info(get_type_name(), $sformatf("--------------------------------------------------------------------------------"), UVM_LOW)
      `uvm_info(get_type_name(), $sformatf("DUT Bi-Quad Coefficients:"), UVM_LOW)
      print_biquad_coefficients(dut_bq_coef);

      `uvm_info(get_type_name(), $sformatf("--------------------------------------------------------------------------------"), UVM_LOW)
      `uvm_info(get_type_name(), $sformatf("SB  Bi-Quad Coefficients:"), UVM_LOW)
      bq_coef = vip_dsp_pkg::biquad_coefficients(iir_f0, iir_fs, iir_q, iir_type);
      print_biquad_coefficients(bq_coef);
    end

  endfunction


  function void print_biquad_coefficients(biquad_coefficients_t bqc);

    string coef = {$sformatf("  w0:   %f\n", bqc.w0),
                   $sformatf("  alfa: %f\n", bqc.alfa),
                   $sformatf("  b0:   %f\n", bqc.b0),
                   $sformatf("  b1:   %f\n", bqc.b1),
                   $sformatf("  b2:   %f\n", bqc.b2),
                   $sformatf("  a0:   %f\n", bqc.a0),
                   $sformatf("  a1:   %f\n", bqc.a1),
                   $sformatf("  a2:   %f\n", bqc.a2)};

    `uvm_info(get_type_name(), $sformatf("\n%s\n", coef), UVM_LOW)

  endfunction

endclass