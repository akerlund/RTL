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
// This arbiter uses the value of "arregion" to decide which slave is requested
// by a master and thus this module supports up to 16 connections.
//
///////////////////////////////////////////////////////////////////////////////

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

  typedef enum {
    WAIT_MST_ARVALID_E,
    WAIT_SLV_ARREADY_E,
    WAIT_SLV_RLAST_E
  } read_state_t;

  read_state_t read_state;

  logic [NR_OF_SLAVES_C-1 : 0] arregion;

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
    end
    else begin

      case (read_state)

        WAIT_MST_ARVALID_E: begin

          if (mst_arvalid) begin
            read_state <= WAIT_SLV_ARREADY_E;
            arregion   <= mst_arregion[NR_OF_SLAVES_C-1 : 0];
          end
        end

        WAIT_SLV_ARREADY_E: begin

          if (mst_arvalid && mst_arready) begin
            read_state <= WAIT_SLV_RLAST_E;
            arregion   <= mst_arregion[NR_OF_SLAVES_C-1 : 0];
          end
        end


        WAIT_SLV_RLAST_E: begin

          if (mst_rlast && mst_rvalid && mst_rready) begin
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
    if (read_state == WAIT_SLV_ARREADY_E) begin

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
    end
  end
endmodule

`default_nettype wire
