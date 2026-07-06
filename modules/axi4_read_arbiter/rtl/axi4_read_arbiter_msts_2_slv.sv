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

module axi4_read_arbiter_msts_2_slv #(
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI_ADDR_WIDTH_P = -1,
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int NR_OF_MASTERS_P  = -1
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
    output logic                                                  slv_arvalid,
    input  wire                                                   slv_arready,

    // Read Data Channel
    input  wire                            [AXI_ID_WIDTH_P-1 : 0] slv_rid,
    input  wire                                           [1 : 0] slv_rresp,
    input  wire                          [AXI_DATA_WIDTH_P-1 : 0] slv_rdata,
    input  wire                                                   slv_rlast,
    input  wire                                                   slv_rvalid,
    output logic                                                  slv_rready
  );


  // ---------------------------------------------------------------------------
  // Read Channel signals
  // ---------------------------------------------------------------------------

  typedef enum {
    FIND_MST_ARVALID_E,
    WAIT_FOR_ADDR_HS_E,
    WAIT_SLV_RLAST_E
  } read_state_t;

  read_state_t read_state;

  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] read_rotating_mst;
  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] read_select;
  logic                                 read_mst_is_chosen;

  // ---------------------------------------------------------------------------
  // Port assignments
  // ---------------------------------------------------------------------------

  // AXI4 Read Data Channel
  assign mst_rid   = slv_rid;
  assign mst_rresp = slv_rresp;
  assign mst_rdata = slv_rdata;
  assign mst_rlast = slv_rlast;

  // ---------------------------------------------------------------------------
  // Read processes
  // ---------------------------------------------------------------------------

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      read_state         <= FIND_MST_ARVALID_E;
      mst_arready        <= '0;
      read_rotating_mst  <= '0;                 // Round Robin counter
      read_select        <= '0;                 // MUX select
      read_mst_is_chosen <= '0;                 // Output enable
    end
    else begin

      mst_arready <= '0;

      // -----------------------------------------------------------------------
      // Read Address Channel
      // -----------------------------------------------------------------------

      case (read_state)

        FIND_MST_ARVALID_E: begin

          if (read_rotating_mst == NR_OF_MASTERS_P-1) begin
            read_rotating_mst <= '0;
          end else begin
            read_rotating_mst <= read_rotating_mst + 1;
          end

          if (mst_arvalid[read_rotating_mst]) begin
            read_state                     <= WAIT_FOR_ADDR_HS_E;
            mst_arready[read_rotating_mst] <= slv_arready;
            read_select                    <= read_rotating_mst;
            read_mst_is_chosen             <= '1;
          end
        end


        WAIT_FOR_ADDR_HS_E: begin

          mst_arready        <= '0;
          mst_arready[read_select] <= slv_arready;

          if (slv_arready && slv_arvalid) begin
            read_state         <= WAIT_SLV_RLAST_E;
          end
        end


        WAIT_SLV_RLAST_E: begin

          if (slv_rlast && slv_rvalid && slv_rready) begin
            read_state         <= FIND_MST_ARVALID_E;
            read_mst_is_chosen <= '0;
          end
        end
      endcase
    end
  end


  // MUX - Read Address Channel
  always_comb begin

    slv_arid     = '0;
    slv_araddr   = '0;
    slv_arlen    = '0;
    slv_arsize   = '0;
    slv_arburst  = '0;
    slv_arregion = '0;
    slv_arvalid  = '0;

    if (!read_mst_is_chosen) begin

      slv_arid     = '0;
      slv_araddr   = '0;
      slv_arlen    = '0;
      slv_arsize   = '0;
      slv_arburst  = '0;
      slv_arregion = '0;
      slv_arvalid  = '0;
    end else begin

      slv_arid     = mst_arid     [read_select];
      slv_araddr   = mst_araddr   [read_select];
      slv_arlen    = mst_arlen    [read_select];
      slv_arsize   = mst_arsize   [read_select];
      slv_arburst  = mst_arburst  [read_select];
      slv_arregion = mst_arregion [read_select];
      slv_arvalid  = mst_arvalid  [read_select];
    end
  end


  // MUX - Read Data Channel
  always_comb begin

    mst_rvalid = '0;
    slv_rready = '0;

    if (!read_mst_is_chosen) begin
      mst_rvalid = '0;
      slv_rready = '0;
    end else begin
      mst_rvalid[read_select] = slv_rvalid;
      slv_rready              = mst_rready[read_select];
    end
  end
endmodule

`default_nettype wire
