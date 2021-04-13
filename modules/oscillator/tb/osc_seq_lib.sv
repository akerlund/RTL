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

import osc_apb_slave_addr_pkg::*;
import vip_fixed_point_pkg::*;

class osc_base_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends vip_apb3_base_seq #(vip_cfg);

  `uvm_object_param_utils(osc_base_seq #(vip_cfg))

  // Oscillator parameters
  real                osc_f;
  int                 osc_duty_cycle;
  osc_waveform_type_t osc_waveform_type;

  // APB3 variables
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] paddr;
  logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] pwdata;
  logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] prdata;
  int                                    psel;


  function new(string name = "osc_base_seq");
    super.new(name);
  endfunction

endclass



class osc_frequency_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends osc_base_seq #(vip_cfg);

  `uvm_object_param_utils(osc_frequency_seq #(vip_cfg))

  function new(string name = "osc_frequency_seq");

    super.new(name);

    osc_f             = 1000.0;
    osc_duty_cycle    = 250;
    osc_waveform_type = OSC_SQUARE_E;

  endfunction


  virtual task body();

    // Write waveform
    paddr  = CR_OSC_WAVEFORM_SELECT_ADDR_C;
    pwdata = osc_waveform_type;
    write_word(paddr, pwdata);

    // Write frequency
    paddr  = CR_OSC_FREQUENCY_ADDR_C;
    pwdata = float_to_fixed_point(osc_f, Q_BITS_C);
    write_word(paddr, pwdata);

    // Write duty cycle
    paddr  = CR_OSC_DUTY_CYCLE_ADDR_C;
    pwdata = osc_duty_cycle;
    write_word(paddr, pwdata);


  endtask

endclass
