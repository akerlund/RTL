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
class mix_block extends uvm_reg_block;

  `uvm_object_utils(mix_block)

  rand mix_clear_dac_min_max_reg mix_clear_dac_min_max;
  rand mixer_channel_gain_0_reg mixer_channel_gain_0;
  rand mixer_channel_gain_1_reg mixer_channel_gain_1;
  rand mixer_channel_gain_2_reg mixer_channel_gain_2;
  rand mixer_channel_gain_3_reg mixer_channel_gain_3;
  rand mix_channel_pan_0_reg mix_channel_pan_0;
  rand mix_channel_pan_1_reg mix_channel_pan_1;
  rand mix_channel_pan_2_reg mix_channel_pan_2;
  rand mix_channel_pan_3_reg mix_channel_pan_3;
  rand mixer_output_gain_reg mixer_output_gain;
  rand mix_out_clip_reg mix_out_clip;
  rand mix_channel_clip_reg mix_channel_clip;
  rand mix_max_dac_amplitude_reg mix_max_dac_amplitude;
  rand mix_min_dac_amplitude_reg mix_min_dac_amplitude;


  function new (string name = "mix_block");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction


  function void build();

    mix_clear_dac_min_max = mix_clear_dac_min_max_reg::type_id::create("mix_clear_dac_min_max");
    mix_clear_dac_min_max.build();
    mix_clear_dac_min_max.configure(this);

    mixer_channel_gain_0 = mixer_channel_gain_0_reg::type_id::create("mixer_channel_gain_0");
    mixer_channel_gain_0.build();
    mixer_channel_gain_0.configure(this);

    mixer_channel_gain_1 = mixer_channel_gain_1_reg::type_id::create("mixer_channel_gain_1");
    mixer_channel_gain_1.build();
    mixer_channel_gain_1.configure(this);

    mixer_channel_gain_2 = mixer_channel_gain_2_reg::type_id::create("mixer_channel_gain_2");
    mixer_channel_gain_2.build();
    mixer_channel_gain_2.configure(this);

    mixer_channel_gain_3 = mixer_channel_gain_3_reg::type_id::create("mixer_channel_gain_3");
    mixer_channel_gain_3.build();
    mixer_channel_gain_3.configure(this);

    mix_channel_pan_0 = mix_channel_pan_0_reg::type_id::create("mix_channel_pan_0");
    mix_channel_pan_0.build();
    mix_channel_pan_0.configure(this);

    mix_channel_pan_1 = mix_channel_pan_1_reg::type_id::create("mix_channel_pan_1");
    mix_channel_pan_1.build();
    mix_channel_pan_1.configure(this);

    mix_channel_pan_2 = mix_channel_pan_2_reg::type_id::create("mix_channel_pan_2");
    mix_channel_pan_2.build();
    mix_channel_pan_2.configure(this);

    mix_channel_pan_3 = mix_channel_pan_3_reg::type_id::create("mix_channel_pan_3");
    mix_channel_pan_3.build();
    mix_channel_pan_3.configure(this);

    mixer_output_gain = mixer_output_gain_reg::type_id::create("mixer_output_gain");
    mixer_output_gain.build();
    mixer_output_gain.configure(this);

    mix_out_clip = mix_out_clip_reg::type_id::create("mix_out_clip");
    mix_out_clip.build();
    mix_out_clip.configure(this);

    mix_channel_clip = mix_channel_clip_reg::type_id::create("mix_channel_clip");
    mix_channel_clip.build();
    mix_channel_clip.configure(this);

    mix_max_dac_amplitude = mix_max_dac_amplitude_reg::type_id::create("mix_max_dac_amplitude");
    mix_max_dac_amplitude.build();
    mix_max_dac_amplitude.configure(this);

    mix_min_dac_amplitude = mix_min_dac_amplitude_reg::type_id::create("mix_min_dac_amplitude");
    mix_min_dac_amplitude.build();
    mix_min_dac_amplitude.configure(this);



    default_map = create_map("mix_map", 0, 8, UVM_LITTLE_ENDIAN);

    default_map.add_reg(mix_clear_dac_min_max, 0, "WO");
    default_map.add_reg(mixer_channel_gain_0, 8, "RW");
    default_map.add_reg(mixer_channel_gain_1, 16, "RW");
    default_map.add_reg(mixer_channel_gain_2, 24, "RW");
    default_map.add_reg(mixer_channel_gain_3, 32, "RW");
    default_map.add_reg(mix_channel_pan_0, 40, "RW");
    default_map.add_reg(mix_channel_pan_1, 48, "RW");
    default_map.add_reg(mix_channel_pan_2, 56, "RW");
    default_map.add_reg(mix_channel_pan_3, 64, "RW");
    default_map.add_reg(mixer_output_gain, 72, "RW");
    default_map.add_reg(mix_out_clip, 80, "RO");
    default_map.add_reg(mix_channel_clip, 88, "RO");
    default_map.add_reg(mix_max_dac_amplitude, 96, "RO");
    default_map.add_reg(mix_min_dac_amplitude, 104, "RO");


    lock_model();

  endfunction

endclass
