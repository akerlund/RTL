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

interface axi4_if #(
    parameter int ID_WIDTH_P   = 1,
    parameter int ADDR_WIDTH_P = 1,
    parameter int DATA_WIDTH_P = 8,
    parameter int STRB_WIDTH_P = DATA_WIDTH_P/8
  );

  // Write Address Channel
  logic   [ID_WIDTH_P-1 : 0] awid;
  logic [ADDR_WIDTH_P-1 : 0] awaddr;
  logic              [7 : 0] awlen;
  logic              [2 : 0] awsize;
  logic              [1 : 0] awburst;
  logic                      awvalid;
  logic                      awready;

  // Write Data Channel
  logic [DATA_WIDTH_P-1 : 0] wdata;
  logic [STRB_WIDTH_P-1 : 0] wstrb;
  logic                      wlast;
  logic                      wvalid;
  logic                      wready;

  // Write Response Channel
  logic   [ID_WIDTH_P-1 : 0] bid;
  logic              [1 : 0] bresp;
  logic                      bvalid;
  logic                      bready;

  // Read Address Channel
  logic   [ID_WIDTH_P-1 : 0] arid;
  logic [ADDR_WIDTH_P-1 : 0] araddr;
  logic              [7 : 0] arlen;
  logic              [2 : 0] arsize;
  logic              [1 : 0] arburst;
  logic                      arvalid;
  logic                      arready;

  // Read Data Channel
  logic   [ID_WIDTH_P-1 : 0] rid;
  logic [DATA_WIDTH_P-1 : 0] rdata;
  logic              [1 : 0] rresp;
  logic                      rlast;
  logic                      rvalid;
  logic                      rready;

  modport master(
    output awid,
    output awaddr,
    output awlen,
    output awsize,
    output awburst,
    output awvalid,
    input  awready,
    output wdata,
    output wstrb,
    output wlast,
    output wvalid,
    input  wready,
    input  bid,
    input  bresp,
    input  bvalid,
    output bready,
    output arid,
    output araddr,
    output arlen,
    output arsize,
    output arburst,
    output arvalid,
    input  arready,
    input  rid,
    input  rdata,
    input  rresp,
    input  rlast,
    input  rvalid,
    output rready
  );

  modport slave(
    input  awid,
    input  awaddr,
    input  awlen,
    input  awsize,
    input  awburst,
    input  awvalid,
    output awready,
    input  wdata,
    input  wstrb,
    input  wlast,
    input  wvalid,
    output wready,
    output bid,
    output bresp,
    output bvalid,
    input  bready,
    input  arid,
    input  araddr,
    input  arlen,
    input  arsize,
    input  arburst,
    input  arvalid,
    output arready,
    output rid,
    output rdata,
    output rresp,
    output rlast,
    output rvalid,
    input  rready
  );

  modport monitor(
    input awid,
    input awaddr,
    input awlen,
    input awsize,
    input awburst,
    input awvalid,
    input awready,
    input wdata,
    input wstrb,
    input wlast,
    input wvalid,
    input wready,
    input bid,
    input bresp,
    input bvalid,
    input bready,
    input arid,
    input araddr,
    input arlen,
    input arsize,
    input arburst,
    input arvalid,
    input arready,
    input rid,
    input rdata,
    input rresp,
    input rlast,
    input rvalid,
    input rready
  );

  initial begin
    if (ID_WIDTH_P <= 0 || ADDR_WIDTH_P <= 0 || DATA_WIDTH_P <= 0 || STRB_WIDTH_P <= 0) begin
      $error("AXI4 interface widths must be greater than zero");
    end

    if (DATA_WIDTH_P % 8 != 0) begin
      $error("DATA_WIDTH_P must be a whole number of bytes");
    end
  end

endinterface
