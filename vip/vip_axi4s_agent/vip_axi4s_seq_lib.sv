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

// -----------------------------------------------------------------------------
// Base Sequence
// -----------------------------------------------------------------------------
class vip_axi4s_base_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(vip_axi4s_base_seq #(vip_cfg))

  // Sequence parameters
  rand int unsigned nr_of_bursts = 1;
       int unsigned max_idle_between_bursts = 0;

  // Constraints
  constraint constraint_nr_of_bursts {
    nr_of_bursts >= 1;
    nr_of_bursts <= 4096;
  }


  function new(string name = "vip_axi4s_base_seq");

    super.new(name);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Write Random Sequence
// Randomizes item and send them. The write item's random function assures
// the write will not span through a 4k address boundary.
// -----------------------------------------------------------------------------
class axi4s_random_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0})
  extends vip_axi4s_base_seq #(vip_cfg);

  `uvm_object_param_utils(axi4s_random_seq #(vip_cfg))

  function new(string name = "axi4s_random_seq");
    super.new(name);
  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    for (int i = 0; i < nr_of_bursts; i++) begin

      // Increasing the address by number of bytes that were written previously
      axi4s_item = new();

      void'(axi4s_item.randomize());

      req = axi4s_item;
      start_item(req);
      finish_item(req);

      #($urandom_range(0, max_idle_between_bursts));

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_bursts), UVM_LOW)

  endtask

endclass


// -----------------------------------------------------------------------------
// Counting Sequence
// Sends write data (wdata) as 0, 1, 2, ..., 3
// -----------------------------------------------------------------------------
class axi4s_counting_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0})
  extends vip_axi4s_base_seq #(vip_cfg);

  `uvm_object_param_utils(axi4s_counting_seq #(vip_cfg))


  function new(string name = "axi4s_counting_seq");
    super.new(name);
  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

  endtask

endclass
