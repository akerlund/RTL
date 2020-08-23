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

class div_positive_divisions_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(div_positive_divisions_seq #(vip_cfg))

  int nr_of_random_divisions = 1;

  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_dividend;
  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_divisor;


  function new(string name = "div_positive_divisions_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    axi4s_item = new();
    axi4s_item.burst_size = 2;
    void'(axi4s_item.randomize());

    for (int i = 0; i < nr_of_random_divisions; i++) begin

      ing_dividend = $urandom_range(0, 2**(N_BITS_C-1)-1);
      ing_divisor  = $urandom_range(0, 2**(N_BITS_C-1)-1);

      axi4s_item.tid      = i;
      axi4s_item.tdata[0] = ing_dividend;
      axi4s_item.tdata[1] = ing_divisor;

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_random_divisions), UVM_LOW)

  endtask

endclass



class div_negative_divisions_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(div_negative_divisions_seq #(vip_cfg))

  int nr_of_random_divisions = 1;

  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_dividend;
  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_divisor;


  function new(string name = "div_negative_divisions_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    axi4s_item = new();
    axi4s_item.burst_size = 2;
    void'(axi4s_item.randomize());

    for (int i = 0; i < nr_of_random_divisions; i++) begin

      ing_dividend = $urandom_range(2**(N_BITS_C-1), 0);
      ing_divisor  = $urandom_range(2**(N_BITS_C-1), 0);

      axi4s_item.tid      = i;
      axi4s_item.tdata[0] = ing_dividend;
      axi4s_item.tdata[1] = ing_divisor;

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_random_divisions), UVM_LOW)

  endtask

endclass


class div_random_divisions_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(div_random_divisions_seq #(vip_cfg))

  int nr_of_random_divisions = 1;

  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_dividend;
  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_divisor;


  function new(string name = "div_random_divisions_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    axi4s_item = new();
    axi4s_item.burst_size = 2;
    void'(axi4s_item.randomize());

    for (int i = 0; i < nr_of_random_divisions; i++) begin

      ing_dividend = $urandom;
      ing_divisor  = $urandom_range(2**(N_BITS_C-3), -2**(N_BITS_C-3));

      axi4s_item.tid      = i;
      axi4s_item.tdata[0] = ing_dividend;
      axi4s_item.tdata[1] = ing_divisor;

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_random_divisions), UVM_LOW)

  endtask

endclass


class div_overflow_divisions_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(div_overflow_divisions_seq #(vip_cfg))

  int nr_of_random_divisions = 1;

  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_dividend;
  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_divisor;


  function new(string name = "div_overflow_divisions_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    axi4s_item = new();
    axi4s_item.burst_size = 2;
    void'(axi4s_item.randomize());

    for (int i = 0; i < nr_of_random_divisions; i++) begin

      ing_dividend = $urandom;

      axi4s_item.tid      = i;
      axi4s_item.tdata[0] = ing_dividend;
      axi4s_item.tdata[1] = 1; // Small divisior guarantees overflow

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_random_divisions), UVM_LOW)

  endtask

endclass