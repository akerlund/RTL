`default_nettype none

module axi4s_mux_rr_demux #(
    parameter int nr_of_streams_p    = -1,
    parameter int tdata_byte_width_p = -1,
    parameter int byte_width_p       = nr_of_streams_p * tdata_byte_width_p,
    parameter int tid_bit_width_p    = nr_of_streams_p * $clog2(nr_of_streams_p)
  )(
    input  wire                            clk,
    input  wire                            rst_n,

    // MUX
    // AXI4-S master side
    output logic         [nr_of_streams_p-1:0] axi4s_mux_rr_i_tready,
    input  wire             [byte_width_p-1:0] axi4s_mux_rr_i_tdata,
    input  wire          [nr_of_streams_p-1:0] axi4s_mux_rr_i_tvalid,
    input  wire          [nr_of_streams_p-1:0] axi4s_mux_rr_i_tlast,
    input  wire          [tid_bit_width_p-1:0] axi4s_mux_rr_i_tid,

    // AXI4-S slave side
    input  wire                                axi4s_mux_rr_o_tready,
    output logic      [tdata_byte_width_p-1:0] axi4s_mux_rr_o_tdata,
    output logic                               axi4s_mux_rr_o_tvalid,
    output logic                               axi4s_mux_rr_o_tlast,
    output logic [$clog2(nr_of_streams_p)-1:0] axi4s_mux_rr_o_tid,

    // DEMUX
    // AXI4-S master side
    output logic                               axi4s_demux_i_tready,
    input  wire       [tdata_byte_width_p-1:0] axi4s_demux_i_tdata,
    input  wire                                axi4s_demux_i_tvalid,
    input  wire                                axi4s_demux_i_tlast,
    input  wire  [$clog2(nr_of_streams_p)-1:0] axi4s_demux_i_tid,

    // AXI4-S slave side
    input  wire          [nr_of_streams_p-1:0] axi4s_demux_o_tready,
    output logic            [byte_width_p-1:0] axi4s_demux_o_tdata,
    output logic         [nr_of_streams_p-1:0] axi4s_demux_o_tvalid,
    output logic         [nr_of_streams_p-1:0] axi4s_demux_o_tlast,
    output logic         [tid_bit_width_p-1:0] axi4s_demux_o_tid
  );

  axi4s_mux_rr #(
    .nr_of_streams_p    ( nr_of_streams_p       ),
    .tdata_byte_width_p ( tdata_byte_width_p    )
  ) axi4s_mux_rr_i0 (
    .clk                ( clk                   ),
    .rst_n              ( rst_n                 ),
    .axi4s_i_tready     ( axi4s_mux_rr_i_tready ),
    .axi4s_i_tdata      ( axi4s_mux_rr_i_tdata  ),
    .axi4s_i_tvalid     ( axi4s_mux_rr_i_tvalid ),
    .axi4s_i_tlast      ( axi4s_mux_rr_i_tlast  ),
    .axi4s_i_tid        ( axi4s_mux_rr_i_tid    ),
    .axi4s_o_tready     ( axi4s_mux_rr_o_tready ),
    .axi4s_o_tdata      ( axi4s_mux_rr_o_tdata  ),
    .axi4s_o_tvalid     ( axi4s_mux_rr_o_tvalid ),
    .axi4s_o_tlast      ( axi4s_mux_rr_o_tlast  ),
    .axi4s_o_tid        ( axi4s_mux_rr_o_tid    )
  );

   axi4s_demux #(
    .nr_of_streams_p    ( nr_of_streams_p      ),
    .tdata_byte_width_p ( tdata_byte_width_p   )
   ) axi4s_demux_i0 (
    .clk                ( clk                  ),
    .rst_n              ( rst_n                ),
    .axi4s_i_tready     ( axi4s_demux_i_tready ),
    .axi4s_i_tdata      ( axi4s_demux_i_tdata  ),
    .axi4s_i_tvalid     ( axi4s_demux_i_tvalid ),
    .axi4s_i_tlast      ( axi4s_demux_i_tlast  ),
    .axi4s_i_tid        ( axi4s_demux_i_tid    ),
    .axi4s_o_tready     ( axi4s_demux_o_tready ),
    .axi4s_o_tdata      ( axi4s_demux_o_tdata  ),
    .axi4s_o_tvalid     ( axi4s_demux_o_tvalid ),
    .axi4s_o_tlast      ( axi4s_demux_o_tlast  ),
    .axi4s_o_tid        ( axi4s_demux_o_tid    )
  );


endmodule

`default_nettype wire