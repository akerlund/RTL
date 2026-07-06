////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

module tb_top #(
    parameter int AXI_DATA_WIDTH_P = 16,
    parameter int AXI_STRB_WIDTH_P = 2,
    parameter int AXI_KEEP_WIDTH_P = 2,
    parameter int AXI_ID_WIDTH_P   = 2,
    parameter int AXI_DEST_WIDTH_P = 2,
    parameter int AXI_USER_WIDTH_P = 1
  )(
    input  wire clk,
    input  wire rst_n,

    input  wire                          slv_tvalid,
    output wire                          slv_tready,
    input  wire [AXI_DATA_WIDTH_P-1 : 0] slv_tdata,
    input  wire [AXI_STRB_WIDTH_P-1 : 0] slv_tstrb,
    input  wire [AXI_KEEP_WIDTH_P-1 : 0] slv_tkeep,
    input  wire                          slv_tlast,
    input  wire   [AXI_ID_WIDTH_P-1 : 0] slv_tid,
    input  wire [AXI_DEST_WIDTH_P-1 : 0] slv_tdest,
    input  wire [AXI_USER_WIDTH_P-1 : 0] slv_tuser,

    output wire                          mst0_tvalid,
    input  wire                          mst0_tready,
    output wire [AXI_DATA_WIDTH_P-1 : 0] mst0_tdata,
    output wire [AXI_STRB_WIDTH_P-1 : 0] mst0_tstrb,
    output wire [AXI_KEEP_WIDTH_P-1 : 0] mst0_tkeep,
    output wire                          mst0_tlast,
    output wire   [AXI_ID_WIDTH_P-1 : 0] mst0_tid,
    output wire [AXI_DEST_WIDTH_P-1 : 0] mst0_tdest,
    output wire [AXI_USER_WIDTH_P-1 : 0] mst0_tuser,

    output wire                          mst1_tvalid,
    input  wire                          mst1_tready,
    output wire [AXI_DATA_WIDTH_P-1 : 0] mst1_tdata,
    output wire [AXI_STRB_WIDTH_P-1 : 0] mst1_tstrb,
    output wire [AXI_KEEP_WIDTH_P-1 : 0] mst1_tkeep,
    output wire                          mst1_tlast,
    output wire   [AXI_ID_WIDTH_P-1 : 0] mst1_tid,
    output wire [AXI_DEST_WIDTH_P-1 : 0] mst1_tdest,
    output wire [AXI_USER_WIDTH_P-1 : 0] mst1_tuser,

    output wire                          mst2_tvalid,
    input  wire                          mst2_tready,
    output wire [AXI_DATA_WIDTH_P-1 : 0] mst2_tdata,
    output wire [AXI_STRB_WIDTH_P-1 : 0] mst2_tstrb,
    output wire [AXI_KEEP_WIDTH_P-1 : 0] mst2_tkeep,
    output wire                          mst2_tlast,
    output wire   [AXI_ID_WIDTH_P-1 : 0] mst2_tid,
    output wire [AXI_DEST_WIDTH_P-1 : 0] mst2_tdest,
    output wire [AXI_USER_WIDTH_P-1 : 0] mst2_tuser
  );

  localparam int NR_OF_MASTERS_C = 3;

  wire [NR_OF_MASTERS_C-1 : 0] mst_tvalid;
  wire [NR_OF_MASTERS_C-1 : 0] mst_tready;
  wire [AXI_DATA_WIDTH_P-1 : 0] mst_tdata;
  wire [AXI_STRB_WIDTH_P-1 : 0] mst_tstrb;
  wire [AXI_KEEP_WIDTH_P-1 : 0] mst_tkeep;
  wire                          mst_tlast;
  wire   [AXI_ID_WIDTH_P-1 : 0] mst_tid;
  wire [AXI_DEST_WIDTH_P-1 : 0] mst_tdest;
  wire [AXI_USER_WIDTH_P-1 : 0] mst_tuser;

  assign mst0_tvalid  = mst_tvalid[0];
  assign mst_tready[0] = mst0_tready;
  assign mst1_tvalid  = mst_tvalid[1];
  assign mst_tready[1] = mst1_tready;
  assign mst2_tvalid  = mst_tvalid[2];
  assign mst_tready[2] = mst2_tready;

  assign mst0_tdata = mst_tdata;
  assign mst1_tdata = mst_tdata;
  assign mst2_tdata = mst_tdata;
  assign mst0_tstrb = mst_tstrb;
  assign mst1_tstrb = mst_tstrb;
  assign mst2_tstrb = mst_tstrb;
  assign mst0_tkeep = mst_tkeep;
  assign mst1_tkeep = mst_tkeep;
  assign mst2_tkeep = mst_tkeep;
  assign mst0_tlast = mst_tlast;
  assign mst1_tlast = mst_tlast;
  assign mst2_tlast = mst_tlast;
  assign mst0_tid   = mst_tid;
  assign mst1_tid   = mst_tid;
  assign mst2_tid   = mst_tid;
  assign mst0_tdest = mst_tdest;
  assign mst1_tdest = mst_tdest;
  assign mst2_tdest = mst_tdest;
  assign mst0_tuser = mst_tuser;
  assign mst1_tuser = mst_tuser;
  assign mst2_tuser = mst_tuser;

  axi4s_s2m_arbiter #(
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
    .slv_tvalid ( slv_tvalid ),
    .slv_tready ( slv_tready ),
    .slv_tdata  ( slv_tdata  ),
    .slv_tstrb  ( slv_tstrb  ),
    .slv_tkeep  ( slv_tkeep  ),
    .slv_tlast  ( slv_tlast  ),
    .slv_tid    ( slv_tid    ),
    .slv_tdest  ( slv_tdest  ),
    .slv_tuser  ( slv_tuser  ),
    .mst_tvalid ( mst_tvalid ),
    .mst_tready ( mst_tready ),
    .mst_tdata  ( mst_tdata  ),
    .mst_tstrb  ( mst_tstrb  ),
    .mst_tkeep  ( mst_tkeep  ),
    .mst_tlast  ( mst_tlast  ),
    .mst_tid    ( mst_tid    ),
    .mst_tdest  ( mst_tdest  ),
    .mst_tuser  ( mst_tuser  )
  );

endmodule
