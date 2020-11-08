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

class mix_positive_signals_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(mix_positive_signals_seq #(vip_cfg))

  int nr_of_signals = 1;

  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_multiplicand;
  logic [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_multiplier;


  function new(string name = "mix_positive_signals_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    axi4s_item = new();
    axi4s_item.burst_size = 1;
    void'(axi4s_item.randomize());

    for (int i = 0; i < nr_of_signals; i++) begin

      ing_multiplicand = $urandom_range(0, 2**((AUDIO_WIDTH_C-Q_BITS_C)/2)-1);
      ing_multiplier   = $urandom_range(0, 2**((AUDIO_WIDTH_C-Q_BITS_C)/2)-1);

      axi4s_item.tid      = i;
      axi4s_item.tdata[0] = ing_multiplicand;
      axi4s_item.tdata[1] = ing_multiplier;

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_signals), UVM_LOW)

  endtask

endclass


class mix_random_signals_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(mix_random_signals_seq #(vip_cfg))

  int nr_of_signals = 1;

  logic signed [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_multiplicand;
  logic signed [vip_cfg.AXI_DATA_WIDTH_P-1 : 0] ing_multiplier;


  function new(string name = "mix_random_signals_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;


    for (int i = 0; i < nr_of_signals; i++) begin

      axi4s_item = new();
      axi4s_item.burst_size = 1;
      void'(axi4s_item.randomize());

      axi4s_item.tid      = i;
      axi4s_item.tdata[0] = axi4s_item.tdata[0] >>> ((AUDIO_WIDTH_C-Q_BITS_C)/2+2);
      axi4s_item.tdata[1] = axi4s_item.tdata[1] >>> ((AUDIO_WIDTH_C-Q_BITS_C)/2+2);

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_signals), UVM_LOW)

  endtask

endclass
