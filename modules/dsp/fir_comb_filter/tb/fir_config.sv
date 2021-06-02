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

class fir_config extends uvm_object;

  logic [63 : 0] fir_delay_time = 0;
  logic [63 : 0] fir_delay_gain = 0;

  `uvm_object_utils_begin(fir_config);
    `uvm_field_int(fir_delay_time, UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(fir_delay_gain, UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end;

  function new(string name = "fir_config");
    super.new(name);
  endfunction

endclass
