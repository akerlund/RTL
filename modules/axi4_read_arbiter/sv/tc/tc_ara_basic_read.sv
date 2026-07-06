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

class tc_ara_basic_read extends ara_base_test;

  `uvm_component_utils(tc_ara_basic_read)

  function new(string name = "tc_ara_basic_read", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    vip_axi4_read_seq0.set_id_type(VIP_AXI4_ID_COUNTER_E);
    vip_axi4_read_seq0.set_axaddr_range(2**VIP_AXI4_CFG_C.ADDR_WIDTH_P-1, 0);
    vip_axi4_read_seq0.set_log_denominator(128);
    vip_axi4_read_seq0.set_arid(0);
    vip_axi4_read_seq0.set_requests(4096);
    vip_axi4_read_seq0.set_axlen(15);

    vip_axi4_read_seq0.start(v_sqr.rd_sequencer0);

    phase.drop_objection(this);

  endtask

endclass
