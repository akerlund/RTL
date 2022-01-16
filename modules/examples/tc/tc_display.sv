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

class tc_display extends ex_base_test;

  `uvm_component_utils(tc_display)

  function new(string name = "tc_display", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    /*
      %h, %H   Display in hexadecimal format
      %d, %D   Display in decimal format
      %b, %B   Display in binary format
      %o or %O Display octal format
      %m, %M   Display hierarchical name
      %s, %S   Display as a string
      %t, %T   Display in time format
      %f, %F   Display 'real' in a decimal format
      %e, %E   Display 'real' in an exponential format
    */

    $display("I am display");

    phase.drop_objection(this);

  endtask

endclass
