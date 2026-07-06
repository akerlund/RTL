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
