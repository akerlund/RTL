////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module axi4s_m2s_2m_arbiter #(
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_STRB_WIDTH_P = -1,
    parameter int AXI_KEEP_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI_DEST_WIDTH_P = -1,
    parameter int AXI_USER_WIDTH_P = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // -------------------------------------------------------------------------
    // Ingress
    // -------------------------------------------------------------------------

    input  wire                           mst0_tvalid,
    output logic                          mst0_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] mst0_tdata,
    input  wire  [AXI_STRB_WIDTH_P-1 : 0] mst0_tstrb,
    input  wire  [AXI_KEEP_WIDTH_P-1 : 0] mst0_tkeep,
    input  wire                           mst0_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] mst0_tid,
    input  wire  [AXI_DEST_WIDTH_P-1 : 0] mst0_tdest,
    input  wire  [AXI_USER_WIDTH_P-1 : 0] mst0_tuser,

    input  wire                           mst1_tvalid,
    output logic                          mst1_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] mst1_tdata,
    input  wire  [AXI_STRB_WIDTH_P-1 : 0] mst1_tstrb,
    input  wire  [AXI_KEEP_WIDTH_P-1 : 0] mst1_tkeep,
    input  wire                           mst1_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] mst1_tid,
    input  wire  [AXI_DEST_WIDTH_P-1 : 0] mst1_tdest,
    input  wire  [AXI_USER_WIDTH_P-1 : 0] mst1_tuser,

    // -------------------------------------------------------------------------
    // Egress
    // -------------------------------------------------------------------------

    output logic                          slv_tvalid,
    input  wire                           slv_tready,
    output logic [AXI_DATA_WIDTH_P-1 : 0] slv_tdata,
    output logic [AXI_STRB_WIDTH_P-1 : 0] slv_tstrb,
    output logic [AXI_KEEP_WIDTH_P-1 : 0] slv_tkeep,
    output logic                          slv_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] slv_tid,
    output logic [AXI_DEST_WIDTH_P-1 : 0] slv_tdest,
    output logic [AXI_USER_WIDTH_P-1 : 0] slv_tuser
  );

  typedef enum {
    RR_PRIO_MST_0,
    RR_PRIO_MST_1,
    BURST_MST_0,
    BURST_MST_1
  } rr_priority_state_t;

  typedef enum {
    NO_SELECTED_E,
    MASTER0_E,
    MASTER1_E
  } selected_master_t;

  rr_priority_state_t current_rr_priority_state;
  rr_priority_state_t next_rr_priority_state;
  selected_master_t   selected_master;


  // Combinatorial multiplexing of the connected masters
  always_comb begin

    mst0_tready = '0;
    mst1_tready = '0;

    case (selected_master)

      NO_SELECTED_E: begin
        mst0_tready = '0;
        mst1_tready = '0;
        slv_tvalid  = '0;
        slv_tdata   = '0;
        slv_tstrb   = '0;
        slv_tkeep   = '0;
        slv_tlast   = '0;
        slv_tid     = '0;
        slv_tdest   = '0;
        slv_tuser   = '0;
      end

      MASTER0_E: begin
        slv_tvalid  = mst0_tvalid;
        mst0_tready = slv_tready;
        slv_tdata   = mst0_tdata;
        slv_tstrb   = mst0_tstrb;
        slv_tkeep   = mst0_tkeep;
        slv_tlast   = mst0_tlast;
        slv_tid     = mst0_tid;
        slv_tdest   = mst0_tdest;
        slv_tuser   = mst0_tuser;
      end

      MASTER1_E: begin
        slv_tvalid  = mst1_tvalid;
        mst1_tready = slv_tready;
        slv_tdata   = mst1_tdata;
        slv_tstrb   = mst1_tstrb;
        slv_tkeep   = mst1_tkeep;
        slv_tlast   = mst1_tlast;
        slv_tid     = mst1_tid;
        slv_tdest   = mst1_tdest;
        slv_tuser   = mst1_tuser;
      end

      default: begin
        mst0_tready = '0;
        mst1_tready = '0;
        slv_tvalid  = '0;
        slv_tdata   = '0;
        slv_tstrb   = '0;
        slv_tkeep   = '0;
        slv_tlast   = '0;
        slv_tid     = '0;
        slv_tdest   = '0;
        slv_tuser   = '0;
      end

    endcase
  end


  // Round Robin fashioned priority multiplexer
  always_comb begin

    // Standard assignments

    case (current_rr_priority_state)

      // -----------------------------------------------------------------------
      // States waiting that are waiting for any Master's "tvalid"
      // -----------------------------------------------------------------------

      RR_PRIO_MST_0: begin
        selected_master = NO_SELECTED_E;

        if (slv_tready) begin

          if (mst0_tvalid) begin      // Master 0
            next_rr_priority_state = BURST_MST_0;
          end
          else if (mst1_tvalid) begin // Master 1
            next_rr_priority_state = BURST_MST_1;
          end
        end
        else begin
          next_rr_priority_state = next_rr_priority_state;
        end
      end


      RR_PRIO_MST_1: begin
        selected_master = NO_SELECTED_E;

        if (slv_tready) begin

          if (mst1_tvalid) begin      // Master 1
            next_rr_priority_state = BURST_MST_1;
          end
          else if (mst0_tvalid) begin // Master 0
            next_rr_priority_state = BURST_MST_0;
          end
        end
        else begin
          next_rr_priority_state = next_rr_priority_state;
        end
      end

      // -----------------------------------------------------------------------
      // States waiting that are waiting for any Master's "tlast"
      // -----------------------------------------------------------------------

      BURST_MST_0: begin
        selected_master = MASTER0_E;
        if (mst0_tvalid && mst0_tready && mst0_tlast) begin
          next_rr_priority_state = RR_PRIO_MST_1;
        end
        else begin
          next_rr_priority_state = next_rr_priority_state;
        end
      end

      BURST_MST_1: begin
        next_rr_priority_state = next_rr_priority_state;
        selected_master = MASTER1_E;
        if (mst1_tvalid && mst1_tready && mst1_tlast) begin
          next_rr_priority_state = RR_PRIO_MST_0;
        end
        else begin
          next_rr_priority_state = next_rr_priority_state;
        end
      end

      default: begin
        selected_master = NO_SELECTED_E;
        next_rr_priority_state = RR_PRIO_MST_0;
      end

    endcase
  end


  // FSM REG
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_rr_priority_state <= RR_PRIO_MST_0;
    end
    else begin
      current_rr_priority_state <= next_rr_priority_state;
    end
  end

endmodule

`default_nettype wire
