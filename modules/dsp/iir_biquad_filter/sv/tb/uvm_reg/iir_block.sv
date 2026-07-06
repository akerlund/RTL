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
class iir_block extends uvm_reg_block;

  `uvm_object_utils(iir_block)

  rand iir_f0_reg iir_f0;
  rand iir_fs_reg iir_fs;
  rand iir_q_reg iir_q;
  rand iir_type_reg iir_type;
  rand iir_bypass_reg iir_bypass;
  rand iir_w0_reg iir_w0;
  rand iir_alfa_reg iir_alfa;
  rand iir_b0_reg iir_b0;
  rand iir_b1_reg iir_b1;
  rand iir_b2_reg iir_b2;
  rand iir_a0_reg iir_a0;
  rand iir_a1_reg iir_a1;
  rand iir_a2_reg iir_a2;


  function new (string name = "iir_block");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction


  function void build();

    iir_f0 = iir_f0_reg::type_id::create("iir_f0");
    iir_f0.build();
    iir_f0.configure(this);

    iir_fs = iir_fs_reg::type_id::create("iir_fs");
    iir_fs.build();
    iir_fs.configure(this);

    iir_q = iir_q_reg::type_id::create("iir_q");
    iir_q.build();
    iir_q.configure(this);

    iir_type = iir_type_reg::type_id::create("iir_type");
    iir_type.build();
    iir_type.configure(this);

    iir_bypass = iir_bypass_reg::type_id::create("iir_bypass");
    iir_bypass.build();
    iir_bypass.configure(this);

    iir_w0 = iir_w0_reg::type_id::create("iir_w0");
    iir_w0.build();
    iir_w0.configure(this);

    iir_alfa = iir_alfa_reg::type_id::create("iir_alfa");
    iir_alfa.build();
    iir_alfa.configure(this);

    iir_b0 = iir_b0_reg::type_id::create("iir_b0");
    iir_b0.build();
    iir_b0.configure(this);

    iir_b1 = iir_b1_reg::type_id::create("iir_b1");
    iir_b1.build();
    iir_b1.configure(this);

    iir_b2 = iir_b2_reg::type_id::create("iir_b2");
    iir_b2.build();
    iir_b2.configure(this);

    iir_a0 = iir_a0_reg::type_id::create("iir_a0");
    iir_a0.build();
    iir_a0.configure(this);

    iir_a1 = iir_a1_reg::type_id::create("iir_a1");
    iir_a1.build();
    iir_a1.configure(this);

    iir_a2 = iir_a2_reg::type_id::create("iir_a2");
    iir_a2.build();
    iir_a2.configure(this);



    default_map = create_map("iir_map", 0, 8, UVM_LITTLE_ENDIAN);

    default_map.add_reg(iir_f0, 0, "RW");
    default_map.add_reg(iir_fs, 8, "RW");
    default_map.add_reg(iir_q, 16, "RW");
    default_map.add_reg(iir_type, 24, "RW");
    default_map.add_reg(iir_bypass, 32, "RW");
    default_map.add_reg(iir_w0, 40, "RO");
    default_map.add_reg(iir_alfa, 48, "RO");
    default_map.add_reg(iir_b0, 56, "RO");
    default_map.add_reg(iir_b1, 64, "RO");
    default_map.add_reg(iir_b2, 72, "RO");
    default_map.add_reg(iir_a0, 80, "RO");
    default_map.add_reg(iir_a1, 88, "RO");
    default_map.add_reg(iir_a2, 96, "RO");


    lock_model();

  endfunction

endclass
