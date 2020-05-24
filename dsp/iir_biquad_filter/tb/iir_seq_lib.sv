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

class iir_base_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends vip_apb3_base_seq #(vip_cfg);

  `uvm_object_param_utils(iir_base_seq #(vip_cfg))

  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] paddr;
  logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] pwdata;
  int                                    psel;

  // Base addresses
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] OSC_BASE_ADDR_C               = 0;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] IIR_BASE_ADDR_C               = 16;

  // Oscillator addresses
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_OSC_WAVEFORM_SELECT_ADDR_C = 0;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_OSC_FREQUENCY_ADDR_C       = 4;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_OSC_DUTY_CYCLE_ADDR_C      = 8;

  // IIR addresses
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_IIR_F0_ADDR_C              = 0;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_IIR_FS_ADDR_C              = 4;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_IIR_Q_ADDR_C               = 8;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_IIR_TYPE_ADDR_C            = 12;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_IIR_BYPASS_ADDR_C          = 16;


  function new(string name = "iir_base_seq");

    super.new(name);

  endfunction

endclass



class iir_bypass_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends iir_base_seq #(vip_cfg);

  `uvm_object_param_utils(iir_bypass_seq #(vip_cfg))

  function new(string name = "iir_bypass_seq");
    super.new(name);
  endfunction


  virtual task body();

    // Oscillator registers

    `uvm_info(get_name(), $sformatf("Writing OSC registers"), UVM_LOW)
    psel = 0;

    // Write waveform
    paddr  = OSC_BASE_ADDR_C + CR_OSC_WAVEFORM_SELECT_ADDR_C;
    pwdata = '0;
    write_word(paddr, pwdata, psel);

    // Write frequency
    paddr  = OSC_BASE_ADDR_C + CR_OSC_FREQUENCY_ADDR_C;
    pwdata = 50; // Clocks
    write_word(paddr, pwdata, psel);

    // Write duty cycle
    paddr  = OSC_BASE_ADDR_C + CR_OSC_DUTY_CYCLE_ADDR_C;
    pwdata = 25; // Clocks
    write_word(paddr, pwdata, psel);

    psel = 1;

    `uvm_info(get_name(), $sformatf("Writing IIR registers"), UVM_LOW)
    // IIR registers
    paddr  = IIR_BASE_ADDR_C + CR_IIR_F0_ADDR_C;
    pwdata = (24000 << Q_BITS_C);
    write_word(paddr, pwdata, psel);

    paddr  = IIR_BASE_ADDR_C + CR_IIR_FS_ADDR_C;
    pwdata = (48000 << Q_BITS_C);
    write_word(paddr, pwdata, psel);

    paddr  = IIR_BASE_ADDR_C + CR_IIR_Q_ADDR_C;
    pwdata = (1 << Q_BITS_C);;
    write_word(paddr, pwdata, psel);

    paddr  = IIR_BASE_ADDR_C + CR_IIR_TYPE_ADDR_C;
    pwdata = IIR_LOW_PASS_E;
    write_word(paddr, pwdata, psel);

    paddr  = IIR_BASE_ADDR_C + CR_IIR_BYPASS_ADDR_C;
    pwdata = '1;
    write_word(paddr, pwdata, psel);

    #5000us;

  endtask

endclass
