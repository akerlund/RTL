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

class register_model extends uvm_reg_block;

  `uvm_object_utils(register_model)

  iir_block   iir;
  uvm_reg_map reg_map;

  function new (string name = "register_model");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
    uvm_reg::include_coverage("*", UVM_CVR_ALL);
  endfunction

  virtual function void build();

    `uvm_info(get_name(), $sformatf("Creating uvm_reg"), UVM_LOW)
    iir = iir_block::type_id::create("iir");

    `uvm_info(get_name(), $sformatf("Configuring uvm_reg"), UVM_LOW)
    iir.configure(this);

    `uvm_info(get_name(), $sformatf("Building uvm_reg"), UVM_LOW)
    iir.build();

    `uvm_info(get_name(), $sformatf("Creating register map"), UVM_LOW)
    reg_map = create_map("reg_map", 'h0, 8, UVM_LITTLE_ENDIAN);

    default_map = reg_map;

    `uvm_info(get_name(), $sformatf("Adding submap iir"), UVM_LOW)
    reg_map.add_submap(iir.default_map, 0);

    lock_model();

  endfunction

endclass
