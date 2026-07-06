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

class mul_positive_multiplications_seq #(
  vip_axi4s_cfg_t CFG_P = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(CFG_P));

  `uvm_object_param_utils(mul_positive_multiplications_seq #(CFG_P))

  int nr_of_random_multiplications = 1;

  logic [CFG_P.AXI_DATA_WIDTH_P-1 : 0] ing_multiplicand;
  logic [CFG_P.AXI_DATA_WIDTH_P-1 : 0] ing_multiplier;


  function new(string name = "mul_positive_multiplications_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(CFG_P) axi4s_item;

    axi4s_item = new();
    axi4s_item.burst_size = 2;
    void'(axi4s_item.randomize());

    for (int i = 0; i < nr_of_random_multiplications; i++) begin

      ing_multiplicand = $urandom_range(0, 2**((N_BITS_C-Q_BITS_C)/2)-1);
      ing_multiplier   = $urandom_range(0, 2**((N_BITS_C-Q_BITS_C)/2)-1);

      axi4s_item.tid      = i;
      axi4s_item.tdata[0] = ing_multiplicand;
      axi4s_item.tdata[1] = ing_multiplier;

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_random_multiplications), UVM_LOW)

  endtask

endclass


class mul_random_multiplications_seq #(
  vip_axi4s_cfg_t CFG_P = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(CFG_P));

  `uvm_object_param_utils(mul_random_multiplications_seq #(CFG_P))

  int nr_of_random_multiplications;
  int nr_of_random_multiplications_over_100;
  int pp_multiplications;
  int pn_multiplications;
  int np_multiplications;
  int nn_multiplications;

  function new(string name = "mul_random_multiplications_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(CFG_P) axi4s_item;

    nr_of_random_multiplications_over_100 = nr_of_random_multiplications / 100;
    pp_multiplications = 0;
    pn_multiplications = 0;
    np_multiplications = 0;
    nn_multiplications = 0;
    for (int i = 0; i < nr_of_random_multiplications; i++) begin

      if (i % nr_of_random_multiplications_over_100 == 0) begin
        `uvm_info(get_type_name(), $sformatf("Random burst number (%0d)", i), UVM_LOW)
      end

      axi4s_item = new();
      axi4s_item.burst_size = 2;
      axi4s_item.randomize();
      axi4s_item.tdata[0] = $signed(axi4s_item.tdata[0]) >>> ((N_BITS_C-Q_BITS_C)+2);
      axi4s_item.tdata[1] = $signed(axi4s_item.tdata[1]) >>> ((N_BITS_C-Q_BITS_C)+2);
      axi4s_item.tid      = i;

      if ($signed(axi4s_item.tdata[0]) >= 0 && $signed(axi4s_item.tdata[1]) >= 0) begin
        pp_multiplications++;
      end
      else if ($signed(axi4s_item.tdata[0]) >= 0 && $signed(axi4s_item.tdata[1]) < 0) begin
        pn_multiplications++;
      end
      if ($signed(axi4s_item.tdata[0]) < 0 && $signed(axi4s_item.tdata[1]) >= 0) begin
        np_multiplications++;
      end
      else begin
        nn_multiplications++;
      end


      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("Multiplication signs"), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("++ = (%0d)", pp_multiplications), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("+- = (%0d)", pn_multiplications), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("-+ = (%0d)", np_multiplications), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("-- = (%0d)", nn_multiplications), UVM_LOW)

  endtask

endclass


class mul_corner_multiplications_seq #(
  vip_axi4s_cfg_t CFG_P = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(CFG_P));

  `uvm_object_param_utils(mul_corner_multiplications_seq #(CFG_P))

  function new(string name = "mul_corner_multiplications_seq");
    super.new(name);
  endfunction


  virtual task body();

    req = new();
    req.burst_size = 2;
    req.randomize();

    `uvm_info(get_name(), $sformatf("Multiplicand is zero"), UVM_LOW)
    req.tdata[0] = '1;
    req.tdata[1] = '0;
    req.tid      = 0;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Multiplier is zero"), UVM_LOW)
    req.tdata[0] = '1;
    req.tdata[1] = 0;
    req.tid      = 1;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Largest possible values"), UVM_LOW)
    req.tdata[0] = 2**(N_BITS_C-Q_BITS_C)-1;
    req.tdata[1] = 2**(N_BITS_C-Q_BITS_C)-1;
    req.tid      = 2;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Lowest possible values"), UVM_LOW)
    req.tdata[0] = -2**(N_BITS_C-Q_BITS_C);
    req.tdata[1] = -2**(N_BITS_C-Q_BITS_C);
    req.tid      = 3;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Largest fractional parts"), UVM_LOW)
    req.tdata[0] = {'0, {Q_BITS_C{1'b1}}};
    req.tdata[1] = {'0, {Q_BITS_C{1'b1}}};
    req.tid      = 4;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Largest fractional part * largest possible value"), UVM_LOW)
    req.tdata[0] = {'0, {Q_BITS_C{1'b1}}};
    req.tdata[1] = 2**(N_BITS_C-Q_BITS_C)-1;
    req.tid      = 5;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Largest fractional part * lowest possible value"), UVM_LOW)
    req.tdata[0] = {'0, {Q_BITS_C{1'b1}}};
    req.tdata[1] = -2**(N_BITS_C-Q_BITS_C);
    req.tid      = 6;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Largest fractional part * lowest fractional part"), UVM_LOW)
    req.tdata[0] = {'0, {Q_BITS_C{1'b1}}};
    req.tdata[1] = -2**(N_BITS_C-Q_BITS_C);
    req.tid      = 7;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Lowest fractional parts"), UVM_LOW)
    req.tdata[0] = {'0, 1'b1};
    req.tdata[1] = {'0, 1'b1};
    req.tid      = 8;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Lowest fractional part * largest possible value"), UVM_LOW)
    req.tdata[0] = {'0, 1'b1};
    req.tdata[1] = 2**(N_BITS_C-Q_BITS_C)-1;
    req.tid      = 9;
    start_item(req);
    finish_item(req);
    #100;

    `uvm_info(get_name(), $sformatf("Lowest fractional part * lowest possible value"), UVM_LOW)
    req.tdata[0] = {'0, 1'b1};
    req.tdata[1] = -2**(N_BITS_C-Q_BITS_C);
    req.tid      = 10;
    start_item(req);
    finish_item(req);
    #100;

  endtask

endclass
