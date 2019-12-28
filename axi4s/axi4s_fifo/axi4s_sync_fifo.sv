`default_nettype none

module axi4s_sync_fifo #(
    parameter int tuser_bit_width_p = -1,
    parameter int address_width_p   = -1
  )(
    input  wire                          clk,
    input  wire                          rst_n,

    output logic                         axi4s_i_tready,
    input  wire  [tuser_bit_width_p-1:0] axi4s_i_tuser,
    input  wire                          axi4s_i_tvalid,

    input  wire                          axi4s_o_tready,
    output logic [tuser_bit_width_p-1:0] axi4s_o_tuser,
    output logic                         axi4s_o_tvalid,

    output logic     [address_width_p:0] sr_fill_level    
  );

  logic wp_fifo_full;
  logic rp_fifo_empty;
  logic axi4s_i_transaction;
  logic axi4s_o_transaction;

  assign axi4s_i_tready      = !wp_fifo_full;
  assign axi4s_o_tvalid      = !rp_fifo_empty;
  assign axi4s_i_transaction = axi4s_i_tready && axi4s_i_tvalid;
  assign axi4s_o_transaction = axi4s_o_tready && axi4s_o_tvalid;

  synchronous_fifo #(
    .data_width_p      ( tuser_bit_width_p   ),
    .address_width_p   ( address_width_p     )
  ) synchronous_fifo_i0 (
    .clk               ( clk                 ),
    .rst_n             ( rst_n               ),
    .wp_write_en       ( axi4s_i_transaction ),
    .wp_data_in        ( axi4s_i_tuser       ),
    .wp_fifo_full      ( wp_fifo_full        ),
    .rp_read_en        ( axi4s_o_transaction ),
    .rp_data_out       ( axi4s_o_tuser       ),
    .rp_fifo_empty     ( rp_fifo_empty       ),
    .sr_fill_level     ( sr_fill_level       ),
    .sr_max_fill_level (                     )
  );

endmodule

`default_nettype wire