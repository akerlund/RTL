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

class vip_apb3_monitor #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_monitor;

  protected virtual vip_apb3_if #(vip_cfg) vif;

  protected int id;
  vip_apb3_config cfg;


  `uvm_component_param_utils_begin(vip_apb3_monitor #(vip_cfg))
    `uvm_field_int(id, UVM_DEFAULT)
  `uvm_component_utils_end


  function new(string name, uvm_component parent);

    super.new(name, parent);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual vip_apb3_if #(vip_cfg))::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
    end

  endfunction



  virtual task run_phase(uvm_phase phase);

    fork
      monitor_reset();
      collect_transfers();
    join

  endtask



  virtual protected task monitor_reset();

    @(posedge vif.rst_n);

  endtask



  virtual protected task collect_transfers();

    vip_apb3_item #(vip_cfg) item = new();

    @(negedge vif.rst_n);
    @(posedge vif.rst_n);

    forever begin

      @(posedge vif.clk iff vif.rst_n == 1);

    end

  endtask

endclass
