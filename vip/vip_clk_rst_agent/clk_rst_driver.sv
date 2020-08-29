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

class clk_rst_driver extends uvm_driver #(clk_rst_item);

  virtual clk_rst_if vif;

  clk_rst_config cfg;


  `uvm_component_utils(clk_rst_driver);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual clk_rst_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
    end

    if (!cfg.clock_period > 0) begin
      `uvm_fatal(get_full_name(), $sformatf("Clock period must be higher than: (%0f)", cfg.clock_period))
    end

  endfunction



  task pre_reset_phase(uvm_phase phase);

    vif.clk   = '0;
    vif.rst   = '0;
    vif.rst_n = '1;

  endtask



  virtual task run_phase(uvm_phase phase);

    fork
      drive_clock();
      get_reset_item();
    join

  endtask


  virtual protected task drive_clock();

    #(cfg.clock_period/2);

    forever begin

      vif.clk = ~vif.clk;
      #(cfg.clock_period/2);

    end

  endtask



  virtual protected task get_reset_item();

    vif.rst   = '0;
    vif.rst_n = '1;

    forever begin

      seq_item_port.get_next_item(req);

      drive_reset();

      seq_item_port.item_done();

    end

  endtask



  virtual protected task drive_reset();

    // Waiting half a period because the reset is "asserted" at delta-time 0, a kind
    // of UVM DC component? This is in case this sequence is started at the very
    // beginning which will trigger the Monitor to react falsely.

    #(cfg.clock_period/2);

    if (req.reset_edge != RESET_ASYNCHRONOUSLY_E) begin

      if (req.reset_edge == RESET_AT_CLK_RISING_EDGE_E) begin
        @(posedge vif.clk);
      end
      else begin
        @(negedge vif.clk);
      end

    end
    else begin
      #(3*cfg.clock_period/4);
    end

    vif.rst   =  req.reset_value;
    vif.rst_n = ~req.reset_value;

  endtask

endclass
