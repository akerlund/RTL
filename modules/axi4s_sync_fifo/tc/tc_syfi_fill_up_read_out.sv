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

class tc_syfi_fill_up_read_out extends syfi_base_test;

  `uvm_component_utils(tc_syfi_fill_up_read_out)

  axi4s_single_transaction_seq      #(vip_axi4s_cfg) axi4s_single_transaction_seq0;
  axi4s_slave_sequential_tready_seq #(vip_axi4s_cfg) axi4s_slave_sequential_tready_seq0;

  int nr_of_bursts = 2048;


  function new(string name = "tc_syfi_fill_up_read_out", uvm_component parent = null);

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
