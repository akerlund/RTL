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

class vip_axi4s_item #(
  vip_axi4s_cfg_t cfg = '{default: '0}
  ) extends uvm_sequence_item;

  // ---------------------------------------------------------------------------
  // AXI4-S signals
  // ---------------------------------------------------------------------------

  rand logic [cfg.AXI_DATA_WIDTH_P-1 : 0] tdata [];
       logic [cfg.AXI_STRB_WIDTH_P-1 : 0] tstrb [];
       logic [cfg.AXI_KEEP_WIDTH_P-1 : 0] tkeep [];
  rand logic   [cfg.AXI_ID_WIDTH_P-1 : 0] tid       = '0;
  rand logic [cfg.AXI_DEST_WIDTH_P-1 : 0] tdest     = '0;
       logic [cfg.AXI_USER_WIDTH_P-1 : 0] tuser [];

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  int burst_size;
  //constraint con_name {}


  `uvm_object_param_utils_begin(vip_axi4s_item #(cfg))
    `uvm_field_int(tid,          UVM_DEFAULT)
    `uvm_field_int(tdest,        UVM_DEFAULT)
    `uvm_field_sarray_int(tdata, UVM_DEFAULT)
    `uvm_field_sarray_int(tstrb, UVM_DEFAULT)
    `uvm_field_sarray_int(tkeep, UVM_DEFAULT)
    `uvm_field_sarray_int(tuser, UVM_DEFAULT)
  `uvm_object_utils_end


  function new(string name = "vip_axi4s_item");

    super.new(name);
    burst_size = -1;

  endfunction


  function void pre_randomize();

    if (burst_size == -1) begin
      burst_size = $urandom_range(1, AXI4S_MAX_BURST_LENGTH_C / cfg.AXI_DATA_WIDTH_P);
    end

    tdata = new[burst_size];
    tstrb = new[burst_size];
    tkeep = new[burst_size];
    tuser = new[burst_size];

    foreach (tstrb[i]) begin
      tstrb[i] = '0;
    end

    foreach (tkeep[i]) begin
      tkeep[i] = '1;
    end

    foreach (tuser[i]) begin
      tuser[i] = '0;
    end

  endfunction

endclass
