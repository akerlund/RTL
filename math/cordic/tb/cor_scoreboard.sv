////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////


class cor_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(cor_scoreboard)

  // For raising objections
  uvm_phase current_phase;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

  endfunction

  function void connect_phase(uvm_phase phase);

    current_phase = phase;
    super.connect_phase(current_phase);

  endfunction

  virtual task run_phase(uvm_phase phase);

    current_phase = phase;
    super.run_phase(current_phase);

  endtask

  function void check_phase(uvm_phase phase);

    current_phase = phase;
    super.check_phase(current_phase);

  endfunction

endclass
