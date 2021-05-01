////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/PYRG
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
  rand iir_10_reg iir_10;
  rand iir_11_reg iir_11;
  rand iir_12_reg iir_12;


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

    iir_10 = iir_10_reg::type_id::create("iir_10");
    iir_10.build();
    iir_10.configure(this);

    iir_11 = iir_11_reg::type_id::create("iir_11");
    iir_11.build();
    iir_11.configure(this);

    iir_12 = iir_12_reg::type_id::create("iir_12");
    iir_12.build();
    iir_12.configure(this);



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
    default_map.add_reg(iir_10, 80, "RO");
    default_map.add_reg(iir_11, 88, "RO");
    default_map.add_reg(iir_12, 96, "RO");


    lock_model();

  endfunction

endclass
