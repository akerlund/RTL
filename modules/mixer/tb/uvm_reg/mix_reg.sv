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
// None
// -----------------------------------------------------------------------------
class mix_clear_dac_min_max_reg extends uvm_reg;

  `uvm_object_utils(mix_clear_dac_min_max_reg)

  rand uvm_reg_field cmd_mix_clear_dac_min_max;


  function new (string name = "mix_clear_dac_min_max_reg");
    super.new(name, 1, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    //
    // -----------------------------------------------------------------------------
    cmd_mix_clear_dac_min_max = uvm_reg_field::type_id::create("cmd_mix_clear_dac_min_max");
    cmd_mix_clear_dac_min_max.configure(
      .parent(this),
      .size(1),
      .lsb_pos(0),
      .access("WO"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cmd_mix_clear_dac_min_max", 0, 1);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's input gain of the channels
// -----------------------------------------------------------------------------
class mixer_channel_gain_0_reg extends uvm_reg;

  `uvm_object_utils(mixer_channel_gain_0_reg)

  rand uvm_reg_field cr_mix_channel_gain_0;


  function new (string name = "mixer_channel_gain_0_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's input gain of the channels
    // -----------------------------------------------------------------------------
    cr_mix_channel_gain_0 = uvm_reg_field::type_id::create("cr_mix_channel_gain_0");
    cr_mix_channel_gain_0.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_channel_gain_0", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's input gain of the channels
// -----------------------------------------------------------------------------
class mixer_channel_gain_1_reg extends uvm_reg;

  `uvm_object_utils(mixer_channel_gain_1_reg)

  rand uvm_reg_field cr_mix_channel_gain_1;


  function new (string name = "mixer_channel_gain_1_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's input gain of the channels
    // -----------------------------------------------------------------------------
    cr_mix_channel_gain_1 = uvm_reg_field::type_id::create("cr_mix_channel_gain_1");
    cr_mix_channel_gain_1.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_channel_gain_1", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's input gain of the channels
// -----------------------------------------------------------------------------
class mixer_channel_gain_2_reg extends uvm_reg;

  `uvm_object_utils(mixer_channel_gain_2_reg)

  rand uvm_reg_field cr_mix_channel_gain_2;


  function new (string name = "mixer_channel_gain_2_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's input gain of the channels
    // -----------------------------------------------------------------------------
    cr_mix_channel_gain_2 = uvm_reg_field::type_id::create("cr_mix_channel_gain_2");
    cr_mix_channel_gain_2.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_channel_gain_2", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's input gain of the channels
// -----------------------------------------------------------------------------
class mixer_channel_gain_3_reg extends uvm_reg;

  `uvm_object_utils(mixer_channel_gain_3_reg)

  rand uvm_reg_field cr_mix_channel_gain_3;


  function new (string name = "mixer_channel_gain_3_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's input gain of the channels
    // -----------------------------------------------------------------------------
    cr_mix_channel_gain_3 = uvm_reg_field::type_id::create("cr_mix_channel_gain_3");
    cr_mix_channel_gain_3.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_channel_gain_3", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's pan of the channels
// -----------------------------------------------------------------------------
class mix_channel_pan_0_reg extends uvm_reg;

  `uvm_object_utils(mix_channel_pan_0_reg)

  rand uvm_reg_field cr_mix_channel_pan_0;


  function new (string name = "mix_channel_pan_0_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's pan of the channels
    // -----------------------------------------------------------------------------
    cr_mix_channel_pan_0 = uvm_reg_field::type_id::create("cr_mix_channel_pan_0");
    cr_mix_channel_pan_0.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_channel_pan_0", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's pan of the channels
// -----------------------------------------------------------------------------
class mix_channel_pan_1_reg extends uvm_reg;

  `uvm_object_utils(mix_channel_pan_1_reg)

  rand uvm_reg_field cr_mix_channel_pan_1;


  function new (string name = "mix_channel_pan_1_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's pan of the channels
    // -----------------------------------------------------------------------------
    cr_mix_channel_pan_1 = uvm_reg_field::type_id::create("cr_mix_channel_pan_1");
    cr_mix_channel_pan_1.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_channel_pan_1", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's pan of the channels
// -----------------------------------------------------------------------------
class mix_channel_pan_2_reg extends uvm_reg;

  `uvm_object_utils(mix_channel_pan_2_reg)

  rand uvm_reg_field cr_mix_channel_pan_2;


  function new (string name = "mix_channel_pan_2_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's pan of the channels
    // -----------------------------------------------------------------------------
    cr_mix_channel_pan_2 = uvm_reg_field::type_id::create("cr_mix_channel_pan_2");
    cr_mix_channel_pan_2.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_channel_pan_2", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's pan of the channels
// -----------------------------------------------------------------------------
class mix_channel_pan_3_reg extends uvm_reg;

  `uvm_object_utils(mix_channel_pan_3_reg)

  rand uvm_reg_field cr_mix_channel_pan_3;


  function new (string name = "mix_channel_pan_3_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's pan of the channels
    // -----------------------------------------------------------------------------
    cr_mix_channel_pan_3 = uvm_reg_field::type_id::create("cr_mix_channel_pan_3");
    cr_mix_channel_pan_3.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_channel_pan_3", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Mixer's input gain of the output
// -----------------------------------------------------------------------------
class mixer_output_gain_reg extends uvm_reg;

  `uvm_object_utils(mixer_output_gain_reg)

  rand uvm_reg_field cr_mix_output_gain;


  function new (string name = "mixer_output_gain_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Mixer's input gain of the output
    // -----------------------------------------------------------------------------
    cr_mix_output_gain = uvm_reg_field::type_id::create("cr_mix_output_gain");
    cr_mix_output_gain.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(1<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_mix_output_gain", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// None
// -----------------------------------------------------------------------------
class mix_out_clip_reg extends uvm_reg;

  `uvm_object_utils(mix_out_clip_reg)

  rand uvm_reg_field sr_mix_out_clip;


  function new (string name = "mix_out_clip_reg");
    super.new(name, 2, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // None
    // -----------------------------------------------------------------------------
    sr_mix_out_clip = uvm_reg_field::type_id::create("sr_mix_out_clip");
    sr_mix_out_clip.configure(
      .parent(this),
      .size(2),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_mix_out_clip", 0, 2);

  endfunction

endclass

// -----------------------------------------------------------------------------
// None
// -----------------------------------------------------------------------------
class mix_channel_clip_reg extends uvm_reg;

  `uvm_object_utils(mix_channel_clip_reg)

  rand uvm_reg_field sr_mix_channel_clip;


  function new (string name = "mix_channel_clip_reg");
    super.new(name, NR_OF_CHANNELS_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // None
    // -----------------------------------------------------------------------------
    sr_mix_channel_clip = uvm_reg_field::type_id::create("sr_mix_channel_clip");
    sr_mix_channel_clip.configure(
      .parent(this),
      .size(NR_OF_CHANNELS_P),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_mix_channel_clip", 0, NR_OF_CHANNELS_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// None
// -----------------------------------------------------------------------------
class mix_max_dac_amplitude_reg extends uvm_reg;

  `uvm_object_utils(mix_max_dac_amplitude_reg)

  rand uvm_reg_field sr_sr_mix_max_dac_amplitude;


  function new (string name = "mix_max_dac_amplitude_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // None
    // -----------------------------------------------------------------------------
    sr_sr_mix_max_dac_amplitude = uvm_reg_field::type_id::create("sr_sr_mix_max_dac_amplitude");
    sr_sr_mix_max_dac_amplitude.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_sr_mix_max_dac_amplitude", 0, AUDIO_WIDTH_P);

  endfunction

endclass

// -----------------------------------------------------------------------------
// None
// -----------------------------------------------------------------------------
class mix_min_dac_amplitude_reg extends uvm_reg;

  `uvm_object_utils(mix_min_dac_amplitude_reg)

  rand uvm_reg_field sr_sr_mix_min_dac_amplitude;


  function new (string name = "mix_min_dac_amplitude_reg");
    super.new(name, AUDIO_WIDTH_P, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // None
    // -----------------------------------------------------------------------------
    sr_sr_mix_min_dac_amplitude = uvm_reg_field::type_id::create("sr_sr_mix_min_dac_amplitude");
    sr_sr_mix_min_dac_amplitude.configure(
      .parent(this),
      .size(AUDIO_WIDTH_P),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("sr_sr_mix_min_dac_amplitude", 0, AUDIO_WIDTH_P);

  endfunction

endclass

