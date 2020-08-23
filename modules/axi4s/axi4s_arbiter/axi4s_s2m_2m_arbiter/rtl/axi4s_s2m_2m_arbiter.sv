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

module axi4s_s2m_2m_arbiter #(
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_STRB_WIDTH_P = -1,
    parameter int AXI_KEEP_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI_DEST_WIDTH_P = -1,
    parameter int AXI_USER_WIDTH_P = -1,
    parameter int MASTER0_TID_P    = -1,
    parameter int MASTER1_TID_P    = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // -------------------------------------------------------------------------
    // Ingress (Slave)
    // -------------------------------------------------------------------------

    input  wire                           slv_tvalid,
    output logic                          slv_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] slv_tdata,
    input  wire  [AXI_STRB_WIDTH_P-1 : 0] slv_tstrb,
    input  wire  [AXI_KEEP_WIDTH_P-1 : 0] slv_tkeep,
    input  wire                           slv_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] slv_tid,
    input  wire  [AXI_DEST_WIDTH_P-1 : 0] slv_tdest,
    input  wire  [AXI_USER_WIDTH_P-1 : 0] slv_tuser,

    // -------------------------------------------------------------------------
    // Egress (Masters)
    // -------------------------------------------------------------------------

    output logic                          mst0_tvalid,
    input  wire                           mst0_tready,
    output logic [AXI_DATA_WIDTH_P-1 : 0] mst0_tdata,
    output logic [AXI_STRB_WIDTH_P-1 : 0] mst0_tstrb,
    output logic [AXI_KEEP_WIDTH_P-1 : 0] mst0_tkeep,
    output logic                          mst0_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] mst0_tid,
    output logic [AXI_DEST_WIDTH_P-1 : 0] mst0_tdest,
    output logic [AXI_USER_WIDTH_P-1 : 0] mst0_tuser,

    output logic                          mst1_tvalid,
    input  wire                           mst1_tready,
    output logic [AXI_DATA_WIDTH_P-1 : 0] mst1_tdata,
    output logic [AXI_STRB_WIDTH_P-1 : 0] mst1_tstrb,
    output logic [AXI_KEEP_WIDTH_P-1 : 0] mst1_tkeep,
    output logic                          mst1_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] mst1_tid,
    output logic [AXI_DEST_WIDTH_P-1 : 0] mst1_tdest,
    output logic [AXI_USER_WIDTH_P-1 : 0] mst1_tuser
  );

  typedef enum {
    NO_SELECTED_E,
    MASTER0_E,
    MASTER1_E
  } selected_master_t;

  typedef enum {
    WAIT_ING_TVALID,
    WAIT_ING_TLAST
  } arbiter_state_t;

  selected_master_t selected_master;
  arbiter_state_t   arbiter_state;
  arbiter_state_t   next_arbiter_state;

  // Interface muxing
  always_comb begin

    case (selected_master)

      NO_SELECTED_E: begin

        slv_tready  = '0;

        mst0_tvalid = '0;
        mst0_tdata  = '0;
        mst0_tstrb  = '0;
        mst0_tkeep  = '0;
        mst0_tlast  = '0;
        mst0_tid    = '0;
        mst0_tdest  = '0;
        mst0_tuser  = '0;

        mst1_tvalid = '0;
        mst1_tdata  = '0;
        mst1_tstrb  = '0;
        mst1_tkeep  = '0;
        mst1_tlast  = '0;
        mst1_tid    = '0;
        mst1_tdest  = '0;
        mst1_tuser  = '0;
      end


      MASTER0_E: begin

        slv_tready  = mst0_tready;

        mst0_tvalid = slv_tvalid;
        mst0_tdata  = slv_tdata;
        mst0_tstrb  = slv_tstrb;
        mst0_tkeep  = slv_tkeep;
        mst0_tlast  = slv_tlast;
        mst0_tid    = slv_tid;
        mst0_tdest  = slv_tdest;
        mst0_tuser  = slv_tuser;
      end


      MASTER1_E: begin

        slv_tready  = mst1_tready;

        mst1_tvalid = slv_tvalid;
        mst1_tdata  = slv_tdata;
        mst1_tstrb  = slv_tstrb;
        mst1_tkeep  = slv_tkeep;
        mst1_tlast  = slv_tlast;
        mst1_tid    = slv_tid;
        mst1_tdest  = slv_tdest;
        mst1_tuser  = slv_tuser;
      end


      default: begin

        slv_tready  = '0;

        mst0_tvalid = '0;
        mst0_tdata  = '0;
        mst0_tstrb  = '0;
        mst0_tkeep  = '0;
        mst0_tlast  = '0;
        mst0_tid    = '0;
        mst0_tdest  = '0;
        mst0_tuser  = '0;

        mst1_tvalid = '0;
        mst1_tdata  = '0;
        mst1_tstrb  = '0;
        mst1_tkeep  = '0;
        mst1_tlast  = '0;
        mst1_tid    = '0;
        mst1_tdest  = '0;
        mst1_tuser  = '0;
      end
    endcase

  end



  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      arbiter_state <= WAIT_ING_TVALID;
    end
    else begin
      arbiter_state <= next_arbiter_state;
    end
  end


  always_comb begin

    next_arbiter_state = arbiter_state;

    case (arbiter_state)

      WAIT_ING_TVALID: begin

        selected_master = NO_SELECTED_E;

        if (slv_tvalid) begin

          if (!slv_tlast) begin
            next_arbiter_state = WAIT_ING_TLAST;
          end

          case (slv_tid)

            MASTER0_TID_P: begin
              selected_master = MASTER0_E;
            end

            MASTER1_TID_P: begin
              selected_master = MASTER1_E;
            end

          endcase
        end

      end


      WAIT_ING_TLAST: begin

        if (slv_tvalid && slv_tready && slv_tlast) begin
          next_arbiter_state = WAIT_ING_TVALID;
        end
      end

    endcase

  end

endmodule

`default_nettype wire
