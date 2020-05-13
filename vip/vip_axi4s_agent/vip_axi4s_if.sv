interface vip_axi4s_if #(
  parameter vip_axi4s_cfg_t cfg = '{default: '0}
  )(
    input clk,
    input rst_n
  );

  logic                              tvalid;
  logic                              tready;
  logic [cfg.AXI_DATA_WIDTH_P-1 : 0] tdata;
  logic [cfg.AXI_STRB_WIDTH_P-1 : 0] tstrb;
  logic [cfg.AXI_KEEP_WIDTH_P-1 : 0] tkeep;
  logic                              tlast;
  logic   [cfg.AXI_ID_WIDTH_P-1 : 0] tid;
  logic [cfg.AXI_DEST_WIDTH_P-1 : 0] tdest;
  logic [cfg.AXI_USER_WIDTH_P-1 : 0] tuser;

endinterface
