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

class awa_write_vseq #(
  vip_axi4_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(axi4_write_item #(vip_cfg));

  `uvm_object_param_utils(awa_write_vseq #(vip_cfg))
  `uvm_declare_p_sequencer(awa_virtual_sequencer)

  write_random_seq #(vip_cfg) write_random_seq0;
  write_random_seq #(vip_cfg) write_random_seq1;
  write_random_seq #(vip_cfg) write_random_seq2;

  int max_awaddr              = -1;
  int nr_of_bursts            = -1;
  int max_idle_between_bursts = -1;

  function new(string name = "awa_write_vseq");

    super.new(name);

  endfunction


  virtual task body();

    write_random_seq0 = write_random_seq #(vip_cfg)::type_id::create("write_random_seq0");
    write_random_seq1 = write_random_seq #(vip_cfg)::type_id::create("write_random_seq1");
    write_random_seq2 = write_random_seq #(vip_cfg)::type_id::create("write_random_seq2");

    write_random_seq0.max_awaddr = max_awaddr;
    write_random_seq1.max_awaddr = max_awaddr;
    write_random_seq2.max_awaddr = max_awaddr;

    write_random_seq0.nr_of_bursts = nr_of_bursts;
    write_random_seq1.nr_of_bursts = nr_of_bursts;
    write_random_seq2.nr_of_bursts = nr_of_bursts;

    write_random_seq0.max_idle_between_bursts = max_idle_between_bursts;
    write_random_seq1.max_idle_between_bursts = max_idle_between_bursts;
    write_random_seq2.max_idle_between_bursts = max_idle_between_bursts;

    `uvm_info(get_name(), $sformatf("Starting three sequences"), UVM_LOW);

    fork
      write_random_seq0.start(p_sequencer.write_sequencer0);
      write_random_seq1.start(p_sequencer.write_sequencer1);
      write_random_seq2.start(p_sequencer.write_sequencer2);
    join

  endtask

endclass
