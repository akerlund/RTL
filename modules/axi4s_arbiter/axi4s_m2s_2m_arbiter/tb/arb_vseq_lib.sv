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

class arb_vseq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(arb_vseq #(vip_cfg))
  `uvm_declare_p_sequencer(arb_virtual_sequencer)

  axi4s_random_seq #(vip_cfg) random_seq0;
  axi4s_random_seq #(vip_cfg) random_seq1;

  int nr_of_bursts            = -1;
  int max_idle_between_bursts = -1;

  function new(string name = "arb_vseq");

    super.new(name);

  endfunction


  virtual task body();

    random_seq0 = axi4s_random_seq #(vip_cfg)::type_id::create("random_seq0");
    random_seq1 = axi4s_random_seq #(vip_cfg)::type_id::create("random_seq1");

    random_seq0.nr_of_bursts = nr_of_bursts;
    random_seq1.nr_of_bursts = nr_of_bursts;

    random_seq0.max_idle_between_bursts = max_idle_between_bursts;
    random_seq1.max_idle_between_bursts = max_idle_between_bursts;

    `uvm_info(get_name(), $sformatf("Starting two sequences"), UVM_LOW);

    fork
      random_seq0.start(p_sequencer.mst0_sequencer);
      random_seq1.start(p_sequencer.mst1_sequencer);
    join

  endtask

endclass
