////////////////////////////////////////////////////////////////////////////////
// cocotb entry point for axi4s_fifo.
//
// The DUT only carries a generic tuser vector (no tdata/tlast of its own) --
// the SV testbench packs {tlast, tdata} into ing_tuser on ingress and unpacks
// egr_tuser back into {tlast, tdata} on egress (see sv/tb/fi_tb_top.sv). This
// wrapper does the same packing/unpacking so the standard AXI4-S cocotb VIP
// (Axi4sBus) can attach to plain mst_*/slv_* signals; tstrb/tkeep/tid/tdest/
// tuser are intentionally absent from this wrapper's ports (Axi4sBus tolerates
// missing signals) since this DUT has no concept of them.
////////////////////////////////////////////////////////////////////////////////

module tb_top #(
    parameter int AXI_DATA_WIDTH_P  = 32,
    parameter int FIFO_ADDR_WIDTH_P = 6,
    parameter int MAX_REG_BYTES_P   = 256
  )(
    input  wire clk,
    input  wire rst_n,

    input  wire                          mst_tvalid,
    output wire                          mst_tready,
    input  wire [AXI_DATA_WIDTH_P-1 : 0] mst_tdata,
    input  wire                          mst_tlast,

    output wire                          slv_tvalid,
    input  wire                          slv_tready,
    output wire [AXI_DATA_WIDTH_P-1 : 0] slv_tdata,
    output wire                          slv_tlast,

    output wire [FIFO_ADDR_WIDTH_P : 0]  sr_fill_level,
    output wire [FIFO_ADDR_WIDTH_P : 0]  sr_max_fill_level,
    output wire                          sr_almost_full
  );

  localparam int TUSER_WIDTH_C = AXI_DATA_WIDTH_P + 1;

  wire [TUSER_WIDTH_C-1 : 0] ing_tuser;
  wire [TUSER_WIDTH_C-1 : 0] egr_tuser;

  assign ing_tuser = {mst_tlast, mst_tdata};
  assign {slv_tlast, slv_tdata} = egr_tuser;

  axi4s_fifo #(
    .TUSER_WIDTH_P        ( TUSER_WIDTH_C        ),
    .ADDR_WIDTH_P         ( FIFO_ADDR_WIDTH_P    ),
    .MAX_REG_BYTES_P      ( MAX_REG_BYTES_P      )
  ) dut (
    .clk                  ( clk                  ),
    .rst_n                ( rst_n                ),
    .ing_tready           ( mst_tready           ),
    .ing_tuser            ( ing_tuser            ),
    .ing_tvalid           ( mst_tvalid           ),
    .egr_tready           ( slv_tready           ),
    .egr_tuser            ( egr_tuser            ),
    .egr_tvalid           ( slv_tvalid           ),
    .sr_fill_level        ( sr_fill_level        ),
    .sr_max_fill_level    ( sr_max_fill_level    ),
    .sr_almost_full       ( sr_almost_full       ),
    .cr_almost_full_level ( '0                   )
  );

endmodule
