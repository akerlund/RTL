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

module axi4_write_arbiter_mst_2_slvs #(
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI_ADDR_WIDTH_P = -1,
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_STRB_WIDTH_P = -1,
    parameter int NR_OF_SLAVES_P   = -1
  )(

    // Clock and reset
    input  wire                                                 clk,
    input  wire                                                 rst_n,

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Write Address Channel
    input  wire                          [AXI_ID_WIDTH_P-1 : 0] mst_awid,
    input  wire                        [AXI_ADDR_WIDTH_P-1 : 0] mst_awaddr,
    input  wire                                         [7 : 0] mst_awlen,
    input  wire                                         [2 : 0] mst_awsize,
    input  wire                                         [1 : 0] mst_awburst,
    input  wire                                         [3 : 0] mst_awregion,
    input  wire                                                 mst_awvalid,
    output logic                                                mst_awready,

    // Write Data Channel
    input  wire                        [AXI_DATA_WIDTH_P-1 : 0] mst_wdata,
    input  wire                        [AXI_STRB_WIDTH_P-1 : 0] mst_wstrb,
    input  wire                                                 mst_wlast,
    input  wire                                                 mst_wvalid,
    output logic                                                mst_wready,

    // Write Response Channel
    output logic                         [AXI_ID_WIDTH_P-1 : 0] mst_bid,
    output logic                                        [1 : 0] mst_bresp,
    output logic                                                mst_bvalid,
    input  wire                                                 mst_bready,

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Write Address Channel
    output logic                         [AXI_ID_WIDTH_P-1 : 0] slv_awid,
    output logic                       [AXI_ADDR_WIDTH_P-1 : 0] slv_awaddr,
    output logic                                        [7 : 0] slv_awlen,
    output logic                                        [2 : 0] slv_awsize,
    output logic                                        [1 : 0] slv_awburst,
    output logic                                        [3 : 0] slv_awregion,
    output logic                         [NR_OF_SLAVES_P-1 : 0] slv_awvalid,
    input  wire                          [NR_OF_SLAVES_P-1 : 0] slv_awready,

    // Write Data Channel
    output logic                       [AXI_DATA_WIDTH_P-1 : 0] slv_wdata,
    output logic                       [AXI_STRB_WIDTH_P-1 : 0] slv_wstrb,
    output logic                                                slv_wlast,
    output logic                         [NR_OF_SLAVES_P-1 : 0] slv_wvalid,
    input  wire                          [NR_OF_SLAVES_P-1 : 0] slv_wready,

    // Write Response Channel
    input  wire  [NR_OF_SLAVES_P-1 : 0]   [AXI_ID_WIDTH_P-1 : 0] slv_bid,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                  [1 : 0] slv_bresp,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                          slv_bvalid,
    output logic                          [NR_OF_SLAVES_P-1 : 0] slv_bready
  );


  localparam int NR_OF_SLAVES_C = $clog2(NR_OF_SLAVES_P);
  localparam bit ALL_REGIONS_VALID_C = NR_OF_SLAVES_P >= 16;
  localparam logic [3 : 0] NR_OF_SLAVES_REGION_C = 4'(NR_OF_SLAVES_P);

  // ---------------------------------------------------------------------------
  // Write Channel signals
  // ---------------------------------------------------------------------------

  typedef enum {
    WAIT_MST_AWVALID_E,
    WAIT_FOR_BVALID_E,
    WAIT_MST_WLAST_E,
    WAIT_ERR_WLAST_E,
    WAIT_ERR_BREADY_E
  } write_state_t;

  write_state_t write_state;

  logic [NR_OF_SLAVES_C-1 : 0] awregion;
  logic [NR_OF_SLAVES_C-1 : 0] current_awregion;
  logic                        current_awregion_valid;
  logic [AXI_ID_WIDTH_P-1 : 0] error_awid;

  assign current_awregion = mst_awregion[NR_OF_SLAVES_C-1 : 0];
  assign current_awregion_valid = ALL_REGIONS_VALID_C || (mst_awregion < NR_OF_SLAVES_REGION_C);


  // ---------------------------------------------------------------------------
  // Port assignments
  // ---------------------------------------------------------------------------

  // AXI4 Write Address Channel
  assign slv_awid     = mst_awid;
  assign slv_awaddr   = mst_awaddr;
  assign slv_awlen    = mst_awlen;
  assign slv_awsize   = mst_awsize;
  assign slv_awburst  = mst_awburst;
  assign slv_awregion = mst_awregion;

  // AXI4 Write Data Channel
  assign slv_wdata = mst_wdata;
  assign slv_wstrb = mst_wstrb;
  assign slv_wlast = mst_wlast;


  // ---------------------------------------------------------------------------
  // Write processes
  // ---------------------------------------------------------------------------

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      write_state <= WAIT_MST_AWVALID_E;
      awregion    <= '0;
      error_awid   <= '0;
    end
    else begin

      case (write_state)

        WAIT_MST_AWVALID_E: begin
          if (mst_awvalid) begin
            if (current_awregion_valid) begin
              write_state <= WAIT_MST_WLAST_E;
              awregion    <= current_awregion;
            end
            else begin
              write_state <= WAIT_ERR_WLAST_E;
              error_awid  <= mst_awid;
            end
          end
        end


        WAIT_MST_WLAST_E: begin
          if (mst_wlast && mst_wvalid && mst_wready) begin
            write_state <= WAIT_FOR_BVALID_E;
          end
        end

        WAIT_ERR_WLAST_E: begin
          if (mst_wlast && mst_wvalid && mst_wready) begin
            write_state <= WAIT_ERR_BREADY_E;
          end
        end


        WAIT_FOR_BVALID_E: begin
          if (mst_bvalid && mst_bready) begin
            write_state <= WAIT_MST_AWVALID_E;
          end
        end

        WAIT_ERR_BREADY_E: begin
          if (mst_bready) begin
            write_state <= WAIT_MST_AWVALID_E;
          end
        end
      endcase
    end
  end


  // MUX
  always_comb begin

    // Write Address Channel
    mst_awready = '0;
    slv_awvalid = '0;

    // Write Data Channel
    mst_wready  = '0;
    slv_wvalid  = '0;

    // Write Response Channel
    mst_bid     = '0;
    mst_bresp   = '0;
    mst_bvalid  = '0;
    slv_bready  = '0;

    if (write_state == WAIT_MST_AWVALID_E && mst_awvalid) begin

      if (current_awregion_valid) begin
        // Write Address Channel
        mst_awready                   = slv_awready[current_awregion];
        slv_awvalid[current_awregion] = mst_awvalid;

        // Write Data Channel
        mst_wready                   = slv_wready [current_awregion];
        slv_wvalid[current_awregion] = mst_wvalid;

        // Write Response Channel
        mst_bid                      = slv_bid    [current_awregion];
        mst_bresp                    = slv_bresp  [current_awregion];
        mst_bvalid                   = slv_bvalid [current_awregion];
        slv_bready[current_awregion] = mst_bready;
      end
      else begin
        mst_awready = '1;
      end

    end else if (write_state != WAIT_MST_AWVALID_E) begin

      if (write_state == WAIT_ERR_WLAST_E) begin
        mst_wready = '1;
      end
      else if (write_state == WAIT_ERR_BREADY_E) begin
        mst_bid    = error_awid;
        mst_bresp  = 2'b11;
        mst_bvalid = '1;
      end
      else begin
        // Write Address Channel
        mst_awready           = slv_awready[awregion];
        slv_awvalid[awregion] = mst_awvalid;

        // Write Data Channel
        mst_wready           = slv_wready [awregion];
        slv_wvalid[awregion] = mst_wvalid;

        // Write Response Channel
        mst_bid              = slv_bid    [awregion];
        mst_bresp            = slv_bresp  [awregion];
        mst_bvalid           = slv_bvalid [awregion];
        slv_bready[awregion] = mst_bready;
      end
    end
  end
endmodule

`default_nettype wire
