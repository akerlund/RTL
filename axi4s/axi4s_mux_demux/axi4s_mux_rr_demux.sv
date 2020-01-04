`default_nettype none

// Description
//
// This module contains one round robin multiplexer and
// one de-multiplexer.

module axi4s_mux_rr_demux #(
    parameter int nr_of_streams_p    = -1,
    parameter int tdata_width_p = -1,
    parameter int tid_bit_width_p    = $clog2(nr_of_streams_p)
  )(
    input  wire                                                clk,
    input  wire                                                rst_n,

    ////////////////////////////////////////////////////////////////////////////
    // MUX
    ////////////////////////////////////////////////////////////////////////////

    // AXI4-S master side
    output logic                         [nr_of_streams_p-1:0] axi4s_mux_rr_i_tready,
    input  wire                          [nr_of_streams_p-1:0] axi4s_mux_rr_i_tvalid,
    input  wire                          [nr_of_streams_p-1:0] axi4s_mux_rr_i_tlast,
    input  wire  [nr_of_streams_p-1 : 0] [tdata_width_p-1 : 0] axi4s_mux_rr_i_tdata,

    // AXI4-S slave side
    input  wire                                                axi4s_mux_rr_o_tready,
    output logic                                               axi4s_mux_rr_o_tvalid,
    output logic                                               axi4s_mux_rr_o_tlast,
    output logic                         [tid_bit_width_p-1:0] axi4s_mux_rr_o_tid,
    output logic                           [tdata_width_p-1:0] axi4s_mux_rr_o_tdata,

    ////////////////////////////////////////////////////////////////////////////
    // DEMUX
    ////////////////////////////////////////////////////////////////////////////

    // AXI4-S master side
    output logic                                               axi4s_demux_i_tready,
    input  wire                                                axi4s_demux_i_tvalid,
    input  wire                                                axi4s_demux_i_tlast,
    input  wire                          [tid_bit_width_p-1:0] axi4s_demux_i_tid,
    input  wire                            [tdata_width_p-1:0] axi4s_demux_i_tdata,

    // AXI4-S slave side
    input  wire                          [nr_of_streams_p-1:0] axi4s_demux_o_tready,
    output logic                         [nr_of_streams_p-1:0] axi4s_demux_o_tvalid,
    output logic                         [nr_of_streams_p-1:0] axi4s_demux_o_tlast,
    output logic [nr_of_streams_p-1 : 0] [tdata_width_p-1 : 0] axi4s_demux_o_tdata
  );

  // Round robin multiplexer, i.e.,
  // (nr_of_streams_p) masters to (one) slave
  axi4s_mux_rr #(
    .nr_of_streams_p ( nr_of_streams_p       ),
    .tdata_width_p   ( tdata_width_p         )
  ) axi4s_mux_rr_i0 (
    .clk             ( clk                   ), // input
    .rst_n           ( rst_n                 ), // input

    .axi4s_i_tready  ( axi4s_mux_rr_i_tready ), // output [nr_of_streams_p]
    .axi4s_i_tvalid  ( axi4s_mux_rr_i_tvalid ), // input
    .axi4s_i_tlast   ( axi4s_mux_rr_i_tlast  ), // input
    .axi4s_i_tdata   ( axi4s_mux_rr_i_tdata  ), // input

    .axi4s_o_tready  ( axi4s_mux_rr_o_tready ), // input  [1]
    .axi4s_o_tvalid  ( axi4s_mux_rr_o_tvalid ), // output
    .axi4s_o_tlast   ( axi4s_mux_rr_o_tlast  ), // output
    .axi4s_o_tid     ( axi4s_mux_rr_o_tid    ), // output
    .axi4s_o_tdata   ( axi4s_mux_rr_o_tdata  )  // output
  );

  // De-multiplexer
  axi4s_demux #(
    .nr_of_streams_p    ( nr_of_streams_p      ),
    .tdata_width_p      ( tdata_width_p        )
  ) axi4s_demux_i0 (
    .clk                ( clk                  ),
    .rst_n              ( rst_n                ),

    .axi4s_i_tready     ( axi4s_demux_i_tready ),
    .axi4s_i_tvalid     ( axi4s_demux_i_tvalid ),
    .axi4s_i_tlast      ( axi4s_demux_i_tlast  ),
    .axi4s_i_tid        ( axi4s_demux_i_tid    ),
    .axi4s_i_tdata      ( axi4s_demux_i_tdata  ),

    .axi4s_o_tready     ( axi4s_demux_o_tready ),
    .axi4s_o_tvalid     ( axi4s_demux_o_tvalid ),
    .axi4s_o_tlast      ( axi4s_demux_o_tlast  ),
    .axi4s_o_tdata      ( axi4s_demux_o_tdata  )
  );

endmodule

`default_nettype wire
