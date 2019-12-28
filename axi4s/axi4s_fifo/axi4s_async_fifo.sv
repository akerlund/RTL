`default_nettype none

module axi4s_async_fifo #(
    parameter int tuser_bit_width_p = -1,
    parameter int address_width_p   = -1
  )(
    input  wire                          clk_wp,
    input  wire                          rst_wp_n,
    input  wire                          clk_rp,
    input  wire                          rst_rp_n,

    output logic                         wp_axi4s_tready,
    input  wire  [tuser_bit_width_p-1:0] wp_axi4s_tuser,
    input  wire                          wp_axi4s_tvalid,

    input  wire                          rp_axi4s_tready,
    output logic [tuser_bit_width_p-1:0] rp_axi4s_tuser,
    output logic                         rp_axi4s_tvalid,

    output logic     [address_width_p:0] sr_wp_fill_level    
  );

  logic wp_fifo_full;
  logic rp_fifo_empty;

  logic sr_wp_fifo_active;
  logic sr_rp_fifo_active;

  logic wp_axi4s_transaction;
  logic rp_axi4s_transaction;

  assign wp_axi4s_tready      = !wp_fifo_full;
  assign rp_axi4s_tvalid      = !rp_fifo_empty;

  assign wp_axi4s_transaction = sr_wp_fifo_active && wp_axi4s_tready && wp_axi4s_tvalid;
  assign rp_axi4s_transaction = sr_rp_fifo_active && rp_axi4s_tready && rp_axi4s_tvalid;

  asynchronous_fifo #(
    .data_width_p         ( tuser_bit_width_p      ),
    .address_width_p      ( address_width_p        )
  ) asynchronous_fifo_i0 (
    .clk_wp               ( clk_wp                 ),
    .rst_wp_n             ( rst_wp_n               ),
    .clk_rp               ( clk_rp                 ),
    .rst_rp_n             ( rst_rp_n               ),
    .wp_write_en          ( wp_axi4s_transaction   ),
    .wp_data_in           ( wp_axi4s_tuser         ),
    .wp_fifo_full         ( wp_fifo_full           ),
    .rp_read_en           ( rp_axi4s_transaction   ),
    .rp_data_out          ( rp_axi4s_tuser         ),
    .rp_fifo_empty        ( rp_fifo_empty          ),
    .sr_wp_fifo_active    ( sr_wp_fifo_active      ),
    .sr_wp_fill_level     ( sr_wp_fill_level       ),
    .sr_wp_max_fill_level (                        ),
    .sr_rp_fifo_active    ( sr_rp_fifo_active      ),
    .sr_rp_fill_level     (                        )
  );

endmodule

`default_nettype wire