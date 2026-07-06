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
  localparam int NR_OF_MASTERS_C  = 4;
  localparam int NR_OF_SLAVES_C   = 1;

  logic                                                   clk;
  logic                                                   rst_n;
  logic [NR_OF_MASTERS_C-1 : 0]   [AXI_ID_WIDTH_C-1 : 0]  mst_arid;
  logic [NR_OF_MASTERS_C-1 : 0] [AXI_ADDR_WIDTH_C-1 : 0]  mst_araddr;
  logic [NR_OF_MASTERS_C-1 : 0]                  [7 : 0]  mst_arlen;
  logic [NR_OF_MASTERS_C-1 : 0]                  [2 : 0]  mst_arsize;
  logic [NR_OF_MASTERS_C-1 : 0]                  [1 : 0]  mst_arburst;
  logic [NR_OF_MASTERS_C-1 : 0]                  [3 : 0]  mst_arregion;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_arvalid;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_arready;
  logic                            [AXI_ID_WIDTH_C-1 : 0] mst_rid;
  logic                                           [1 : 0] mst_rresp;
  logic                          [AXI_DATA_WIDTH_C-1 : 0] mst_rdata;
  logic                                                   mst_rlast;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_rvalid;
  logic [NR_OF_MASTERS_C-1 : 0]                           mst_rready;
  logic                            [AXI_ID_WIDTH_C-1 : 0] slv_arid;
  logic                          [AXI_ADDR_WIDTH_C-1 : 0] slv_araddr;
  logic                                           [7 : 0] slv_arlen;
  logic                                           [2 : 0] slv_arsize;
  logic                                           [1 : 0] slv_arburst;
  logic                                           [3 : 0] slv_arregion;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_arvalid;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_arready;
  logic [NR_OF_SLAVES_C-1 : 0]     [AXI_ID_WIDTH_C-1 : 0] slv_rid;
  logic [NR_OF_SLAVES_C-1 : 0]                    [1 : 0] slv_rresp;
  logic [NR_OF_SLAVES_C-1 : 0]   [AXI_DATA_WIDTH_C-1 : 0] slv_rdata;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_rlast;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_rvalid;
  logic [NR_OF_SLAVES_C-1 : 0]                            slv_rready;

  localparam int M2S_NR_OF_SLAVES_C = 2;

  logic                            [AXI_ID_WIDTH_C-1 : 0] m2s_mst_arid;
  logic                          [AXI_ADDR_WIDTH_C-1 : 0] m2s_mst_araddr;
  logic                                           [7 : 0] m2s_mst_arlen;
  logic                                           [2 : 0] m2s_mst_arsize;
  logic                                           [1 : 0] m2s_mst_arburst;
  logic                                           [3 : 0] m2s_mst_arregion;
  logic                                                   m2s_mst_arvalid;
  logic                                                   m2s_mst_arready;
  logic                            [AXI_ID_WIDTH_C-1 : 0] m2s_mst_rid;
  logic                                           [1 : 0] m2s_mst_rresp;
  logic                          [AXI_DATA_WIDTH_C-1 : 0] m2s_mst_rdata;
  logic                                                   m2s_mst_rlast;
  logic                                                   m2s_mst_rvalid;
  logic                                                   m2s_mst_rready;
  logic                            [AXI_ID_WIDTH_C-1 : 0] m2s_slv_arid;
  logic                          [AXI_ADDR_WIDTH_C-1 : 0] m2s_slv_araddr;
  logic                                           [7 : 0] m2s_slv_arlen;
  logic                                           [2 : 0] m2s_slv_arsize;
  logic                                           [1 : 0] m2s_slv_arburst;
  logic                                           [3 : 0] m2s_slv_arregion;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_arvalid;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_arready;
  logic [M2S_NR_OF_SLAVES_C-1 : 0] [AXI_ID_WIDTH_C-1 : 0] m2s_slv_rid;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                [1 : 0] m2s_slv_rresp;
  logic [M2S_NR_OF_SLAVES_C-1 : 0] [AXI_DATA_WIDTH_C-1 : 0] m2s_slv_rdata;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_rlast;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_rvalid;
  logic [M2S_NR_OF_SLAVES_C-1 : 0]                        m2s_slv_rready;

  axi4_read_arbiter #(
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .AXI_ADDR_WIDTH_P ( AXI_ADDR_WIDTH_C ),
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .NR_OF_MASTERS_P  ( NR_OF_MASTERS_C  ),
    .NR_OF_SLAVES_P   ( NR_OF_SLAVES_C   )
  ) dut (
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .mst_arid    ( mst_arid    ),
    .mst_araddr  ( mst_araddr  ),
    .mst_arlen   ( mst_arlen   ),
    .mst_arsize  ( mst_arsize  ),
    .mst_arburst ( mst_arburst ),
    .mst_arregion( mst_arregion),
    .mst_arvalid ( mst_arvalid ),
    .mst_arready ( mst_arready ),
    .mst_rid     ( mst_rid     ),
    .mst_rresp   ( mst_rresp   ),
    .mst_rdata   ( mst_rdata   ),
    .mst_rlast   ( mst_rlast   ),
    .mst_rvalid  ( mst_rvalid  ),
    .mst_rready  ( mst_rready  ),
    .slv_arid    ( slv_arid    ),
    .slv_araddr  ( slv_araddr  ),
    .slv_arlen   ( slv_arlen   ),
    .slv_arsize  ( slv_arsize  ),
    .slv_arburst ( slv_arburst ),
    .slv_arregion( slv_arregion),
    .slv_arvalid ( slv_arvalid ),
    .slv_arready ( slv_arready ),
    .slv_rid     ( slv_rid     ),
    .slv_rresp   ( slv_rresp   ),
    .slv_rdata   ( slv_rdata   ),
    .slv_rlast   ( slv_rlast   ),
    .slv_rvalid  ( slv_rvalid  ),
    .slv_rready  ( slv_rready  )
  );

  axi4_read_arbiter #(
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C       ),
    .AXI_ADDR_WIDTH_P ( AXI_ADDR_WIDTH_C     ),
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C     ),
    .NR_OF_MASTERS_P  ( 1                    ),
    .NR_OF_SLAVES_P   ( M2S_NR_OF_SLAVES_C   )
  ) dut_mst_2_slvs (
    .clk         ( clk              ),
    .rst_n       ( rst_n            ),
    .mst_arid    ( m2s_mst_arid     ),
    .mst_araddr  ( m2s_mst_araddr   ),
    .mst_arlen   ( m2s_mst_arlen    ),
    .mst_arsize  ( m2s_mst_arsize   ),
    .mst_arburst ( m2s_mst_arburst  ),
    .mst_arregion( m2s_mst_arregion ),
    .mst_arvalid ( m2s_mst_arvalid  ),
    .mst_arready ( m2s_mst_arready  ),
    .mst_rid     ( m2s_mst_rid      ),
    .mst_rresp   ( m2s_mst_rresp    ),
    .mst_rdata   ( m2s_mst_rdata    ),
    .mst_rlast   ( m2s_mst_rlast    ),
    .mst_rvalid  ( m2s_mst_rvalid   ),
    .mst_rready  ( m2s_mst_rready   ),
    .slv_arid    ( m2s_slv_arid     ),
    .slv_araddr  ( m2s_slv_araddr   ),
    .slv_arlen   ( m2s_slv_arlen    ),
    .slv_arsize  ( m2s_slv_arsize   ),
    .slv_arburst ( m2s_slv_arburst  ),
    .slv_arregion( m2s_slv_arregion ),
    .slv_arvalid ( m2s_slv_arvalid  ),
    .slv_arready ( m2s_slv_arready  ),
    .slv_rid     ( m2s_slv_rid      ),
    .slv_rresp   ( m2s_slv_rresp    ),
    .slv_rdata   ( m2s_slv_rdata    ),
    .slv_rlast   ( m2s_slv_rlast    ),
    .slv_rvalid  ( m2s_slv_rvalid   ),
    .slv_rready  ( m2s_slv_rready   )
  );

endmodule

`default_nettype wire
