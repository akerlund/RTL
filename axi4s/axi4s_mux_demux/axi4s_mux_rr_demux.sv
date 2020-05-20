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

module axi4s_mux_rr_demux #(
    parameter int nr_of_streams_p = -1,
    parameter int tdata_width_p   = -1,
    parameter int tid_bit_width_p = $clog2(nr_of_streams_p)
  )(
    // Clock and reset
    input  wire                                                clk,
    input  wire                                                rst_n,

    //--------------------------------------------------------------------------
    // MUX
    //--------------------------------------------------------------------------

    // AXI4-S master side
    output logic                         [nr_of_streams_p-1 : 0] axi4s_mux_rr_i_tready,
    input  wire                          [nr_of_streams_p-1 : 0] axi4s_mux_rr_i_tvalid,
    input  wire                          [nr_of_streams_p-1 : 0] axi4s_mux_rr_i_tlast,
    input  wire  [nr_of_streams_p-1 : 0] [tdata_width_p*8-1 : 0] axi4s_mux_rr_i_tdata,

    // AXI4-S slave side
    input  wire                                                  axi4s_mux_rr_o_tready,
    output logic                                                 axi4s_mux_rr_o_tvalid,
    output logic                                                 axi4s_mux_rr_o_tlast,
    output logic                         [tid_bit_width_p-1 : 0] axi4s_mux_rr_o_tid,
    output logic                         [tdata_width_p*8-1 : 0] axi4s_mux_rr_o_tdata,

    //--------------------------------------------------------------------------
    // DEMUX
    //--------------------------------------------------------------------------

    // AXI4-S master side
    output logic                                                 axi4s_demux_i_tready,
    input  wire                                                  axi4s_demux_i_tvalid,
    input  wire                                                  axi4s_demux_i_tlast,
    input  wire                          [tid_bit_width_p-1 : 0] axi4s_demux_i_tid,
    input  wire                          [tdata_width_p*8-1 : 0] axi4s_demux_i_tdata,

    // AXI4-S slave side
    input  wire                          [nr_of_streams_p-1 : 0] axi4s_demux_o_tready,
    output logic                         [nr_of_streams_p-1 : 0] axi4s_demux_o_tvalid,
    output logic                         [nr_of_streams_p-1 : 0] axi4s_demux_o_tlast,
    output logic [nr_of_streams_p-1 : 0] [tdata_width_p*8-1 : 0] axi4s_demux_o_tdata
  );

  // Round robin multiplexer, i.e.,
  // (nr_of_streams_p) masters as inputs out to (one) slave
  axi4s_mux_rr #(
    .nr_of_streams_p ( nr_of_streams_p       ),
    .tdata_width_p   ( tdata_width_p         )
  ) axi4s_mux_rr_i0 (
    // Clock and reset
    .clk             ( clk                   ), // input
    .rst_n           ( rst_n                 ), // input

    // AXI4-S master side
    .axi4s_i_tready  ( axi4s_mux_rr_i_tready ), // output
    .axi4s_i_tvalid  ( axi4s_mux_rr_i_tvalid ), // input
    .axi4s_i_tlast   ( axi4s_mux_rr_i_tlast  ), // input
    .axi4s_i_tdata   ( axi4s_mux_rr_i_tdata  ), // input  [nr_of_streams_p]

    // AXI4-S slave side
    .axi4s_o_tready  ( axi4s_mux_rr_o_tready ), // input
    .axi4s_o_tvalid  ( axi4s_mux_rr_o_tvalid ), // output
    .axi4s_o_tlast   ( axi4s_mux_rr_o_tlast  ), // output
    .axi4s_o_tid     ( axi4s_mux_rr_o_tid    ), // output
    .axi4s_o_tdata   ( axi4s_mux_rr_o_tdata  )  // output [1]
  );

  // De-multiplexer
  axi4s_demux #(
    .nr_of_streams_p ( nr_of_streams_p      ),
    .tdata_width_p   ( tdata_width_p        )
  ) axi4s_demux_i0 (
    // Clock and reset
    .clk             ( clk                  ), // input
    .rst_n           ( rst_n                ), // input

    // AXI4-S master side
    .axi4s_i_tready  ( axi4s_demux_i_tready ), // output
    .axi4s_i_tvalid  ( axi4s_demux_i_tvalid ), // input
    .axi4s_i_tlast   ( axi4s_demux_i_tlast  ), // input
    .axi4s_i_tid     ( axi4s_demux_i_tid    ), // input
    .axi4s_i_tdata   ( axi4s_demux_i_tdata  ), // input  [1]

    // AXI4-S slave side
    .axi4s_o_tready  ( axi4s_demux_o_tready ), // input
    .axi4s_o_tvalid  ( axi4s_demux_o_tvalid ), // output
    .axi4s_o_tlast   ( axi4s_demux_o_tlast  ), // output
    .axi4s_o_tdata   ( axi4s_demux_o_tdata  )  // output [nr_of_streams_p]
  );

endmodule

`default_nettype wire
