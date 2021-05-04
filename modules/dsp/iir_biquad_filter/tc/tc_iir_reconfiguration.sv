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

class tc_iir_reconfiguration extends iir_base_test;

  `uvm_component_utils(tc_iir_reconfiguration)

  function new(string name = "tc_iir_reconfiguration", uvm_component parent = null);

    super.new(name, parent);

    iir_f0     = 3000;
    iir_fs     = 64000;
    iir_q      = 1;
    iir_type   = IIR_LOW_PASS_E;
    iir_bypass = '0;
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    `uvm_info(get_name(), $sformatf("Writing an IIR configuration"), UVM_LOW)
    reg_model.iir.iir_f0.write(uvm_status,     iir_f0);
    reg_model.iir.iir_fs.write(uvm_status,     iir_fs);
    reg_model.iir.iir_q.write(uvm_status,      iir_q);
    reg_model.iir.iir_type.write(uvm_status,   iir_type);
    reg_model.iir.iir_bypass.write(uvm_status, iir_bypass);

    `uvm_info(get_name(), $sformatf("Waiting 100us"), UVM_LOW)
    #100us;

    `uvm_info(get_name(), $sformatf("Reading an IIR configuration"), UVM_LOW)
    reg_model.iir.iir_w0.read(uvm_status,   value);
    reg_model.iir.iir_alfa.read(uvm_status, value);
    reg_model.iir.iir_b0.read(uvm_status,   value);
    reg_model.iir.iir_b1.read(uvm_status,   value);
    reg_model.iir.iir_b2.read(uvm_status,   value);
    reg_model.iir.iir_a0.read(uvm_status,   value);
    reg_model.iir.iir_a1.read(uvm_status,   value);
    reg_model.iir.iir_a2.read(uvm_status,   value);

    `uvm_info(get_name(), $sformatf("Waiting 3ms"), UVM_LOW)
    #3ms;

    for (int i = 0; i < 14; i++) begin

      `uvm_info(get_name(), $sformatf("Iteration (%0d/%0d)", i+1, 14), UVM_LOW)

      `uvm_info(get_name(), $sformatf("Writing an IIR configuration"), UVM_LOW)
      reg_model.iir.iir_f0.write(uvm_status, iir_f0);
      iir_f0 = iir_f0 - 200;
      `uvm_info(get_name(), $sformatf("Waiting 1us"), UVM_LOW)
      #1us;
      reg_model.iir.iir_w0.read(uvm_status,   value);
      reg_model.iir.iir_alfa.read(uvm_status, value);
      reg_model.iir.iir_b0.read(uvm_status,   value);
      reg_model.iir.iir_b1.read(uvm_status,   value);
      reg_model.iir.iir_b2.read(uvm_status,   value);
      reg_model.iir.iir_a0.read(uvm_status,   value);
      reg_model.iir.iir_a1.read(uvm_status,   value);
      reg_model.iir.iir_a2.read(uvm_status,   value);
      `uvm_info(get_name(), $sformatf("Waiting 3ms"), UVM_LOW)
      #3ms;

    end

    `uvm_info(get_name(), $sformatf("Waiting 10ms"), UVM_LOW)
    #10ms;

    phase.drop_objection(this);

  endtask

endclass
