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

`default_nettype none

module axi4s_sync_fifo #(
    parameter int TUSER_WIDTH_P   = -1,
    parameter int ADDRESS_WIDTH_P = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,

    output logic                       ing_tready,
    input  wire  [TUSER_WIDTH_P-1 : 0] ing_tuser,
    input  wire                        ing_tvalid,

    input  wire                        egr_tready,
    output logic [TUSER_WIDTH_P-1 : 0] egr_tuser,
    output logic                       egr_tvalid,

    output logic [ADDRESS_WIDTH_P : 0] sr_fill_level,
    output logic [ADDRESS_WIDTH_P : 0] sr_max_fill_level,
    input  wire  [ADDRESS_WIDTH_P : 0] cr_almost_full_level
  );

  logic wp_fifo_full;
  logic rp_fifo_empty;
  logic ing_transaction;
  logic egr_transaction;

  assign ing_tready      = !wp_fifo_full;
  assign egr_tvalid      = !rp_fifo_empty;

  assign ing_transaction = ing_tready && ing_tvalid;
  assign egr_transaction = egr_tready && egr_tvalid;

  synchronous_fifo #(
    .DATA_WIDTH_P         ( TUSER_WIDTH_P        ),
    .ADDRESS_WIDTH_P      ( ADDRESS_WIDTH_P      )
  ) synchronous_fifo_i0 (
    .clk                  ( clk                  ), // input
    .rst_n                ( rst_n                ), // input
    .ing_enable           ( ing_transaction      ), // input
    .ing_data             ( ing_tuser            ), // input
    .ing_full             ( wp_fifo_full         ), // output
    .ing_almost_full      (                      ), // output
    .egr_enable           ( egr_transaction      ), // input
    .egr_data             ( egr_tuser            ), // output
    .egr_empty            ( rp_fifo_empty        ), // output
    .sr_fill_level        ( sr_fill_level        ), // output
    .sr_max_fill_level    ( sr_max_fill_level    ), // output
    .cr_almost_full_level ( cr_almost_full_level )  // input
  );

endmodule

`default_nettype wire