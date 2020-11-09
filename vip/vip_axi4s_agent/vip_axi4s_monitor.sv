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

class vip_axi4s_monitor #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_monitor;

  // Virtual interface to the DUT
  protected virtual vip_axi4s_if #(vip_cfg) vif;

  // Analysis ports
  uvm_analysis_port #(vip_axi4s_item #(vip_cfg)) collected_port;

  // Monitor variables
  protected int    id;
  vip_axi4s_config cfg;


  // Ingress data is saved in dynamic lists. When 'tlast' is asserted the data
  // is copied over to a write_item.
  logic [vip_cfg.AXI_DATA_WIDTH_P : 0] tdata_transactions [$];
  logic [vip_cfg.AXI_STRB_WIDTH_P : 0] tstrb_transactions [$];
  logic [vip_cfg.AXI_KEEP_WIDTH_P : 0] tkeep_transactions [$];
  logic [vip_cfg.AXI_USER_WIDTH_P : 0] tuser_transactions [$];


  `uvm_component_param_utils_begin(vip_axi4s_monitor #(vip_cfg))
    `uvm_field_int(id, UVM_DEFAULT)
  `uvm_component_utils_end



  function new(string name, uvm_component parent);

    super.new(name, parent);
    collected_port = new("collected_port", this);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual vip_axi4s_if #(vip_cfg))::get(this, "", "vif", vif)) begin
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

    int transfer_counter = 0;

    vip_axi4s_item #(vip_cfg) collected_item;

    @(negedge vif.rst_n);
    @(posedge vif.rst_n);

    forever begin

      @(posedge vif.clk iff vif.rst_n == 1);

      if (vif.tvalid && vif.tready) begin
        tdata_transactions.push_back(vif.tdata);
        tstrb_transactions.push_back(vif.tstrb);
        tkeep_transactions.push_back(vif.tkeep);
        tuser_transactions.push_back(vif.tuser);
      end

      // Upon 'tlast'
      if (vif.tlast && vif.tvalid && vif.tready) begin

        // Create a write item and allocate memory for the arrays
        collected_item       = new();
        transfer_counter     = tdata_transactions.size();
        collected_item.tdata = new[transfer_counter];
        collected_item.tstrb = new[transfer_counter];
        collected_item.tkeep = new[transfer_counter];
        collected_item.tuser = new[transfer_counter];

        // Append 'tdata'
        foreach (tdata_transactions[i]) begin
          collected_item.tdata[i] = tdata_transactions[i];
        end

        // Append 'tstrb'
        foreach (tstrb_transactions[i]) begin
          collected_item.tstrb[i] = tstrb_transactions[i];
        end

        // Append 'tkeep'
        foreach (tkeep_transactions[i]) begin
          collected_item.tkeep[i] = tkeep_transactions[i];
        end

        // Append 'tuser'
        foreach (tuser_transactions[i]) begin
          collected_item.tuser[i] = tuser_transactions[i];
        end

        collected_item.tid   = vif.tid;
        collected_item.tdest = vif.tdest;

        // Delete the saved transactions
        tdata_transactions.delete();
        tstrb_transactions.delete();
        tkeep_transactions.delete();
        tuser_transactions.delete();

        `uvm_info(get_type_name(), $sformatf("Collected transfer:\n%s", collected_item.sprint()), UVM_HIGH)
        collected_port.write(collected_item);

      end

    end

  endtask

endclass
