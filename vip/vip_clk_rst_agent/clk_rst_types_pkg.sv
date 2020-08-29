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

package clk_rst_types_pkg;

  typedef enum {
    RESET_ASYNCHRONOUSLY_E,
    RESET_AT_CLK_RISING_EDGE_E,
    RESET_AT_CLK_FALLING_EDGE_E
  } reset_edge_t;

  typedef enum bit {
    RESET_INACTIVE_E,
    RESET_ACTIVE_E
  } reset_value_t;

  typedef enum {
    RESET_ACTIVE_LOW_E,
    RESET_ACTIVE_HIGH_E
  } reset_active_t;

endpackage
