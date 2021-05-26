////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/PYRG
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
class fir_block extends uvm_reg_block;

  `uvm_object_utils(fir_block)

  rand fir_delay_time_reg fir_delay_time;
  rand fir_delay_gain_reg fir_delay_gain;


  function new (string name = "fir_block");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction


  function void build();

    fir_delay_time = fir_delay_time_reg::type_id::create("fir_delay_time");
    fir_delay_time.build();
    fir_delay_time.configure(this);

    fir_delay_gain = fir_delay_gain_reg::type_id::create("fir_delay_gain");
    fir_delay_gain.build();
    fir_delay_gain.configure(this);



    default_map = create_map("fir_map", 0, 8, UVM_LITTLE_ENDIAN);

    default_map.add_reg(fir_delay_time, 0, "WO");
    default_map.add_reg(fir_delay_gain, 8, "WO");


    lock_model();

  endfunction

endclass
