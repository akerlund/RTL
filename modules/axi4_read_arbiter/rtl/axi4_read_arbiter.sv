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

module axi4_read_arbiter #(
  parameter int AXI_ID_WIDTH_P   = -1,
  parameter int AXI_ADDR_WIDTH_P = -1,
  parameter int AXI_DATA_WIDTH_P = -1,
  parameter int NR_OF_MASTERS_P  = -1,
  parameter int NR_OF_SLAVES_P   = -1
)(

    // Clock and reset
    input  wire                                                   clk,
    input  wire                                                   rst_n,

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Read Address Channel
    input  wire  [NR_OF_MASTERS_P-1 : 0]   [AXI_ID_WIDTH_P-1 : 0] mst_arid,
    input  wire  [NR_OF_MASTERS_P-1 : 0] [AXI_ADDR_WIDTH_P-1 : 0] mst_araddr,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                  [7 : 0] mst_arlen,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                  [2 : 0] mst_arsize,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                  [1 : 0] mst_arburst,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                  [3 : 0] mst_arregion,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                          mst_arvalid,
    output logic [NR_OF_MASTERS_P-1 : 0]                          mst_arready,

    // Read Data Channel
    output logic                           [AXI_ID_WIDTH_P-1 : 0] mst_rid,
    output logic                                          [1 : 0] mst_rresp,
    output logic                         [AXI_DATA_WIDTH_P-1 : 0] mst_rdata,
    output logic                                                  mst_rlast,
    output logic [NR_OF_MASTERS_P-1 : 0]                          mst_rvalid,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                          mst_rready,

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Read Address Channel
    output logic                           [AXI_ID_WIDTH_P-1 : 0] slv_arid,
    output logic                         [AXI_ADDR_WIDTH_P-1 : 0] slv_araddr,
    output logic                                          [7 : 0] slv_arlen,
    output logic                                          [2 : 0] slv_arsize,
    output logic                                          [1 : 0] slv_arburst,
    output logic                                          [3 : 0] slv_arregion,
    output logic [NR_OF_SLAVES_P-1 : 0]                           slv_arvalid,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                           slv_arready,

    // Read Data Channel
    input  wire  [NR_OF_SLAVES_P-1 : 0]    [AXI_ID_WIDTH_P-1 : 0] slv_rid,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                   [1 : 0] slv_rresp,
    input  wire  [NR_OF_SLAVES_P-1 : 0]  [AXI_DATA_WIDTH_P-1 : 0] slv_rdata,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                           slv_rlast,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                           slv_rvalid,
    output logic [NR_OF_SLAVES_P-1 : 0]                           slv_rready
  );

  initial begin
    if (AXI_ID_WIDTH_P <= 0) begin
      $fatal(1, "AXI_ID_WIDTH_P must be greater than zero");
    end
    if (AXI_ADDR_WIDTH_P <= 0) begin
      $fatal(1, "AXI_ADDR_WIDTH_P must be greater than zero");
    end
    if (AXI_DATA_WIDTH_P <= 0) begin
      $fatal(1, "AXI_DATA_WIDTH_P must be greater than zero");
    end
    if (NR_OF_MASTERS_P <= 0 || NR_OF_SLAVES_P <= 0) begin
      $fatal(1, "NR_OF_MASTERS_P and NR_OF_SLAVES_P must be greater than zero");
    end
    if (NR_OF_MASTERS_P > 1 && NR_OF_SLAVES_P > 1) begin
      $fatal(1, "axi4_read_arbiter supports one master to many slaves or many masters to one slave");
    end
  end

  generate
  if (NR_OF_MASTERS_P == 1) begin : gen_mst_to_slvs

    axi4_read_arbiter_mst_2_slvs #(
      .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
      .AXI_ADDR_WIDTH_P ( AXI_ADDR_WIDTH_P ),
      .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
      .NR_OF_SLAVES_P   ( NR_OF_SLAVES_P   )
    ) axi4_read_arbiter_mst_2_slvs_i0 (

      // Clock and reset
      .clk              ( clk              ), // input
      .rst_n            ( rst_n            ), // input

      // -------------------------------------------------------------------------
      // AXI4 Masters
      // -------------------------------------------------------------------------

      // Read Address Channel
      .mst_arid         ( mst_arid         ), // input
      .mst_araddr       ( mst_araddr       ), // input
      .mst_arlen        ( mst_arlen        ), // input
      .mst_arsize       ( mst_arsize       ), // input
      .mst_arburst      ( mst_arburst      ), // input
      .mst_arregion     ( mst_arregion     ), // input
      .mst_arvalid      ( mst_arvalid      ), // input
      .mst_arready      ( mst_arready      ), // output

      // Read Data Channel
      .mst_rid          ( mst_rid          ), // output
      .mst_rresp        ( mst_rresp        ), // output
      .mst_rdata        ( mst_rdata        ), // output
      .mst_rlast        ( mst_rlast        ), // output
      .mst_rvalid       ( mst_rvalid       ), // output
      .mst_rready       ( mst_rready       ), // input

      // -------------------------------------------------------------------------
      // AXI4 Slave
      // -------------------------------------------------------------------------

      // Read Address Channel
      .slv_arid         ( slv_arid         ), // output
      .slv_araddr       ( slv_araddr       ), // output
      .slv_arlen        ( slv_arlen        ), // output
      .slv_arsize       ( slv_arsize       ), // output
      .slv_arburst      ( slv_arburst      ), // output
      .slv_arregion     ( slv_arregion     ), // output
      .slv_arvalid      ( slv_arvalid      ), // output
      .slv_arready      ( slv_arready      ), // input

      // Read Data Channel
      .slv_rid          ( slv_rid          ), // input
      .slv_rresp        ( slv_rresp        ), // input
      .slv_rdata        ( slv_rdata        ), // input
      .slv_rlast        ( slv_rlast        ), // input
      .slv_rvalid       ( slv_rvalid       ), // input
      .slv_rready       ( slv_rready       )  // output
    );

  end
  else begin : gen_msts_to_slv

    axi4_read_arbiter_msts_2_slv #(
      .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_P   ),
      .AXI_ADDR_WIDTH_P ( AXI_ADDR_WIDTH_P ),
      .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_P ),
      .NR_OF_MASTERS_P  ( NR_OF_MASTERS_P  )
    ) axi4_read_arbiter_msts_2_slv_i0 (

      // Clock and reset
      .clk              ( clk              ), // input
      .rst_n            ( rst_n            ), // input

      // -------------------------------------------------------------------------
      // AXI4 Masters
      // -------------------------------------------------------------------------

      // Read Address Channel
      .mst_arid         ( mst_arid         ), // input
      .mst_araddr       ( mst_araddr       ), // input
      .mst_arlen        ( mst_arlen        ), // input
      .mst_arsize       ( mst_arsize       ), // input
      .mst_arburst      ( mst_arburst      ), // input
      .mst_arregion     ( mst_arregion     ), // input
      .mst_arvalid      ( mst_arvalid      ), // input
      .mst_arready      ( mst_arready      ), // output

      // Read Data Channel
      .mst_rid          ( mst_rid          ), // output
      .mst_rresp        ( mst_rresp        ), // output
      .mst_rdata        ( mst_rdata        ), // output
      .mst_rlast        ( mst_rlast        ), // output
      .mst_rvalid       ( mst_rvalid       ), // output
      .mst_rready       ( mst_rready       ), // input

      // -------------------------------------------------------------------------
      // AXI4 Slave
      // -------------------------------------------------------------------------

      // Read Address Channel
      .slv_arid         ( slv_arid         ), // output
      .slv_araddr       ( slv_araddr       ), // output
      .slv_arlen        ( slv_arlen        ), // output
      .slv_arsize       ( slv_arsize       ), // output
      .slv_arburst      ( slv_arburst      ), // output
      .slv_arregion     ( slv_arregion     ), // output
      .slv_arvalid      ( slv_arvalid      ), // output
      .slv_arready      ( slv_arready      ), // input

      // Read Data Channel
      .slv_rid          ( slv_rid          ), // input
      .slv_rresp        ( slv_rresp        ), // input
      .slv_rdata        ( slv_rdata        ), // input
      .slv_rlast        ( slv_rlast        ), // input
      .slv_rvalid       ( slv_rvalid       ), // input
      .slv_rready       ( slv_rready       )  // output
    );

  end
  endgenerate

endmodule

`default_nettype wire
