////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
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

class tc_positive_signals extends mix_base_test;

  `uvm_component_utils(tc_positive_signals)

  function new(string name = "tc_positive_signals", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction



  task run_phase(uvm_phase phase);

    mix_vif.cr_channel_gain[0] = float_to_fixed_point(1.00, Q_BITS_C);
    mix_vif.cr_channel_pan[0]  = float_to_fixed_point(1.00, Q_BITS_C);
    mix_vif.cr_output_gain[0]  = float_to_fixed_point(1.00, Q_BITS_C);

    super.run_phase(phase);
    phase.raise_objection(this);

    clk_delay(10);
    mix_vif.cr_channel_gain[0] = float_to_fixed_point(1.25, Q_BITS_C);
    mix_vif.cr_channel_pan[0]  = float_to_fixed_point(0.25, Q_BITS_C);
    mix_vif.cr_output_gain[0]  = float_to_fixed_point(0.80, Q_BITS_C);

    clk_delay(10);
    mix_vif.cr_channel_gain[0] = float_to_fixed_point(0.80, Q_BITS_C);
    mix_vif.cr_channel_pan[0]  = float_to_fixed_point(0.75, Q_BITS_C);
    mix_vif.cr_output_gain[0]  = float_to_fixed_point(1.25, Q_BITS_C);

    phase.drop_objection(this);

  endtask

endclass
