////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

class osc_env extends uvm_env;

  `uvm_component_utils_begin(osc_env)
  `uvm_component_utils_end

  clk_rst_agent                   clk_rst_agent0;
  vip_axi4_agent #(VIP_REG_CFG_C, VIP_AXI4_ROLE_MANAGER_E) reg_agent0;
  osc_virtual_sequencer virtual_sequencer;

  register_model   reg_model;
  vip_axi4_adapter #(VIP_REG_CFG_C) vip_axi4_adapter0;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //----------------------------------------------------------------------------
  //
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    reg_model = register_model::type_id::create("reg_model");
    reg_model.build();
    reg_model.reset();
    uvm_config_db #(register_model)::set(null, "", "reg_model", reg_model);
    vip_axi4_adapter0 = vip_axi4_adapter #(VIP_REG_CFG_C)::type_id::create("vip_axi4_adapter0",, get_full_name());

    clk_rst_agent0 = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    reg_agent0     = vip_axi4_agent #(VIP_REG_CFG_C, VIP_AXI4_ROLE_MANAGER_E)::type_id::create("reg_agent0", this);
    uvm_config_db #(int)::set(this, {"reg_agent0", "*"}, "id", 0);

    virtual_sequencer = osc_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(osc_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction

  //----------------------------------------------------------------------------
  //
  //----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    reg_model.default_map.set_sequencer(.sequencer(reg_agent0.sequencer), .adapter(vip_axi4_adapter0));
    reg_model.default_map.set_base_addr('h00000000);
    virtual_sequencer.clk_rst_sequencer0 = clk_rst_agent0.sequencer;
  endfunction

endclass
