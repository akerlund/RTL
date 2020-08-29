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

class clk_rst_monitor extends uvm_monitor;

  protected virtual clk_rst_if vif;

  clk_rst_config cfg;
  realtime       measured_reset_duration;

  `uvm_component_utils(clk_rst_monitor);

  uvm_analysis_port #(uvm_event) rst_watch_port;


  function new(string name, uvm_component parent);

    super.new(name, parent);

    rst_watch_port = new("rst_watch_port", this);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual clk_rst_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end

  endfunction



  virtual task run_phase(uvm_phase phase);

    // Waiting half a period because the reset is "asserted" at delta-time 0, a kind
    // of UVM DC component?
    #(cfg.clock_period/2);

    fork
      monitor_reset_assertions();
      monitor_reset_deassertions();
    join

  endtask



  virtual protected task monitor_reset_assertions();

    uvm_event rst_event;

    forever begin

      @(posedge vif.rst);
      `uvm_info(get_type_name(), "Reset asserted", UVM_LOW)
      measured_reset_duration = $realtime;
      rst_event = new("reset_asserted");
      rst_watch_port.write(rst_event);

    end

  endtask



  virtual protected task monitor_reset_deassertions();

    forever begin

      @(negedge vif.rst);
      `uvm_info(get_type_name(), "Reset de-asserted", UVM_LOW)
      measured_reset_duration = $realtime - measured_reset_duration;

      if (measured_reset_duration < cfg.clock_period) begin
        `uvm_info(get_type_name(), $sformatf("Reset period is lower than (1) clock period: (%f) < (%f)", measured_reset_duration, cfg.clock_period), UVM_LOW)
      end
      else begin
        `uvm_info(get_type_name(), $sformatf("Reset (rst/rst_n) was active for (%.2f) clock periods", measured_reset_duration/cfg.clock_period), UVM_LOW)
      end

    end

  endtask

endclass
