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

import iir_biquad_apb_slave_addr_pkg::*;

class iir_base_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends vip_apb3_base_seq #(vip_cfg);

  `uvm_object_param_utils(iir_base_seq #(vip_cfg))

  // IIR parameters
  int iir_f0;
  int iir_fs;
  int iir_q;
  int iir_type;
  int iir_bypass;

  // Oscillator parameters
  int osc_f;
  int osc_duty_cycle;
  int osc_waveform_type;

  // APB3 variables
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] paddr;
  logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] pwdata;
  logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] prdata;
  int                                    psel;


  // Oscillator addresses
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_OSC_WAVEFORM_SELECT_ADDR_C = 0;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_OSC_FREQUENCY_ADDR_C       = 4;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_OSC_DUTY_CYCLE_ADDR_C      = 8;



  function new(string name = "iir_base_seq");
    super.new(name);
  endfunction

endclass



class iir_configuration_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends iir_base_seq #(vip_cfg);

  `uvm_object_param_utils(iir_configuration_seq #(vip_cfg))

  function new(string name = "iir_configuration_seq");
    super.new(name);
  endfunction


  virtual task body();

    // -------------------------------------------------------------------------
    // Oscillator registers
    // -------------------------------------------------------------------------

    `uvm_info(get_name(), $sformatf("Writing OSC registers"), UVM_LOW)
    psel = 0;

    // Write waveform
    paddr  = OSC_BASE_ADDR_C + CR_OSC_WAVEFORM_SELECT_ADDR_C;
    pwdata = osc_waveform_type;
    write_word(paddr, pwdata, psel);

    // Write frequency
    paddr  = OSC_BASE_ADDR_C + CR_OSC_FREQUENCY_ADDR_C;
    pwdata = osc_f;
    write_word(paddr, pwdata, psel);

    // Write duty cycle
    paddr  = OSC_BASE_ADDR_C + CR_OSC_DUTY_CYCLE_ADDR_C;
    pwdata = osc_duty_cycle;
    write_word(paddr, pwdata, psel);


    // -------------------------------------------------------------------------
    // IIR registers
    // -------------------------------------------------------------------------

    `uvm_info(get_name(), $sformatf("Writing IIR registers"), UVM_LOW)
    psel = 1;

    // Cut-off
    paddr  = IIR_BASE_ADDR_C + CR_IIR_F0_ADDR_C;
    pwdata = (iir_f0 << Q_BITS_C);
    write_word(paddr, pwdata, psel);

    // Sampling frequency
    paddr  = IIR_BASE_ADDR_C + CR_IIR_FS_ADDR_C;
    pwdata = (iir_fs << Q_BITS_C);
    write_word(paddr, pwdata, psel);

    // Q-value
    paddr  = IIR_BASE_ADDR_C + CR_IIR_Q_ADDR_C;
    pwdata = (iir_q << Q_BITS_C);
    write_word(paddr, pwdata, psel);

    // Filter type
    paddr  = IIR_BASE_ADDR_C + CR_IIR_TYPE_ADDR_C;
    pwdata = iir_type;
    write_word(paddr, pwdata, psel);

    // Bypass enable
    paddr  = IIR_BASE_ADDR_C + CR_IIR_BYPASS_ADDR_C;
    pwdata = iir_bypass;
    write_word(paddr, pwdata, psel);

  endtask

endclass


class iir_read_coefficients_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends iir_base_seq #(vip_cfg);

  `uvm_object_param_utils(iir_read_coefficients_seq #(vip_cfg))

  function new(string name = "iir_read_coefficients_seq");
    super.new(name);
  endfunction


  virtual task body();

    // -------------------------------------------------------------------------
    // IIR coefficients
    // -------------------------------------------------------------------------

    `uvm_info(get_name(), $sformatf("Reading IIR coefficients"), UVM_LOW)

    // w0
    `uvm_info(get_name(), $sformatf("Reading SR_W0_ADDR_C"), UVM_LOW)
    paddr  = IIR_BASE_ADDR_C + SR_W0_ADDR_C;
    read_word(paddr, prdata, IIR_PSEL_BIT_C);

    // alfa
    `uvm_info(get_name(), $sformatf("Reading SR_ALFA_ADDR_C"), UVM_LOW)
    paddr  = IIR_BASE_ADDR_C + SR_ALFA_ADDR_C;
    read_word(paddr, prdata, IIR_PSEL_BIT_C);

    // b0
    `uvm_info(get_name(), $sformatf("Reading SR_ZERO_B0_ADDR_C"), UVM_LOW)
    paddr  = IIR_BASE_ADDR_C + SR_ZERO_B0_ADDR_C;
    read_word(paddr, prdata, IIR_PSEL_BIT_C);

    // b1
    `uvm_info(get_name(), $sformatf("Reading SR_ZERO_B1_ADDR_C"), UVM_LOW)
    paddr  = IIR_BASE_ADDR_C + SR_ZERO_B1_ADDR_C;
    read_word(paddr, prdata, IIR_PSEL_BIT_C);

    // b2
    `uvm_info(get_name(), $sformatf("Reading SR_ZERO_B2_ADDR_C"), UVM_LOW)
    paddr  = IIR_BASE_ADDR_C + SR_ZERO_B2_ADDR_C;
    read_word(paddr, prdata, IIR_PSEL_BIT_C);

    // a0
    `uvm_info(get_name(), $sformatf("Reading SR_ZERO_A0_ADDR_C"), UVM_LOW)
    paddr  = IIR_BASE_ADDR_C + SR_POLE_A0_ADDR_C;
    read_word(paddr, prdata, IIR_PSEL_BIT_C);

    // a1
    `uvm_info(get_name(), $sformatf("Reading SR_ZERO_A1_ADDR_C"), UVM_LOW)
    paddr  = IIR_BASE_ADDR_C + SR_POLE_A1_ADDR_C;
    read_word(paddr, prdata, IIR_PSEL_BIT_C);

    // a2
    `uvm_info(get_name(), $sformatf("Reading SR_ZERO_A2_ADDR_C"), UVM_LOW)
    paddr  = IIR_BASE_ADDR_C + SR_POLE_A2_ADDR_C;
    read_word(paddr, prdata, IIR_PSEL_BIT_C);

  endtask

endclass




class iir_cr_iir_f0_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends iir_base_seq #(vip_cfg);

  `uvm_object_param_utils(iir_cr_iir_f0_seq #(vip_cfg))

  function new(string name = "iir_cr_iir_f0_seq");
    super.new(name);
  endfunction


  virtual task body();

    `uvm_info(get_name(), $sformatf("Writing IIR cut-off requency"), UVM_LOW)
    psel = 1;

    // Cut-off
    paddr  = IIR_BASE_ADDR_C + CR_IIR_F0_ADDR_C;
    pwdata = (iir_f0 << Q_BITS_C);
    write_word(paddr, pwdata, psel);

  endtask

endclass