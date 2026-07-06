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

module axi4_read_arbiter_mst_2_slvs #(
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI_ADDR_WIDTH_P = -1,
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int NR_OF_SLAVES_P   = -1
  )(

    // Clock and reset
    input  wire                                                  clk,
    input  wire                                                  rst_n,

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Read Address Channel
    input  wire                           [AXI_ID_WIDTH_P-1 : 0] mst_arid,
    input  wire                         [AXI_ADDR_WIDTH_P-1 : 0] mst_araddr,
    input  wire                                          [7 : 0] mst_arlen,
    input  wire                                          [2 : 0] mst_arsize,
    input  wire                                          [1 : 0] mst_arburst,
    input  wire                                          [3 : 0] mst_arregion,
    input  wire                                                  mst_arvalid,
    output logic                                                 mst_arready,

    // Read Data Channel
    output logic                          [AXI_ID_WIDTH_P-1 : 0] mst_rid,
    output logic                                         [1 : 0] mst_rresp,
    output logic                        [AXI_DATA_WIDTH_P-1 : 0] mst_rdata,
    output logic                                                 mst_rlast,
    output logic                                                 mst_rvalid,
    input  wire                                                  mst_rready,

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Read Address Channel
    output logic                          [AXI_ID_WIDTH_P-1 : 0] slv_arid,
    output logic                        [AXI_ADDR_WIDTH_P-1 : 0] slv_araddr,
    output logic                                         [7 : 0] slv_arlen,
    output logic                                         [2 : 0] slv_arsize,
    output logic                                         [1 : 0] slv_arburst,
    output logic                                         [3 : 0] slv_arregion,
    output logic [NR_OF_SLAVES_P-1 : 0]                          slv_arvalid,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                          slv_arready,

    // Read Data Channel
    input  wire  [NR_OF_SLAVES_P-1 : 0]   [AXI_ID_WIDTH_P-1 : 0] slv_rid,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                  [1 : 0] slv_rresp,
    input  wire  [NR_OF_SLAVES_P-1 : 0] [AXI_DATA_WIDTH_P-1 : 0] slv_rdata,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                          slv_rlast,
    input  wire  [NR_OF_SLAVES_P-1 : 0]                          slv_rvalid,
    output logic [NR_OF_SLAVES_P-1 : 0]                          slv_rready
  );

  localparam int NR_OF_SLAVES_C = $clog2(NR_OF_SLAVES_P);
  localparam bit ALL_REGIONS_VALID_C = NR_OF_SLAVES_P >= 16;
  localparam logic [3 : 0] NR_OF_SLAVES_REGION_C = 4'(NR_OF_SLAVES_P);

  typedef enum {
    WAIT_MST_ARVALID_E,
    WAIT_SLV_ARREADY_E,
    WAIT_SLV_RLAST_E,
    WAIT_ERR_RREADY_E
  } read_state_t;

  read_state_t read_state;

  logic [NR_OF_SLAVES_C-1 : 0] arregion;
  logic [NR_OF_SLAVES_C-1 : 0] current_arregion;
  logic                        current_arregion_valid;
  logic [AXI_ID_WIDTH_P-1 : 0] error_arid;

  assign current_arregion = mst_arregion[NR_OF_SLAVES_C-1 : 0];
  assign current_arregion_valid = ALL_REGIONS_VALID_C || (mst_arregion < NR_OF_SLAVES_REGION_C);

  // ---------------------------------------------------------------------------
  // Port assignments
  // ---------------------------------------------------------------------------

  // AXI4 Read Address Channel
  assign slv_arid     = mst_arid;
  assign slv_araddr   = mst_araddr;
  assign slv_arlen    = mst_arlen;
  assign slv_arsize   = mst_arsize;
  assign slv_arburst  = mst_arburst;
  assign slv_arregion = mst_arregion;

  // ---------------------------------------------------------------------------
  // Read process
  // ---------------------------------------------------------------------------

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      read_state <= WAIT_MST_ARVALID_E;
      arregion   <= '0;
      error_arid  <= '0;
    end
    else begin

      case (read_state)

        WAIT_MST_ARVALID_E: begin

          if (mst_arvalid) begin
            if (current_arregion_valid) begin
              arregion <= current_arregion;
              if (slv_arready[current_arregion]) begin
                read_state <= WAIT_SLV_RLAST_E;
              end
              else begin
                read_state <= WAIT_SLV_ARREADY_E;
              end
            end
            else begin
              read_state <= WAIT_ERR_RREADY_E;
              error_arid  <= mst_arid;
            end
          end
        end

        WAIT_SLV_ARREADY_E: begin

          if (mst_arvalid && mst_arready) begin
            read_state <= WAIT_SLV_RLAST_E;
            arregion   <= current_arregion;
          end
        end


        WAIT_SLV_RLAST_E: begin

          if (mst_rlast && mst_rvalid && mst_rready) begin
            read_state <= WAIT_MST_ARVALID_E;
          end
        end

        WAIT_ERR_RREADY_E: begin

          if (mst_rready) begin
            read_state <= WAIT_MST_ARVALID_E;
          end
        end
      endcase
    end
  end


  // MUX
  always_comb begin

    // Read Address Channel
    mst_arready = '0;
    slv_arvalid = '0;

    // Read Data Channel
    mst_rid     = '0;
    mst_rresp   = '0;
    mst_rdata   = '0;
    mst_rlast   = '0;
    mst_rvalid  = '0;
    slv_rready  = '0;

    // A Read Address Channel transaction must have subsequent
    // Data Channel transaction(s)
    if (read_state == WAIT_MST_ARVALID_E && mst_arvalid) begin

      if (current_arregion_valid) begin
        // Read Address Channel
        mst_arready                   = slv_arready[current_arregion];
        slv_arvalid[current_arregion] = mst_arvalid;
      end
      else begin
        mst_arready = '1;
      end

    end else if (read_state == WAIT_SLV_ARREADY_E) begin

      // Read Address Channel
      mst_arready           = slv_arready[arregion];
      slv_arvalid[arregion] = mst_arvalid;
    end else if (read_state == WAIT_SLV_RLAST_E) begin

      // Read Data Channel
      mst_rid              = slv_rid    [arregion];
      mst_rresp            = slv_rresp  [arregion];
      mst_rdata            = slv_rdata  [arregion];
      mst_rlast            = slv_rlast  [arregion];
      mst_rvalid           = slv_rvalid [arregion];
      slv_rready[arregion] = mst_rready;
    end else if (read_state == WAIT_ERR_RREADY_E) begin

      mst_rid     = error_arid;
      mst_rresp   = 2'b11;
      mst_rdata   = '0;
      mst_rlast   = '1;
      mst_rvalid  = '1;
    end
  end
endmodule

`default_nettype wire
