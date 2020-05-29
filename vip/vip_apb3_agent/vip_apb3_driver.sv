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

class vip_apb3_driver #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_driver #(vip_apb3_item #(vip_cfg));

  protected virtual vip_apb3_if #(vip_cfg) vif;

  protected int   id;
  vip_apb3_config cfg;


  `uvm_component_param_utils_begin(vip_apb3_driver #(vip_cfg))
    `uvm_field_int(id, UVM_DEFAULT)
  `uvm_component_utils_end



  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual vip_apb3_if #(vip_cfg))::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
    end

  endfunction



  virtual task run_phase(uvm_phase phase);

    fork
      reset_signals();
      get_and_drive();
    join

  endtask



  virtual protected task reset_signals();

    forever begin

      @(negedge vif.rst_n);

      vif.paddr   <= '0;
      vif.psel    <= '0;
      vif.penable <= '0;
      vif.pwrite  <= '0;
      vif.pwdata  <= '0;


    end

  endtask



  virtual protected task get_and_drive();

    @(negedge vif.rst_n);
    @(posedge vif.rst_n);

    `uvm_info(get_name(), $sformatf("Reset asserted"), UVM_LOW)

    forever begin

      @(posedge vif.clk);

      seq_item_port.get_next_item(req);

      vif.paddr  <= req.paddr;
      vif.psel   <= (1 << req.psel);
      vif.pwrite <= req.pwrite;
      vif.pwdata <= req.pwdata;

      @(posedge vif.clk);

      vif.penable <= '1;

      @(posedge vif.clk);

      while (!vif.pready[req.psel]) begin
        @(posedge vif.clk);
      end

      if (req.pwrite == APB_OP_READ_E) begin
        rsp = new();
        rsp.prdata = vif.prdata[req.psel];
        rsp.set_id_info(req);
        seq_item_port.put(rsp);
      end

      vif.paddr   <= '0;
      vif.psel    <=  0;
      vif.penable <= '0;
      vif.pwrite  <= '0;
      vif.pwdata  <= '0;

      seq_item_port.item_done();


    end

  endtask

endclass
