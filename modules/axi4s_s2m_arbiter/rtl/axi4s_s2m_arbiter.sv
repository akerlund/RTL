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
// This arbiter uses the 'tdest' field from the slave to select which
// connected master's tvalid signal to assert.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module axi4s_s2m_arbiter #(
    parameter int NR_OF_MASTERS_P  = -1,
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_STRB_WIDTH_P = -1,
    parameter int AXI_KEEP_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int AXI_DEST_WIDTH_P = -1,
    parameter int AXI_USER_WIDTH_P = -1
  )(
    // Clock and reset
    input  wire                                                   clk,
    input  wire                                                   rst_n,

    // -------------------------------------------------------------------------
    // AXI4-S Slave
    // -------------------------------------------------------------------------

    input  wire                                                   slv_tvalid,
    output logic                                                  slv_tready,
    input  wire                          [AXI_DATA_WIDTH_P-1 : 0] slv_tdata,
    input  wire                          [AXI_STRB_WIDTH_P-1 : 0] slv_tstrb,
    input  wire                          [AXI_KEEP_WIDTH_P-1 : 0] slv_tkeep,
    input  wire                                                   slv_tlast,
    input  wire                            [AXI_ID_WIDTH_P-1 : 0] slv_tid,
    input  wire                          [AXI_DEST_WIDTH_P-1 : 0] slv_tdest,
    input  wire                          [AXI_USER_WIDTH_P-1 : 0] slv_tuser,

    // -------------------------------------------------------------------------
    // AXI4-S Masters
    // -------------------------------------------------------------------------

    output logic [NR_OF_MASTERS_P-1 : 0]                          mst_tvalid,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                          mst_tready,
    output logic                         [AXI_DATA_WIDTH_P-1 : 0] mst_tdata,
    output logic                         [AXI_STRB_WIDTH_P-1 : 0] mst_tstrb,
    output logic                         [AXI_KEEP_WIDTH_P-1 : 0] mst_tkeep,
    output logic                                                  mst_tlast,
    output logic                           [AXI_ID_WIDTH_P-1 : 0] mst_tid,
    output logic                         [AXI_DEST_WIDTH_P-1 : 0] mst_tdest,
    output logic                         [AXI_USER_WIDTH_P-1 : 0] mst_tuser
  );

  typedef enum {
    WAIT_SLV_TVALID_E,
    WAIT_SLV_TLAST_E
  } arbiter_state_t;

  arbiter_state_t arbiter_state;

  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] mux_address;
  logic                                 output_enable;

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      arbiter_state <= WAIT_SLV_TVALID_E;
      mux_address   <= '0;
      output_enable <= '0;
    end
    else begin

      case (arbiter_state)

        WAIT_SLV_TVALID_E: begin

          if (slv_tvalid) begin

            arbiter_state <= WAIT_SLV_TLAST_E;
            mux_address   <= slv_tdest;
            output_enable <= '1;

          end
        end


        WAIT_SLV_TLAST_E: begin

          if (slv_tlast && slv_tvalid && slv_tready) begin
            arbiter_state <= WAIT_SLV_TVALID_E;
            output_enable <= '0;
          end

        end

      endcase
    end
  end

  // Interface muxing
  always_comb begin

    slv_tready = '0;
    mst_tvalid = '0;

    mst_tdata  = slv_tdata;
    mst_tstrb  = slv_tstrb;
    mst_tkeep  = slv_tkeep;
    mst_tlast  = slv_tlast;
    mst_tid    = slv_tid;
    mst_tdest  = slv_tdest;
    mst_tuser  = slv_tuser;

    if (!output_enable) begin

        slv_tready = '0;
        mst_tvalid = '0;

    end
    else begin

      slv_tready              = mst_tready[mux_address];
      mst_tvalid[mux_address] = slv_tvalid;

    end

  end

endmodule

`default_nettype wire
