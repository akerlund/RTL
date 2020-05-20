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

class vip_axi4s_config extends uvm_object;

  uvm_active_passive_enum is_active            = UVM_ACTIVE;
  vip_axi4s_agent_type_t  vip_axi4s_agent_type = VIP_AXI4S_MASTER_AGENT_E;

  //----------------------------------------------------------------------------
  // Slave configurations
  //----------------------------------------------------------------------------

  // Back pressure on 'tready'. Time and period are number of clock periods.
  int tready_back_pressure_enabled = 0;

  // Set how long 'tready' can be asserter for back pressure
  int min_tready_deasserted_time = 1;
  int max_tready_deasserted_time = 10;

  // Set the period of when 'tready' is de-asserted
  int min_tready_deasserted_period = 10;
  int max_tready_deasserted_period = 55;



  `uvm_object_utils_begin(vip_axi4s_config);
    `uvm_field_int(tready_back_pressure_enabled, UVM_DEFAULT)
    `uvm_field_int(min_tready_deasserted_time,   UVM_DEFAULT)
    `uvm_field_int(max_tready_deasserted_time,   UVM_DEFAULT)
    `uvm_field_int(min_tready_deasserted_period, UVM_DEFAULT)
    `uvm_field_int(max_tready_deasserted_period, UVM_DEFAULT)
  `uvm_object_utils_end;



  function new(string name = "vip_axi4s_config");
    super.new(name);
  endfunction


  // Enable backpressure on Write Data Channel
  function void set_tready_back_pressure_enabled(int enabled);
    this.tready_back_pressure_enabled = enabled;
  endfunction


  // Parameters for stimulating 'tready'
  function void configure_tready_parameters(
    int min_tready_deasserted_time,
    int max_tready_deasserted_time,
    int min_tready_deasserted_period,
    int max_tready_deasserted_period);

    this.min_tready_deasserted_time   = min_tready_deasserted_time;
    this.max_tready_deasserted_time   = max_tready_deasserted_time;
    this.min_tready_deasserted_period = min_tready_deasserted_period;
    this.max_tready_deasserted_period = max_tready_deasserted_period;
  endfunction


endclass
