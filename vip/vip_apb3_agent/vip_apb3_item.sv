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

class vip_apb3_item #(
  vip_apb3_cfg_t cfg = '{default: '0}
  ) extends uvm_sequence_item;

   rand logic   [cfg.APB_ADDR_WIDTH_P-1 : 0] paddr;
        int                                  psel;
        logic                                pwrite;
   rand logic   [cfg.APB_DATA_WIDTH_P-1 : 0] pwdata;
   rand logic   [cfg.APB_DATA_WIDTH_P-1 : 0] prdata;
        logic                                pslverr;


  `uvm_object_param_utils_begin(vip_apb3_item #(cfg))
    `uvm_field_int(paddr,   UVM_DEFAULT)
    `uvm_field_int(pwrite,  UVM_DEFAULT)
    `uvm_field_int(pwdata,  UVM_DEFAULT)
    `uvm_field_int(prdata,  UVM_DEFAULT)
    `uvm_field_int(pslverr, UVM_DEFAULT)
  `uvm_object_utils_end


  function new(string name = "vip_apb3_item");
    super.new(name);
  endfunction


endclass
