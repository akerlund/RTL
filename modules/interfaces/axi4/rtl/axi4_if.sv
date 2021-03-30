////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
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
// Without the following signals:
//  logic                      awlock;
//  logic              [3 : 0] awcache;
//  logic              [2 : 0] awprot;
//  logic              [3 : 0] awqos;
//  logic              [3 : 0] awregion;
//  logic [USER_WIDTH_P-1 : 0] awuser;
//  logic [USER_WIDTH_P-1 : 0] wuser;
//  logic [USER_WIDTH_P-1 : 0] buser;
//  logic              [1 : 0] arburst;
//  logic                      arlock;
//  logic              [3 : 0] arcache;
//  logic              [2 : 0] arprot;
//  logic              [3 : 0] arqos;
//  logic              [3 : 0] arregion;
//  logic [USER_WIDTH_P-1 : 0] aruser;
//  logic [USER_WIDTH_P-1 : 0] ruser;
//
////////////////////////////////////////////////////////////////////////////////

interface axi4_if #(
    parameter int ID_WIDTH_P   = -1,
    parameter int ADDR_WIDTH_P = -1,
    parameter int DATA_WIDTH_P = -1,
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
    input  arvalid,
    output arready,
    output rid,
    output rdata,
    output rresp,
    output rlast,
    output rvalid,
    input  rready
  );

endinterface
