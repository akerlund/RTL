////////////////////////////////////////////////////////////////////////////////
// cocotb entry point for axi4s_m2s_arbiter.
//
// Flattens the 3-way packed master AXI4-Stream ports into per-master scalar
// signal groups (mst0_*/mst1_*/mst2_*) since cocotb/Verilator cannot address
// packed multi-dimensional array ports element-by-element. AXI_USER_WIDTH_P
// defaults to 1 (not the SV testbench's 0) to sidestep a zero-width vector
// port; TUSER_WIDTH_P=0 in the VIP config still forces every tuser value to 0,
// so this is functionally identical for this testbench.
////////////////////////////////////////////////////////////////////////////////

module tb_top #(
    parameter int AXI_DATA_WIDTH_P = 16,
    parameter int AXI_STRB_WIDTH_P = 2,
    parameter int AXI_KEEP_WIDTH_P = 2,
    parameter int AXI_ID_WIDTH_P   = 2,
    parameter int AXI_DEST_WIDTH_P = 1,
    parameter int AXI_USER_WIDTH_P = 1
  )(
    input  wire clk,
    input  wire rst_n,

    input  wire                          mst0_tvalid,
    output wire                          mst0_tready,
    input  wire [AXI_DATA_WIDTH_P-1 : 0] mst0_tdata,
    input  wire [AXI_STRB_WIDTH_P-1 : 0] mst0_tstrb,
    input  wire [AXI_KEEP_WIDTH_P-1 : 0] mst0_tkeep,
    input  wire                          mst0_tlast,
    input  wire   [AXI_ID_WIDTH_P-1 : 0] mst0_tid,
    input  wire [AXI_DEST_WIDTH_P-1 : 0] mst0_tdest,
    input  wire [AXI_USER_WIDTH_P-1 : 0] mst0_tuser,

    input  wire                          mst1_tvalid,
    output wire                          mst1_tready,
    input  wire [AXI_DATA_WIDTH_P-1 : 0] mst1_tdata,
    input  wire [AXI_STRB_WIDTH_P-1 : 0] mst1_tstrb,
    input  wire [AXI_KEEP_WIDTH_P-1 : 0] mst1_tkeep,
    input  wire                          mst1_tlast,
    input  wire   [AXI_ID_WIDTH_P-1 : 0] mst1_tid,
    input  wire [AXI_DEST_WIDTH_P-1 : 0] mst1_tdest,
    input  wire [AXI_USER_WIDTH_P-1 : 0] mst1_tuser,

    input  wire                          mst2_tvalid,
    output wire                          mst2_tready,
    input  wire [AXI_DATA_WIDTH_P-1 : 0] mst2_tdata,
    input  wire [AXI_STRB_WIDTH_P-1 : 0] mst2_tstrb,
    input  wire [AXI_KEEP_WIDTH_P-1 : 0] mst2_tkeep,
    input  wire                          mst2_tlast,
    input  wire   [AXI_ID_WIDTH_P-1 : 0] mst2_tid,
    input  wire [AXI_DEST_WIDTH_P-1 : 0] mst2_tdest,
    input  wire [AXI_USER_WIDTH_P-1 : 0] mst2_tuser,

    output wire                          slv_tvalid,
    input  wire                          slv_tready,
    output wire [AXI_DATA_WIDTH_P-1 : 0] slv_tdata,
    output wire [AXI_STRB_WIDTH_P-1 : 0] slv_tstrb,
    output wire [AXI_KEEP_WIDTH_P-1 : 0] slv_tkeep,
    output wire                          slv_tlast,
    output wire   [AXI_ID_WIDTH_P-1 : 0] slv_tid,
    output wire [AXI_DEST_WIDTH_P-1 : 0] slv_tdest,
    output wire [AXI_USER_WIDTH_P-1 : 0] slv_tuser
  );

  localparam int NR_OF_MASTERS_C = 3;

  wire [NR_OF_MASTERS_C-1 : 0]                          mst_tvalid;
  wire [NR_OF_MASTERS_C-1 : 0]                          mst_tready;
  wire [NR_OF_MASTERS_C-1 : 0] [AXI_DATA_WIDTH_P-1 : 0] mst_tdata;
  wire [NR_OF_MASTERS_C-1 : 0] [AXI_STRB_WIDTH_P-1 : 0] mst_tstrb;
  wire [NR_OF_MASTERS_C-1 : 0] [AXI_KEEP_WIDTH_P-1 : 0] mst_tkeep;
  wire [NR_OF_MASTERS_C-1 : 0]                          mst_tlast;
  wire [NR_OF_MASTERS_C-1 : 0]   [AXI_ID_WIDTH_P-1 : 0] mst_tid;
  wire [NR_OF_MASTERS_C-1 : 0] [AXI_DEST_WIDTH_P-1 : 0] mst_tdest;
  wire [NR_OF_MASTERS_C-1 : 0] [AXI_USER_WIDTH_P-1 : 0] mst_tuser;

  assign mst_tvalid[0] = mst0_tvalid;
  assign mst0_tready   = mst_tready[0];
  assign mst_tdata[0]  = mst0_tdata;
  assign mst_tstrb[0]  = mst0_tstrb;
  assign mst_tkeep[0]  = mst0_tkeep;
  assign mst_tlast[0]  = mst0_tlast;
  assign mst_tid[0]    = mst0_tid;
  assign mst_tdest[0]  = mst0_tdest;
  assign mst_tuser[0]  = mst0_tuser;

  assign mst_tvalid[1] = mst1_tvalid;
  assign mst1_tready   = mst_tready[1];
  assign mst_tdata[1]  = mst1_tdata;
  assign mst_tstrb[1]  = mst1_tstrb;
  assign mst_tkeep[1]  = mst1_tkeep;
  assign mst_tlast[1]  = mst1_tlast;
  assign mst_tid[1]    = mst1_tid;
  assign mst_tdest[1]  = mst1_tdest;
  assign mst_tuser[1]  = mst1_tuser;

  assign mst_tvalid[2] = mst2_tvalid;
  assign mst2_tready   = mst_tready[2];
  assign mst_tdata[2]  = mst2_tdata;
  assign mst_tstrb[2]  = mst2_tstrb;
  assign mst_tkeep[2]  = mst2_tkeep;
  assign mst_tlast[2]  = mst2_tlast;
  assign mst_tid[2]    = mst2_tid;
  assign mst_tdest[2]  = mst2_tdest;
  assign mst_tuser[2]  = mst2_tuser;

  axi4s_m2s_arbiter #(
    .NR_OF_MASTERS_P  ( NR_OF_MASTERS_C  ),
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( AXI_STRB_WIDTH_P ),
    .AXI_KEEP_WIDTH_P ( AXI_KEEP_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
    .AXI_DEST_WIDTH_P ( AXI_DEST_WIDTH_P ),
    .AXI_USER_WIDTH_P ( AXI_USER_WIDTH_P )
  ) dut (
    .clk        ( clk        ),
    .rst_n      ( rst_n      ),
    .mst_tvalid ( mst_tvalid ),
    .mst_tready ( mst_tready ),
    .mst_tdata  ( mst_tdata  ),
    .mst_tstrb  ( mst_tstrb  ),
    .mst_tkeep  ( mst_tkeep  ),
    .mst_tlast  ( mst_tlast  ),
    .mst_tid    ( mst_tid    ),
    .mst_tdest  ( mst_tdest  ),
    .mst_tuser  ( mst_tuser  ),
    .slv_tvalid ( slv_tvalid ),
    .slv_tready ( slv_tready ),
    .slv_tdata  ( slv_tdata  ),
    .slv_tstrb  ( slv_tstrb  ),
    .slv_tkeep  ( slv_tkeep  ),
    .slv_tlast  ( slv_tlast  ),
    .slv_tid    ( slv_tid    ),
    .slv_tdest  ( slv_tdest  ),
    .slv_tuser  ( slv_tuser  )
  );

endmodule
