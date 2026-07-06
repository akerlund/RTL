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

class tc_fi_basic extends fi_base_test;

  `uvm_component_utils(tc_fi_basic)

  function new(string name = "tc_fi_basic", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    vip_axi4s_seq0.set_tdata_type(VIP_AXI4S_TDATA_COUNTER_E);
    vip_axi4s_seq0.set_cfg_burst_length(128, 1);
    vip_axi4s_seq0.set_nr_of_bursts(1024);
    vip_axi4s_seq0.set_tstrb_type(VIP_AXI4S_TSTRB_ALL_E);
    vip_axi4s_seq0.set_log_denominator(4);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);

    phase.drop_objection(this);

  endtask

endclass
