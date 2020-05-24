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

`ifndef VIP_APB3_TYPES_PKG
`define VIP_APB3_TYPES_PKG

package vip_apb3_types_pkg;

  typedef enum {
    APB_MASTER_AGENT_E,
    APB_SLAVE_AGENT_E
  } vip_apb3_agent_type_t;

  typedef struct packed {
    int APB_ADDR_WIDTH_P;
    int APB_DATA_WIDTH_P;
    int APB_NR_OF_SLAVES_P;
  } vip_apb3_cfg_t;

endpackage

`endif
