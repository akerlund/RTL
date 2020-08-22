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
//   Read Address Channel:
//   Arbiter for connecting several AXI4 Masters to one AXI4 Slave.
//   When a Master is given access it is only allowed to send one "araddr"
//   and the arbiter is hard coded to forward "arburst" as incremental mode.
//
//   Read Data Channel:
//   TODO
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module axi4_read_arbiter #(
    parameter int AXI_ID_WIDTH_P   = 3,
    parameter int AXI_ADDR_WIDTH_P = 32,
    parameter int AXI_DATA_WIDTH_P = 32,
    parameter int NR_OF_MASTERS_P  = 4
  )(

    // Clock and reset
    input  wire                                                   clk,
    input  wire                                                   rst_n,

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Read Address Channel
    input  wire  [0 : NR_OF_MASTERS_P-1]   [AXI_ID_WIDTH_P-1 : 0] mst_arid,
    input  wire  [0 : NR_OF_MASTERS_P-1] [AXI_ADDR_WIDTH_P-1 : 0] mst_araddr,
    input  wire  [0 : NR_OF_MASTERS_P-1]                  [7 : 0] mst_arlen,
    input  wire  [0 : NR_OF_MASTERS_P-1]                          mst_arvalid,
    output logic [0 : NR_OF_MASTERS_P-1]                          mst_arready,

    // Read Data Channel
    output logic                           [AXI_ID_WIDTH_P-1 : 0] mst_rid,
    output logic                         [AXI_DATA_WIDTH_P-1 : 0] mst_rdata,
    output logic                                                  mst_rlast,
    output logic [0 : NR_OF_MASTERS_P-1]                          mst_rvalid,
    input  wire  [0 : NR_OF_MASTERS_P-1]                          mst_rready,

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Read Address Channel
    output logic                           [AXI_ID_WIDTH_P-1 : 0] slv_arid,
    output logic                         [AXI_ADDR_WIDTH_P-1 : 0] slv_araddr,
    output logic                                          [7 : 0] slv_arlen,
    output logic                                          [2 : 0] slv_arsize,
    output logic                                          [1 : 0] slv_arburst,
    output logic                                                  slv_arlock,
    output logic                                          [3 : 0] slv_arcache,
    output logic                                          [2 : 0] slv_arprot,
    output logic                                          [3 : 0] slv_arqos,
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
    WAIT_FOR_ADDR_HS_E
  } rac_state_t;

  typedef enum {
    WAIT_SLV_RVALID_E,
    WAIT_SLV_RLAST_E
  } rdc_state_t;

  rac_state_t rac_state;
  rdc_state_t rdc_state;

  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] rac_rotating_mst;
  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] rac_select;       // Read Address Channel
  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] rdc_select;       // Read Data Channel
  logic                                 rac_mst_is_chosen;
  logic                                 rdc_mst_is_chosen;

  // ---------------------------------------------------------------------------
  // Port assignments
  // ---------------------------------------------------------------------------

  // AXI4 Read Address Channel
  assign slv_arsize  = '0;
  assign slv_arburst = '0;
  assign slv_arlock  = '0;
  assign slv_arcache = '0;
  assign slv_arprot  = '0;
  assign slv_arqos   = '0;

  // AXI4 Read Data Channel
  assign mst_rid   = slv_rid;
  assign mst_rdata = slv_rdata;
  assign mst_rlast = slv_rlast;

  // ---------------------------------------------------------------------------
  // Read processes
  // ---------------------------------------------------------------------------

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rac_state         <= FIND_MST_ARVALID_E;
      rdc_state         <= WAIT_SLV_RVALID_E;
      mst_arready       <= '0;
      rac_rotating_mst  <= '0;                 // Round Robin counter
      rac_select        <= '0;                 // MUX select
      rdc_select        <= '0;                 // MUX select
      rac_mst_is_chosen <= '0;                 // Output enable
      rdc_mst_is_chosen <= '0;
    end
    else begin

      // -----------------------------------------------------------------------
      // Read Address Channel
      // -----------------------------------------------------------------------

      case (rac_state)

        FIND_MST_ARVALID_E: begin

          if (slv_arready) begin

            if (rac_rotating_mst == NR_OF_MASTERS_P-1) begin
              rac_rotating_mst <= '0;
            end
            else begin
              rac_rotating_mst <= rac_rotating_mst + 1;
            end

            if (mst_arvalid[rac_rotating_mst]) begin

              rac_state                     <= WAIT_FOR_ADDR_HS_E;
              mst_arready[rac_rotating_mst] <= '1;
              rac_select                    <= rac_rotating_mst;
              rac_mst_is_chosen             <= '1;

            end

          end
        end


        WAIT_FOR_ADDR_HS_E: begin

          if (slv_arready && slv_arvalid) begin
            rac_state         <= FIND_MST_ARVALID_E;
            mst_arready       <= '0;
            rac_mst_is_chosen <= '0;
          end
          else begin
            mst_arready <= mst_arready;
          end

        end

      endcase

      // -----------------------------------------------------------------------
      // Read Data Channel
      // -----------------------------------------------------------------------

      case (rdc_state)

        WAIT_SLV_RVALID_E: begin

          if (slv_rvalid) begin

            rdc_state         <= WAIT_SLV_RLAST_E;
            rdc_select        <= slv_rid;
            rdc_mst_is_chosen <= '1;

          end
        end


        WAIT_SLV_RLAST_E: begin

          if (slv_rlast && slv_rvalid && slv_rready) begin
            rdc_state         <= WAIT_SLV_RVALID_E;
            rdc_mst_is_chosen <= '0;
          end

        end

      endcase

    end
  end


  // MUX - Read Address Channel
  always_comb begin

    if (!rac_mst_is_chosen) begin

      slv_arid    = '0;
      slv_araddr  = '0;
      slv_arlen   = '0;
      slv_arvalid = '0;

    end
    else begin

      slv_arid    = mst_arid    [rac_select];
      slv_araddr  = mst_araddr  [rac_select];
      slv_arlen   = mst_arlen   [rac_select];
      slv_arvalid = mst_arvalid [rac_select];

    end
  end


  // MUX - Read Data Channel
  always_comb begin

    if (!rdc_mst_is_chosen) begin

      mst_rvalid = '0;
      slv_rready = '0;

    end
    else begin

      mst_rvalid[rdc_select] = slv_rvalid;
      slv_rready             = mst_rready[rdc_select];

    end

  end

endmodule

`default_nettype wire
