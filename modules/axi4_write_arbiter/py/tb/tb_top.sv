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

`default_nettype none

module tb_top;

  localparam int AXI_ID_WIDTH_C   = 4;
  localparam int AXI_ADDR_WIDTH_C = 16;
  localparam int AXI_DATA_WIDTH_C = 32;
  localparam int AXI_STRB_WIDTH_C = 4;
  localparam int NR_OF_MASTERS_C  = 4;
  localparam int NR_OF_SLAVES_C   = 1;

  logic                                                   clk;
  logic                                                   rst_n;
  logic [NR_OF_MASTERS_C-1 : 0]   [AXI_ID_WIDTH_C-1 : 0]  mst_awid;
  logic [NR_OF_MASTERS_C-1 : 0] [AXI_ADDR_WIDTH_C-1 : 0]  mst_awaddr;
  logic [NR_OF_MASTERS_C-1 : 0]                  [7 : 0]  mst_awlen;
  logic [NR_OF_MASTERS_C-1 : 0]                  [2 : 0]  mst_awsize;
  logic [NR_OF_MASTERS_C-1 : 0]                  [1 : 0]  mst_awburst;
  logic [NR_OF_MASTERS_C-1 : 0]                  [3 : 0]  mst_awregion;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_awvalid;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_awready;
  logic [NR_OF_MASTERS_C-1 : 0] [AXI_DATA_WIDTH_C-1 : 0]  mst_wdata;
  logic [NR_OF_MASTERS_C-1 : 0] [AXI_STRB_WIDTH_C-1 : 0]  mst_wstrb;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_wlast;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_wvalid;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_wready;
  logic                            [AXI_ID_WIDTH_C-1 : 0] mst_bid;
  logic                                           [1 : 0] mst_bresp;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_bvalid;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_bready;
  logic                            [AXI_ID_WIDTH_C-1 : 0] slv_awid;
  logic                          [AXI_ADDR_WIDTH_C-1 : 0] slv_awaddr;
  logic                                           [7 : 0] slv_awlen;
  logic                                           [2 : 0] slv_awsize;
  logic                                           [1 : 0] slv_awburst;
  logic                                           [3 : 0] slv_awregion;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_awvalid;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_awready;
  logic                          [AXI_DATA_WIDTH_C-1 : 0] slv_wdata;
  logic                          [AXI_STRB_WIDTH_C-1 : 0] slv_wstrb;
  logic                                                   slv_wlast;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_wvalid;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_wready;
  logic [NR_OF_SLAVES_C-1 : 0]     [AXI_ID_WIDTH_C-1 : 0] slv_bid;
  logic [NR_OF_SLAVES_C-1 : 0]                    [1 : 0] slv_bresp;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_bvalid;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_bready;

  localparam int M2S_NR_OF_SLAVES_C = 2;

  logic                            [AXI_ID_WIDTH_C-1 : 0] m2s_mst_awid;
  logic                          [AXI_ADDR_WIDTH_C-1 : 0] m2s_mst_awaddr;
  logic                                           [7 : 0] m2s_mst_awlen;
  logic                                           [2 : 0] m2s_mst_awsize;
  logic                                           [1 : 0] m2s_mst_awburst;
  logic                                           [3 : 0] m2s_mst_awregion;
  logic                                                   m2s_mst_awvalid;
  logic                                                   m2s_mst_awready;
  logic                          [AXI_DATA_WIDTH_C-1 : 0] m2s_mst_wdata;
  logic                          [AXI_STRB_WIDTH_C-1 : 0] m2s_mst_wstrb;
  logic                                                   m2s_mst_wlast;
  logic                                                   m2s_mst_wvalid;
  logic                                                   m2s_mst_wready;
  logic                            [AXI_ID_WIDTH_C-1 : 0] m2s_mst_bid;
  logic                                           [1 : 0] m2s_mst_bresp;
  logic                                                   m2s_mst_bvalid;
  logic                                                   m2s_mst_bready;
  logic                            [AXI_ID_WIDTH_C-1 : 0] m2s_slv_awid;
  logic                          [AXI_ADDR_WIDTH_C-1 : 0] m2s_slv_awaddr;
  logic                                           [7 : 0] m2s_slv_awlen;
  logic                                           [2 : 0] m2s_slv_awsize;
  logic                                           [1 : 0] m2s_slv_awburst;
  logic                                           [3 : 0] m2s_slv_awregion;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_awvalid;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_awready;
  logic                          [AXI_DATA_WIDTH_C-1 : 0] m2s_slv_wdata;
  logic                          [AXI_STRB_WIDTH_C-1 : 0] m2s_slv_wstrb;
  logic                                                   m2s_slv_wlast;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_wvalid;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_wready;
  logic [M2S_NR_OF_SLAVES_C-1 : 0] [AXI_ID_WIDTH_C-1 : 0] m2s_slv_bid;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                [1 : 0] m2s_slv_bresp;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_bvalid;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_bready;

  axi4_write_arbiter #(
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .AXI_ADDR_WIDTH_P ( AXI_ADDR_WIDTH_C ),
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_STRB_WIDTH_P ( AXI_STRB_WIDTH_C ),
    .NR_OF_MASTERS_P  ( NR_OF_MASTERS_C  ),
    .NR_OF_SLAVES_P   ( NR_OF_SLAVES_C   )
  ) dut (
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .mst_awid    ( mst_awid    ),
    .mst_awaddr  ( mst_awaddr  ),
    .mst_awlen   ( mst_awlen   ),
    .mst_awsize  ( mst_awsize  ),
    .mst_awburst ( mst_awburst ),
    .mst_awregion( mst_awregion),
    .mst_awvalid ( mst_awvalid ),
    .mst_awready ( mst_awready ),
    .mst_wdata   ( mst_wdata   ),
    .mst_wstrb   ( mst_wstrb   ),
    .mst_wlast   ( mst_wlast   ),
    .mst_wvalid  ( mst_wvalid  ),
    .mst_wready  ( mst_wready  ),
    .mst_bid     ( mst_bid     ),
    .mst_bresp   ( mst_bresp   ),
    .mst_bvalid  ( mst_bvalid  ),
    .mst_bready  ( mst_bready  ),
    .slv_awid    ( slv_awid    ),
    .slv_awaddr  ( slv_awaddr  ),
    .slv_awlen   ( slv_awlen   ),
    .slv_awsize  ( slv_awsize  ),
    .slv_awburst ( slv_awburst ),
    .slv_awregion( slv_awregion),
    .slv_awvalid ( slv_awvalid ),
    .slv_awready ( slv_awready ),
    .slv_wdata   ( slv_wdata   ),
    .slv_wstrb   ( slv_wstrb   ),
    .slv_wlast   ( slv_wlast   ),
    .slv_wvalid  ( slv_wvalid  ),
    .slv_wready  ( slv_wready  ),
    .slv_bid     ( slv_bid     ),
    .slv_bresp   ( slv_bresp   ),
    .slv_bvalid  ( slv_bvalid  ),
    .slv_bready  ( slv_bready  )
  );

  axi4_write_arbiter #(
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C       ),
    .AXI_ADDR_WIDTH_P ( AXI_ADDR_WIDTH_C     ),
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C     ),
    .AXI_STRB_WIDTH_P ( AXI_STRB_WIDTH_C     ),
    .NR_OF_MASTERS_P  ( 1                    ),
    .NR_OF_SLAVES_P   ( M2S_NR_OF_SLAVES_C   )
  ) dut_mst_2_slvs (
    .clk         ( clk              ),
    .rst_n       ( rst_n            ),
    .mst_awid    ( m2s_mst_awid     ),
    .mst_awaddr  ( m2s_mst_awaddr   ),
    .mst_awlen   ( m2s_mst_awlen    ),
    .mst_awsize  ( m2s_mst_awsize   ),
    .mst_awburst ( m2s_mst_awburst  ),
    .mst_awregion( m2s_mst_awregion ),
    .mst_awvalid ( m2s_mst_awvalid  ),
    .mst_awready ( m2s_mst_awready  ),
    .mst_wdata   ( m2s_mst_wdata    ),
    .mst_wstrb   ( m2s_mst_wstrb    ),
    .mst_wlast   ( m2s_mst_wlast    ),
    .mst_wvalid  ( m2s_mst_wvalid   ),
    .mst_wready  ( m2s_mst_wready   ),
    .mst_bid     ( m2s_mst_bid      ),
    .mst_bresp   ( m2s_mst_bresp    ),
    .mst_bvalid  ( m2s_mst_bvalid   ),
    .mst_bready  ( m2s_mst_bready   ),
    .slv_awid    ( m2s_slv_awid     ),
    .slv_awaddr  ( m2s_slv_awaddr   ),
    .slv_awlen   ( m2s_slv_awlen    ),
    .slv_awsize  ( m2s_slv_awsize   ),
    .slv_awburst ( m2s_slv_awburst  ),
    .slv_awregion( m2s_slv_awregion ),
    .slv_awvalid ( m2s_slv_awvalid  ),
    .slv_awready ( m2s_slv_awready  ),
    .slv_wdata   ( m2s_slv_wdata    ),
    .slv_wstrb   ( m2s_slv_wstrb    ),
    .slv_wlast   ( m2s_slv_wlast    ),
    .slv_wvalid  ( m2s_slv_wvalid   ),
    .slv_wready  ( m2s_slv_wready   ),
    .slv_bid     ( m2s_slv_bid      ),
    .slv_bresp   ( m2s_slv_bresp    ),
    .slv_bvalid  ( m2s_slv_bvalid   ),
    .slv_bready  ( m2s_slv_bready   )
  );

endmodule

`default_nettype wire
