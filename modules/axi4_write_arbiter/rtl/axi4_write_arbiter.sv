////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
//
// If the parameter "NR_OF_MASTERS_P" is equal to one then an
// "axi4_write_arbiter_mst_2_slvs" will be instantiated, i.e., one master
// connected to (NR_OF_SLAVES_P) slaves.
//
// If the parameter "NR_OF_MASTERS_P" is NOT equal to one then a
// "axi4_write_arbiter_msts_2_slv" will be instantiated, i.e.,
// (NR_OF_MASTERS_P) masters is connected to one slave.
//
///////////////////////////////////////////////////////////////////////////////

`default_nettype none

module axi4_write_arbiter #(
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI_ADDR_WIDTH_P = -1,
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_STRB_WIDTH_P = -1,
    parameter int NR_OF_MASTERS_P  =  1,
    parameter int NR_OF_SLAVES_P   = -1
  )(

    // Clock and reset
    input  wire                                                  clk,
    input  wire                                                  rst_n,

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Write Address Channel
    input  wire  [NR_OF_MASTERS_P-1 : 0]   [AXI_ID_WIDTH_P-1 : 0] mst_awid,
    input  wire  [NR_OF_MASTERS_P-1 : 0] [AXI_ADDR_WIDTH_P-1 : 0] mst_awaddr,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                  [7 : 0] mst_awlen,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                  [2 : 0] mst_awsize,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                  [1 : 0] mst_awburst,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                  [3 : 0] mst_awregion,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                          mst_awvalid,
    output logic [NR_OF_MASTERS_P-1 : 0]                          mst_awready,

    // Write Data Channel
    input  wire  [NR_OF_MASTERS_P-1 : 0] [AXI_DATA_WIDTH_P-1 : 0] mst_wdata,
    input  wire  [NR_OF_MASTERS_P-1 : 0] [AXI_STRB_WIDTH_P-1 : 0] mst_wstrb,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                          mst_wlast,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                          mst_wvalid,
    output logic [NR_OF_MASTERS_P-1 : 0]                          mst_wready,

    // Write Response Channel
    output logic                           [AXI_ID_WIDTH_P-1 : 0] mst_bid,
    output logic                                          [1 : 0] mst_bresp,
    output logic [NR_OF_MASTERS_P-1 : 0]                          mst_bvalid,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                          mst_bready,

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Write Address Channel
    output logic                           [AXI_ID_WIDTH_P-1 : 0] slv_awid,
    output logic                         [AXI_ADDR_WIDTH_P-1 : 0] slv_awaddr,
    output logic                                          [7 : 0] slv_awlen,
    output logic                                          [2 : 0] slv_awsize,
    output logic                                          [1 : 0] slv_awburst,
    output logic                                          [3 : 0] slv_awregion,
    output logic  [NR_OF_SLAVES_P-1 : 0]                          slv_awvalid,
    input  wire   [NR_OF_SLAVES_P-1 : 0]                          slv_awready,

    // Write Data Channel
    output logic                         [AXI_DATA_WIDTH_P-1 : 0] slv_wdata,
    output logic                         [AXI_STRB_WIDTH_P-1 : 0] slv_wstrb,
    output logic                                                  slv_wlast,
    output logic  [NR_OF_SLAVES_P-1 : 0]                          slv_wvalid,
    input  wire   [NR_OF_SLAVES_P-1 : 0]                          slv_wready,

    // Write Response Channel
    input  wire   [NR_OF_SLAVES_P-1 : 0]   [AXI_ID_WIDTH_P-1 : 0] slv_bid,
    input  wire   [NR_OF_SLAVES_P-1 : 0]                  [1 : 0] slv_bresp,
    input  wire   [NR_OF_SLAVES_P-1 : 0]                          slv_bvalid,
    output logic                           [NR_OF_SLAVES_P-1 : 0] slv_bready
  );


  generate
  if (NR_OF_MASTERS_P == 1) begin

    axi4_write_arbiter_mst_2_slvs #(
      .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
      .AXI_ADDR_WIDTH_P ( AXI_ADDR_WIDTH_P ),
      .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
      .AXI_STRB_WIDTH_P ( AXI_STRB_WIDTH_P ),
      .NR_OF_SLAVES_P   ( NR_OF_SLAVES_P   )
    ) axi4_write_arbiter_mst_2_slvs_i0 (

      // Clock and reset
      .clk              ( clk              ), // input
      .rst_n            ( rst_n            ), // input

      // -----------------------------------------------------------------------
      // AXI4 Master
      // -----------------------------------------------------------------------

      // Write Address Channel
      .mst_awid         ( mst_awid         ), // input
      .mst_awaddr       ( mst_awaddr       ), // input
      .mst_awlen        ( mst_awlen        ), // input
      .mst_awsize       ( mst_awsize       ), // input
      .mst_awburst      ( mst_awburst      ), // input
      .mst_awregion     ( mst_awregion     ), // input
      .mst_awvalid      ( mst_awvalid      ), // input
      .mst_awready      ( mst_awready      ), // output

      // Write Data Channel
      .mst_wdata        ( mst_wdata        ), // input
      .mst_wstrb        ( mst_wstrb        ), // input
      .mst_wlast        ( mst_wlast        ), // input
      .mst_wvalid       ( mst_wvalid       ), // input
      .mst_wready       ( mst_wready       ), // output

      // Write Response Channel
      .mst_bid          ( mst_bid          ), // output
      .mst_bresp        ( mst_bresp        ), // output
      .mst_bvalid       ( mst_bvalid       ), // output
      .mst_bready       ( mst_bready       ), // input

      // -----------------------------------------------------------------------
      // AXI4 Slaves
      // -----------------------------------------------------------------------

      // Write Address Channel
      .slv_awid         ( slv_awid         ), // output
      .slv_awaddr       ( slv_awaddr       ), // output
      .slv_awlen        ( slv_awlen        ), // output
      .slv_awsize       ( slv_awsize       ), // output
      .slv_awburst      ( slv_awburst      ), // output
      .slv_awregion     ( slv_awregion     ), // output
      .slv_awvalid      ( slv_awvalid      ), // output
      .slv_awready      ( slv_awready      ), // input

      // Write Data Channel
      .slv_wdata        ( slv_wdata        ), // output
      .slv_wstrb        ( slv_wstrb        ), // output
      .slv_wlast        ( slv_wlast        ), // output
      .slv_wvalid       ( slv_wvalid       ), // output
      .slv_wready       ( slv_wready       ), // input

      // Write Response Channel
      .slv_bid          ( slv_bid          ), // input
      .slv_bresp        ( slv_bresp        ), // input
      .slv_bvalid       ( slv_bvalid       ), // input
      .slv_bready       ( slv_bready       )  // output
    );

  end
  else begin

    axi4_write_arbiter_msts_2_slv #(
      .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
      .AXI_ADDR_WIDTH_P ( AXI_ADDR_WIDTH_P ),
      .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
      .AXI_STRB_WIDTH_P ( AXI_STRB_WIDTH_P ),
      .NR_OF_MASTERS_P  ( NR_OF_MASTERS_P  )
    ) axi4_write_arbiter_msts_2_slv_i0 (

      // Clock and reset
      .clk              ( clk              ), // input
      .rst_n            ( rst_n            ), // input

      // -----------------------------------------------------------------------
      // AXI4 Masters
      // -----------------------------------------------------------------------

      // Write Address Channel
      .mst_awid         ( mst_awid         ), // input
      .mst_awaddr       ( mst_awaddr       ), // input
      .mst_awlen        ( mst_awlen        ), // input
      .mst_awsize       ( mst_awsize       ), // input
      .mst_awburst      ( mst_awburst      ), // input
      .mst_awregion     ( mst_awregion     ), // input
      .mst_awvalid      ( mst_awvalid      ), // input
      .mst_awready      ( mst_awready      ), // output

      // Write Data Channel
      .mst_wdata        ( mst_wdata        ), // input
      .mst_wstrb        ( mst_wstrb        ), // input
      .mst_wlast        ( mst_wlast        ), // input
      .mst_wvalid       ( mst_wvalid       ), // input
      .mst_wready       ( mst_wready       ), // output

      // Write Response Channel
      .mst_bid          ( mst_bid          ), // output
      .mst_bresp        ( mst_bresp        ), // output
      .mst_bvalid       ( mst_bvalid       ), // output
      .mst_bready       ( mst_bready       ), // input

      // -----------------------------------------------------------------------
      // AXI4 Slave
      // -----------------------------------------------------------------------

      // Write Address Channel
      .slv_awid         ( slv_awid         ), // output
      .slv_awaddr       ( slv_awaddr       ), // output
      .slv_awlen        ( slv_awlen        ), // output
      .slv_awsize       ( slv_awsize       ), // output
      .slv_awburst      ( slv_awburst      ), // output
      .slv_awregion     ( slv_awregion     ), // output
      .slv_awvalid      ( slv_awvalid      ), // output
      .slv_awready      ( slv_awready      ), // input

      // Write Data Channel
      .slv_wdata        ( slv_wdata        ), // output
      .slv_wstrb        ( slv_wstrb        ), // output
      .slv_wlast        ( slv_wlast        ), // output
      .slv_wvalid       ( slv_wvalid       ), // output
      .slv_wready       ( slv_wready       ), // input

      // Write Response Channel
      .slv_bid          ( slv_bid          ), // input
      .slv_bresp        ( slv_bresp        ), // input
      .slv_bvalid       ( slv_bvalid       ), // input
      .slv_bready       ( slv_bready       )  // output
    );

  end
  endgenerate

endmodule

`default_nettype wire
