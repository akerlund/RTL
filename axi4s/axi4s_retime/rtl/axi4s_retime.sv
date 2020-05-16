`default_nettype none

module axi4s_retime #(
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_STRB_WIDTH_P = -1,
    parameter int AXI_KEEP_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI_DEST_WIDTH_P = -1,
    parameter int AXI_USER_WIDTH_P = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // -------------------------------------------------------------------------
    // Ingress
    // -------------------------------------------------------------------------

    input  wire                           ing_tvalid,
    output logic                          ing_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] ing_tdata,
    input  wire  [AXI_STRB_WIDTH_P-1 : 0] ing_tstrb,
    input  wire  [AXI_KEEP_WIDTH_P-1 : 0] ing_tkeep,
    input  wire                           ing_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] ing_tid,
    input  wire  [AXI_DEST_WIDTH_P-1 : 0] ing_tdest,
    input  wire  [AXI_USER_WIDTH_P-1 : 0] ing_tuser,

    // -------------------------------------------------------------------------
    // Egress
    // -------------------------------------------------------------------------

    output logic                          egr_tvalid,
    input  wire                           egr_tready,
    output logic [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
    output logic [AXI_STRB_WIDTH_P-1 : 0] egr_tstrb,
    output logic [AXI_KEEP_WIDTH_P-1 : 0] egr_tkeep,
    output logic                          egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] egr_tid,
    output logic [AXI_DEST_WIDTH_P-1 : 0] egr_tdest,
    output logic [AXI_USER_WIDTH_P-1 : 0] egr_tuser
  );

  // FSM REG
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ing_tready <= '0;
      egr_tvalid <= '0;
      egr_tdata  <= '0;
      egr_tstrb  <= '0;
      egr_tkeep  <= '0;
      egr_tlast  <= '0;
      egr_tid    <= '0;
      egr_tdest  <= '0;
      egr_tuser  <= '0;
    end
    else begin
      ing_tready <= egr_tready;
      egr_tvalid <= ing_tvalid;
      egr_tdata  <= ing_tdata;
      egr_tstrb  <= ing_tstrb;
      egr_tkeep  <= ing_tkeep;
      egr_tlast  <= ing_tlast;
      egr_tid    <= ing_tid;
      egr_tdest  <= ing_tdest;
      egr_tuser  <= ing_tuser;
    end
  end


endmodule

`default_nettype wire
