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

interface vip_apb3_if #(
    parameter vip_apb3_cfg_t cfg = '{default: '0}
  )(
    input clk,
    input rst_n
  );

  logic                                  [cfg.APB_ADDR_WIDTH_P-1 : 0] paddr;
  logic                                [cfg.APB_NR_OF_SLAVES_P-1 : 0] psel;
  logic                                                               penable;
  logic                                                               pwrite;
  logic                                  [cfg.APB_DATA_WIDTH_P-1 : 0] pwdata;
  logic                                [cfg.APB_NR_OF_SLAVES_P-1 : 0] pready;
  logic [cfg.APB_NR_OF_SLAVES_P-1 : 0]   [cfg.APB_DATA_WIDTH_P-1 : 0] prdata;
  logic                                                               pslverr;

endinterface
