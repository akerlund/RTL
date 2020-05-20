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

interface vip_axi4s_if #(
  parameter vip_axi4s_cfg_t cfg = '{default: '0}
  )(
    input clk,
    input rst_n
  );

  logic                              tvalid;
  logic                              tready;
  logic [cfg.AXI_DATA_WIDTH_P-1 : 0] tdata;
  logic [cfg.AXI_STRB_WIDTH_P-1 : 0] tstrb;
  logic [cfg.AXI_KEEP_WIDTH_P-1 : 0] tkeep;
  logic                              tlast;
  logic   [cfg.AXI_ID_WIDTH_P-1 : 0] tid;
  logic [cfg.AXI_DEST_WIDTH_P-1 : 0] tdest;
  logic [cfg.AXI_USER_WIDTH_P-1 : 0] tuser;

endinterface
