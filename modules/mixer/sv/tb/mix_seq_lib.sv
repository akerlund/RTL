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

class mix_positive_signals_seq #(
  vip_axi4s_cfg_t VIP_CFG_P = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(VIP_CFG_P));

  `uvm_object_param_utils(mix_positive_signals_seq #(VIP_CFG_P))

  int nr_of_signals = 1;

  logic [(8 * VIP_CFG_P.VIP_AXI4S_TDATA_BYTES_P)-1 : 0] ing_multiplicand;
  logic [(8 * VIP_CFG_P.VIP_AXI4S_TDATA_BYTES_P)-1 : 0] ing_multiplier;


  function new(string name = "mix_positive_signals_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(VIP_CFG_P) axi4s_item;
    vip_axi4s_item_config       axi4s_item_cfg;

    axi4s_item_cfg = new();
    axi4s_item_cfg.min_burst_length = 2;
    axi4s_item_cfg.max_burst_length = 2;
    axi4s_item = new();
    axi4s_item.set_config(axi4s_item_cfg);
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
  vip_axi4s_cfg_t VIP_CFG_P = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(VIP_CFG_P));

  `uvm_object_param_utils(mix_random_signals_seq #(VIP_CFG_P))

  int nr_of_signals = 1;

  logic signed [(8 * VIP_CFG_P.VIP_AXI4S_TDATA_BYTES_P)-1 : 0] ing_multiplicand;
  logic signed [(8 * VIP_CFG_P.VIP_AXI4S_TDATA_BYTES_P)-1 : 0] ing_multiplier;


  function new(string name = "mix_random_signals_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(VIP_CFG_P) axi4s_item;
    vip_axi4s_item_config       axi4s_item_cfg;

    axi4s_item_cfg = new();
    axi4s_item_cfg.min_burst_length = 2;
    axi4s_item_cfg.max_burst_length = 2;


    for (int i = 0; i < nr_of_signals; i++) begin

      axi4s_item = new();
      axi4s_item.set_config(axi4s_item_cfg);
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
