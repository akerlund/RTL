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
// -----------------------------------------------------------------------------
// Cut-off frequency
// -----------------------------------------------------------------------------
class iir_f0_reg extends uvm_reg;

  `uvm_object_utils(iir_f0_reg)

  rand uvm_reg_field cr_iir_f0;


  function new (string name = "iir_f0_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Cut-off frequency
    // -----------------------------------------------------------------------------
    cr_iir_f0 = uvm_reg_field::type_id::create("cr_iir_f0");
    cr_iir_f0.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_iir_f0", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Sampling frequency
// -----------------------------------------------------------------------------
class iir_fs_reg extends uvm_reg;

  `uvm_object_utils(iir_fs_reg)

  rand uvm_reg_field cr_iir_fs;


  function new (string name = "iir_fs_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Sampling frequency
    // -----------------------------------------------------------------------------
    cr_iir_fs = uvm_reg_field::type_id::create("cr_iir_fs");
    cr_iir_fs.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_iir_fs", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Alfa (q)
// -----------------------------------------------------------------------------
class iir_q_reg extends uvm_reg;

  `uvm_object_utils(iir_q_reg)

  rand uvm_reg_field cr_iir_q;


  function new (string name = "iir_q_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Alfa (q)
    // -----------------------------------------------------------------------------
    cr_iir_q = uvm_reg_field::type_id::create("cr_iir_q");
    cr_iir_q.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_iir_q", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Select filter type
// -----------------------------------------------------------------------------
class iir_type_reg extends uvm_reg;

  `uvm_object_utils(iir_type_reg)

  rand uvm_reg_field cr_iir_type;


  function new (string name = "iir_type_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // LP BP HP
    // -----------------------------------------------------------------------------
    cr_iir_type = uvm_reg_field::type_id::create("cr_iir_type");
    cr_iir_type.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_iir_type", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Bypass the filter
// -----------------------------------------------------------------------------
class iir_bypass_reg extends uvm_reg;

  `uvm_object_utils(iir_bypass_reg)

  rand uvm_reg_field cr_iir_bypass;


  function new (string name = "iir_bypass_reg");
    super.new(name, 1, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Bypass the filter
    // -----------------------------------------------------------------------------
    cr_iir_bypass = uvm_reg_field::type_id::create("cr_iir_bypass");
    cr_iir_bypass.configure(
      .parent(this),
      .size(1),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_iir_bypass", 0, 1);

  endfunction

endclass

// -----------------------------------------------------------------------------
// iir_w0
// -----------------------------------------------------------------------------
class iir_w0_reg extends uvm_reg;

  `uvm_object_utils(iir_w0_reg)

  rand uvm_reg_field sr_iir_w0;


  function new (string name = "iir_w0_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // iir_w0
    // -----------------------------------------------------------------------------
    sr_iir_w0 = uvm_reg_field::type_id::create("sr_iir_w0");
    sr_iir_w0.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_iir_w0", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// iir_alfa
// -----------------------------------------------------------------------------
class iir_alfa_reg extends uvm_reg;

  `uvm_object_utils(iir_alfa_reg)

  rand uvm_reg_field sr_iir_alfa;


  function new (string name = "iir_alfa_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // iir_alfa
    // -----------------------------------------------------------------------------
    sr_iir_alfa = uvm_reg_field::type_id::create("sr_iir_alfa");
    sr_iir_alfa.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_iir_alfa", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// iir_b0
// -----------------------------------------------------------------------------
class iir_b0_reg extends uvm_reg;

  `uvm_object_utils(iir_b0_reg)

  rand uvm_reg_field sr_iir_b0;


  function new (string name = "iir_b0_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // iir_b0
    // -----------------------------------------------------------------------------
    sr_iir_b0 = uvm_reg_field::type_id::create("sr_iir_b0");
    sr_iir_b0.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_iir_b0", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// iir_b1
// -----------------------------------------------------------------------------
class iir_b1_reg extends uvm_reg;

  `uvm_object_utils(iir_b1_reg)

  rand uvm_reg_field sr_iir_b1;


  function new (string name = "iir_b1_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // iir_b1
    // -----------------------------------------------------------------------------
    sr_iir_b1 = uvm_reg_field::type_id::create("sr_iir_b1");
    sr_iir_b1.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_iir_b1", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// iir_b2
// -----------------------------------------------------------------------------
class iir_b2_reg extends uvm_reg;

  `uvm_object_utils(iir_b2_reg)

  rand uvm_reg_field sr_iir_b2;


  function new (string name = "iir_b2_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // iir_b2
    // -----------------------------------------------------------------------------
    sr_iir_b2 = uvm_reg_field::type_id::create("sr_iir_b2");
    sr_iir_b2.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_iir_b2", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// iir_a0
// -----------------------------------------------------------------------------
class iir_a0_reg extends uvm_reg;

  `uvm_object_utils(iir_a0_reg)

  rand uvm_reg_field sr_iir_a0;


  function new (string name = "iir_a0_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // iir_a0
    // -----------------------------------------------------------------------------
    sr_iir_a0 = uvm_reg_field::type_id::create("sr_iir_a0");
    sr_iir_a0.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_iir_a0", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// iir_a1
// -----------------------------------------------------------------------------
class iir_a1_reg extends uvm_reg;

  `uvm_object_utils(iir_a1_reg)

  rand uvm_reg_field sr_iir_a1;


  function new (string name = "iir_a1_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // iir_a1
    // -----------------------------------------------------------------------------
    sr_iir_a1 = uvm_reg_field::type_id::create("sr_iir_a1");
    sr_iir_a1.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_iir_a1", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// iir_a2
// -----------------------------------------------------------------------------
class iir_a2_reg extends uvm_reg;

  `uvm_object_utils(iir_a2_reg)

  rand uvm_reg_field sr_iir_a2;


  function new (string name = "iir_a2_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // iir_a2
    // -----------------------------------------------------------------------------
    sr_iir_a2 = uvm_reg_field::type_id::create("sr_iir_a2");
    sr_iir_a2.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_iir_a2", 0, N_BITS_C);

  endfunction

endclass

