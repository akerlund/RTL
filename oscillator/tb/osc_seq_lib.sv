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

class osc_square_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends vip_apb3_base_seq #(vip_cfg);

  `uvm_object_param_utils(osc_square_seq #(vip_cfg))

  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] paddr;
  logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] pwdata;

  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_WAVEFORM_SELECT_ADDR_C = 0;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_FREQUENCY_ADDR_C       = 4;
  logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] CR_DUTY_CYCLE_ADDR_C      = 8;

  function new(string name = "osc_square_seq");

    super.new(name);

  endfunction


  virtual task body();

    // Write waveform
    paddr  = CR_WAVEFORM_SELECT_ADDR_C;
    pwdata = '0;
    write_word(paddr, pwdata);

    // Write frequency
    paddr  = CR_FREQUENCY_ADDR_C;
    pwdata = 50; // Clocks
    write_word(paddr, pwdata);

    // Write duty cycle
    paddr  = CR_DUTY_CYCLE_ADDR_C;
    pwdata = 25; // Clocks
    write_word(paddr, pwdata);

    #1000;

  endtask

endclass
