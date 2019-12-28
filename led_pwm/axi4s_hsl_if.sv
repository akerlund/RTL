`default_nettype none

module axi4s_hsl_if #(
    parameter int tid_bit_width_p    = -1
  )(
    input  wire                        clk,
    input  wire                        rst_n,

    // AXI4-S master side
    output logic                       axi4s_i_tready,
    input  wire                 [23:0] axi4s_i_tdata,
    input  wire                        axi4s_i_tvalid,
    input  wire  [tid_bit_width_p-1:0] axi4s_i_tid,

    // AXI4-S slave side
    input  wire                        axi4s_o_tready,
    output logic                [23:0] axi4s_o_tdata,
    output logic                       axi4s_o_tvalid,
    output logic [tid_bit_width_p-1:0] axi4s_o_tid
  );

  logic axi4s_i_transaction;
  logic axi4s_o_transaction;

  assign axi4s_i_transaction = axi4s_i_tready && axi4s_i_tvalid;
  assign axi4s_o_transaction = axi4s_o_tready && axi4s_o_tvalid;

  color_hsl_12bit_color color_hsl_12bit_color_i0 (
    .clk         ( clk                  ),
    .rst_n       ( rst_n                ),
    .ready       ( axi4s_i_tready       ),
    .valid_hue   ( axi4s_i_transaction  ),
    .hue         ( axi4s_i_tdata[7:0]   ),
    .saturation  ( axi4s_i_tdata[15:8]  ),
    .brightness  ( axi4s_i_tdata[23:16] ),
    .valid_rgb   ( axi4s_o_tvalid       ),
    .color_red   ( axi4s_o_tdata[7:0]   ),
    .color_green ( axi4s_o_tdata[15:8]  ),
    .color_blue  ( axi4s_o_tdata[23:16] )
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      axi4s_o_tid <= '0;
    end
    else begin
      if (axi4s_i_transaction) begin
        axi4s_o_tid <= axi4s_o_tid;
      end
    end
  end

endmodule

`default_nettype wire