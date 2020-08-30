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

  // Settings
  int max_tid = -1;

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

      if (max_tid != -1) begin
        if (axi4s_item.tid > max_tid) begin
          axi4s_item.tid = max_tid;
        end
      end

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

  int counter;

  function new(string name = "axi4s_counting_seq");
    super.new(name);
  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;
    counter = 0;

    for (int i = 0; i < nr_of_bursts; i++) begin

      // Increasing the address by number of bytes that were written previously
      axi4s_item = new();

      void'(axi4s_item.randomize());

      foreach (axi4s_item.tdata[i]) begin
        axi4s_item.tdata[i] = counter++;
      end

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

  endtask

endclass


// -----------------------------------------------------------------------------
// Single transaction
// -----------------------------------------------------------------------------
class axi4s_single_transaction_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0})
  extends vip_axi4s_base_seq #(vip_cfg);

  `uvm_object_param_utils(axi4s_single_transaction_seq #(vip_cfg))

  int counter;

  function new(string name = "axi4s_single_transaction_seq");
    super.new(name);
  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;
    counter = 0;

    `uvm_info(get_name(), $sformatf("Sending (%0d) beats", nr_of_bursts), UVM_LOW)

    for (int i = 0; i < nr_of_bursts; i++) begin

      // Increasing the address by number of bytes that were written previously
      axi4s_item = new();
      axi4s_item.burst_size = 1;

      void'(axi4s_item.randomize());

      if (max_tid != -1) begin
        if (axi4s_item.tid > max_tid) begin
          axi4s_item.tid = max_tid;
        end
      end

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_name(), $sformatf("Sequence complete", nr_of_bursts), UVM_LOW)

  endtask

endclass


// -----------------------------------------------------------------------------
// Slave tready transactions
// -----------------------------------------------------------------------------
class axi4s_slave_sequential_tready_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0})
  extends vip_axi4s_base_seq #(vip_cfg);

  `uvm_object_param_utils(axi4s_slave_sequential_tready_seq #(vip_cfg))

  int nr_of_tready;

  function new(string name = "axi4s_slave_sequential_tready_seq");
    super.new(name);
  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    axi4s_item = new();
    axi4s_item.burst_size = nr_of_tready;
    req = axi4s_item;
    start_item(req);
    finish_item(req);

  endtask

endclass
