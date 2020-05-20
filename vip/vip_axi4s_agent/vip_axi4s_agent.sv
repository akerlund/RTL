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

class vip_axi4s_agent #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_agent;

  protected int id;

  vip_axi4s_monitor   #(vip_cfg) monitor;
  vip_axi4s_driver    #(vip_cfg) driver;
  vip_axi4s_sequencer #(vip_cfg) sequencer;

  vip_axi4s_config    cfg;


  `uvm_component_param_utils_begin(vip_axi4s_agent #(vip_cfg))
    `uvm_field_int(id, UVM_DEFAULT)
    `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
  `uvm_component_utils_end;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(vip_axi4s_config)::get(this, "", "cfg", cfg)) begin
      `uvm_info(get_type_name(), "Agent has no config, creating a default config", UVM_LOW)
      cfg = vip_axi4s_config::type_id::create("default_config", this);
    end

    monitor     = vip_axi4s_monitor #(vip_cfg)::type_id::create("monitor", this);
    monitor.cfg = cfg;

    if (cfg.is_active == UVM_ACTIVE) begin

      driver        = vip_axi4s_driver #(vip_cfg)::type_id::create("driver", this);
      driver.cfg    = cfg;
      sequencer     = vip_axi4s_sequencer #(vip_cfg)::type_id::create("sequencer", this);
      sequencer.cfg = cfg;

    end

  endfunction



  function void connect_phase(uvm_phase phase);

    if (cfg.is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end

  endfunction

endclass
