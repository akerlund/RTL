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

class tc_iir_basic_configuration extends iir_base_test;

  `uvm_component_utils(tc_iir_basic_configuration)

  function new(string name = "tc_iir_basic_configuration", uvm_component parent = null);
    super.new(name, parent);
    iir_f0     = 500;
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

    `uvm_info(get_name(), $sformatf("Waiting 10ms"), UVM_LOW)
    #10ms;

    phase.drop_objection(this);
  endtask

endclass
