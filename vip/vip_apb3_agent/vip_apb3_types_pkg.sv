////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
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
  } vip_apb3_cfg_t;

endpackage

`endif
