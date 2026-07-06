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

class tc_fi_fill_up_read_out extends fi_base_test;

  `uvm_component_utils(tc_fi_fill_up_read_out)

  axi4s_single_transaction_seq      #(vip_axi4s_cfg) axi4s_single_transaction_seq0;
  axi4s_slave_sequential_tready_seq #(vip_axi4s_cfg) axi4s_slave_sequential_tready_seq0;

  int nr_of_bursts = 2048;


  function new(string name = "tc_fi_fill_up_read_out", uvm_component parent = null);

    super.new(name, parent);
    tready_back_pressure_enabled = 1;

  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    vip_axi4s_config_slv.drive_sequence_items = 1;


  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    `uvm_info(get_name(), $sformatf("Writing the FIFO full"), UVM_LOW)
    axi4s_single_transaction_seq0              = axi4s_single_transaction_seq #(vip_axi4s_cfg)::type_id::create("axi4s_single_transaction_seq0");
    axi4s_single_transaction_seq0.nr_of_bursts = 2**FIFO_ADDR_WIDTH_C;
    axi4s_single_transaction_seq0.start(v_sqr.mst0_sequencer);

    `uvm_info(get_name(), $sformatf("Waiting for a little gap in the waveform"), UVM_LOW)
    #(10*clk_rst_config0.clock_period);

    `uvm_info(get_name(), $sformatf("Reading the FIFO"), UVM_LOW)
    axi4s_slave_sequential_tready_seq0              = axi4s_slave_sequential_tready_seq #(vip_axi4s_cfg)::type_id::create("axi4s_slave_sequential_tready_seq0");
    axi4s_slave_sequential_tready_seq0.nr_of_tready = 2**FIFO_ADDR_WIDTH_C;
    axi4s_slave_sequential_tready_seq0.start(v_sqr.slv0_sequencer);


    phase.drop_objection(this);

  endtask

endclass
