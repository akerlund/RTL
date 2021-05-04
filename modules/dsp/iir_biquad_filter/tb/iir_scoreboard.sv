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

`uvm_analysis_imp_decl(_wdata_port)
`uvm_analysis_imp_decl(_rdata_port)

class iir_scoreboard extends uvm_scoreboard;

  //`include "biquad_coefficients.svh"
  `uvm_component_utils(iir_scoreboard)

  uvm_analysis_imp_wdata_port #(vip_axi4_item #(VIP_REG_CFG_C), iir_scoreboard) wdata_port;
  uvm_analysis_imp_rdata_port #(vip_axi4_item #(VIP_REG_CFG_C), iir_scoreboard) rdata_port;

  // Storage for comparison
  vip_axi4_item #(VIP_REG_CFG_C) wdata_items [$];
  vip_axi4_item #(VIP_REG_CFG_C) rdata_items  [$];

  // Debug storage
  vip_axi4_item #(VIP_REG_CFG_C) all_wdata_items [$];
  vip_axi4_item #(VIP_REG_CFG_C) all_rdata_items  [$];

  // For raising objections
  uvm_phase current_phase;

  int number_of_wdata_items;
  int number_of_rdata_items;

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
    wdata_port = new("wdata_port", this);
    rdata_port = new("rdata_port", this);
  endfunction


  virtual task run_phase(uvm_phase phase);
    current_phase = phase;
    super.run_phase(current_phase);
  endtask


  function void check_phase(uvm_phase phase);

    current_phase = phase;
    super.check_phase(current_phase);

    if (number_of_failed != 0) begin
      `uvm_error(get_name(), $sformatf("Test failed! (%0d) mismatches", number_of_failed))
    end else begin
      `uvm_info(get_name(), $sformatf("Test passed (%0d)/(%0d) finished transfers", number_of_passed, number_of_compared), UVM_LOW)
    end
  endfunction

  //----------------------------------------------------------------------------
  // Writes
  //----------------------------------------------------------------------------

  virtual function void write_wdata_port(vip_axi4_item #(VIP_REG_CFG_C) trans);

    int _wdata;
    iir_biquad_type_t t;
    number_of_wdata_items++;

    wdata_items.push_back(trans);
    all_wdata_items.push_back(trans);

    _wdata = trans.wdata[0];

    if (trans.awaddr == IIR_F0_ADDR) begin
      iir_f0 = real'($signed(_wdata))/2**Q_BITS_C;
    end

    else if (trans.awaddr == IIR_FS_ADDR) begin
      iir_fs = real'($signed(_wdata))/2**Q_BITS_C;
    end

    else if (trans.awaddr == IIR_Q_ADDR) begin
      iir_q = real'($signed(_wdata))/2**Q_BITS_C;
    end

    else if (trans.awaddr == IIR_TYPE_ADDR) begin
      iir_type = iir_biquad_type_t'(_wdata);
    end

  endfunction

  //----------------------------------------------------------------------------
  // Reads
  //----------------------------------------------------------------------------

  virtual function void write_rdata_port(vip_axi4_item #(VIP_REG_CFG_C) trans);

    int _rdata;
    number_of_rdata_items++;
    rdata_items.push_back(trans);
    all_rdata_items.push_back(trans);

    _rdata = trans.rdata[0];

    if (trans.araddr == IIR_W0_ADDR) begin
      dut_bq_coef.w0 = real'($signed(_rdata))/2**Q_BITS_C;
    end

    else if (trans.araddr == IIR_ALFA_ADDR) begin
      dut_bq_coef.alfa = real'($signed(_rdata))/2**Q_BITS_C;
    end

    else if (trans.araddr == IIR_B0_ADDR) begin
      dut_bq_coef.b0 = real'($signed(_rdata))/2**Q_BITS_C;
    end

    else if (trans.araddr == IIR_B1_ADDR) begin
      dut_bq_coef.b1 = real'($signed(_rdata))/2**Q_BITS_C;
    end

    else if (trans.araddr == IIR_B2_ADDR) begin
      dut_bq_coef.b2 = real'($signed(_rdata))/2**Q_BITS_C;
    end

    else if (trans.araddr == IIR_A0_ADDR) begin
      dut_bq_coef.a0 = real'($signed(_rdata))/2**Q_BITS_C;
    end

    else if (trans.araddr == IIR_A1_ADDR) begin
      dut_bq_coef.a1 = real'($signed(_rdata))/2**Q_BITS_C;
    end

    else if (trans.araddr == IIR_A2_ADDR) begin
      dut_bq_coef.a2 = real'($signed(_rdata))/2**Q_BITS_C;
      `uvm_info(get_type_name(), $sformatf("--------------------------------------------------------------------------------"), UVM_LOW)
      `uvm_info(get_type_name(), $sformatf("DUT Bi-Quad Coefficients:"), UVM_LOW)
      print_biquad_coefficients(dut_bq_coef);

      `uvm_info(get_type_name(), $sformatf("--------------------------------------------------------------------------------"), UVM_LOW)
      `uvm_info(get_type_name(), $sformatf("SB  Bi-Quad Coefficients:"), UVM_LOW)
      bq_coef = biquad_coefficients(iir_f0, iir_fs, iir_q, iir_type);
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
