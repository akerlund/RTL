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

class tc_osc_frequency_test extends osc_base_test;

  `uvm_component_utils(tc_osc_frequency_test)

  function new(string name = "tc_osc_frequency_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 500, 250), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 500<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 250);
    clk_delay(500000);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 4000, 200), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 4000<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 200);
    clk_delay(500000);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 3000, 100), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 3000<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 100);
    clk_delay(500000);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 2000, 750), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 2000<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 750);
    clk_delay(500000);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 1000, 800), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 1000<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 800);
    clk_delay(500000);

    phase.drop_objection(this);

  endtask

endclass
