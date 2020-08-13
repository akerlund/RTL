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
//   Arbiter for connecting several AXI4 Masters to one AXI4 Slave.
//   When a Master is given access it is only allowed to send one "awaddr"
//   and the arbiter is hard coded to forward "awburst" as incremental mode.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module axi4_m2s_arbiter #(
    parameter int AXI_ID_WIDTH_P    = 3,
    parameter int AXI_ADDR_WIDTH_P  = 32,
    parameter int AXI_DATA_WIDTH_P  = 32,
    parameter int AXI_STRB_WIDTH_P  = 4,
    parameter int NR_OF_MASTERS_P   = 4
  )(

    // Clock and reset
    input  wire                                                   clk,
    input  wire                                                   rst_n,


    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Write Address Channel
    input  wire  [0 : NR_OF_MASTERS_P-1]   [AXI_ID_WIDTH_P-1 : 0] mst_awid,
    input  wire  [0 : NR_OF_MASTERS_P-1] [AXI_ADDR_WIDTH_P-1 : 0] mst_awaddr,
    input  wire  [0 : NR_OF_MASTERS_P-1]                  [7 : 0] mst_awlen,
    input  wire  [0 : NR_OF_MASTERS_P-1]                          mst_awvalid,
    output logic [0 : NR_OF_MASTERS_P-1]                          mst_awready,

    // Write Data Channel
    input  wire  [0 : NR_OF_MASTERS_P-1] [AXI_DATA_WIDTH_P-1 : 0] mst_wdata,
    input  wire  [0 : NR_OF_MASTERS_P-1] [AXI_STRB_WIDTH_P-1 : 0] mst_wstrb,
    input  wire  [0 : NR_OF_MASTERS_P-1]                          mst_wlast,
    input  wire  [0 : NR_OF_MASTERS_P-1]                          mst_wvalid,
    output logic [0 : NR_OF_MASTERS_P-1]                          mst_wready,

    // Read Address Channel
    input  wire  [0 : NR_OF_MASTERS_P-1]   [AXI_ID_WIDTH_P-1 : 0] mst_arid,
    input  wire  [0 : NR_OF_MASTERS_P-1] [AXI_ADDR_WIDTH_P-1 : 0] mst_araddr,
    input  wire  [0 : NR_OF_MASTERS_P-1]                  [7 : 0] mst_arlen,
    input  wire  [0 : NR_OF_MASTERS_P-1]                          mst_arvalid,
    output logic [0 : NR_OF_MASTERS_P-1]                          mst_arready,

    // Read Data Channel
    output logic [0 : NR_OF_MASTERS_P-1] [AXI_DATA_WIDTH_P-1 : 0] mst_rdata,
    output logic [0 : NR_OF_MASTERS_P-1]                          mst_rlast,
    output logic [0 : NR_OF_MASTERS_P-1]                          mst_rvalid,
    input  wire  [0 : NR_OF_MASTERS_P-1]                          mst_rready,

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Write Address Channel
    output logic                           [AXI_ID_WIDTH_P-1 : 0] slv_awid,
    output logic                         [AXI_ADDR_WIDTH_P-1 : 0] slv_awaddr,
    output logic                                          [7 : 0] slv_awlen,
    output logic                                          [2 : 0] slv_awsize,
    output logic                                          [1 : 0] slv_awburst,
    output logic                                                  slv_awlock,
    output logic                                          [3 : 0] slv_awcache,
    output logic                                          [2 : 0] slv_awprot,
    output logic                                          [3 : 0] slv_awqos,
    output logic                                                  slv_awvalid,
    input  wire                                                   slv_awready,

    // Write Data Channel
    output logic                         [AXI_DATA_WIDTH_P-1 : 0] slv_wdata,
    output logic                         [AXI_STRB_WIDTH_P-1 : 0] slv_wstrb,
    output logic                                                  slv_wlast,
    output logic                                                  slv_wvalid,
    input  wire                                                   slv_wready,

    // Write Response Channel
    input  wire                            [AXI_ID_WIDTH_P-1 : 0] slv_bid,
    input  wire                                           [1 : 0] slv_bresp,
    input  wire                                                   slv_bvalid,
    output logic                                                  slv_bready,

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
  // Write Channel signals
  // ---------------------------------------------------------------------------

  typedef enum {
    FIND_MST_AWVALID_E,
    WAIT_FOR_BVALID_E
  } write_state_t;

  write_state_t write_state;

  logic [NR_OF_MASTERS_P-1 : 0] wr_rotating_mst;
  logic [NR_OF_MASTERS_P-1 : 0] wr_selected_mst;
  logic [NR_OF_MASTERS_P-1 : 0] wr_mst_is_chosen;

  // ---------------------------------------------------------------------------
  // Read Channel signals
  // ---------------------------------------------------------------------------

  typedef enum {
    FIND_MST_ARVALID_E,
    WAIT_FOR_RLAST_E
  } read_state_t;

  read_state_t read_state;

  logic [NR_OF_MASTERS_P-1 : 0] rd_rotating_mst;
  logic [NR_OF_MASTERS_P-1 : 0] rd_selected_mst;
  logic [NR_OF_MASTERS_P-1 : 0] rd_mst_is_chosen;

  // ---------------------------------------------------------------------------
  // Port assignments
  // ---------------------------------------------------------------------------

  // AXI4 Write Channel
  assign slv_awsize  = burst_size_as_enum(AXI_STRB_WIDTH_P);
  assign slv_awburst = AXI4_BURST_INCR_C;
  assign slv_awlock  = '0;
  assign slv_awcache = '0;
  assign slv_awprot  = '0;
  assign slv_awqos   = '0;

  // AXI4 Read Channel
  assign slv_arsize  = burst_size_as_enum(AXI_STRB_WIDTH_P);
  assign slv_arburst = AXI4_BURST_INCR_C;
  assign slv_arlock  = '0;
  assign slv_arcache = '0;
  assign slv_arprot  = '0;
  assign slv_arqos   = '0;

  for (int i = 0; i < NR_OF_MASTERS_P) begin
    assign mst_rdata[i] <= slv_rdata;
    assign mst_rlast[i] <= slv_rlast;
  end

  // ---------------------------------------------------------------------------
  // Write processes
  // ---------------------------------------------------------------------------

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      write_state      <= FIND_MST_AWVALID_E;
      wr_rotating_mst  <= '0;                 // Round Robin counter
      wr_selected_mst  <= '0;                 // MUX select
      wr_mst_is_chosen <= '0;                 // Output enable
      slv_bready       <= '0;                 // Write Response Channel
    end
    else begin

      case (write_state)

        FIND_MST_AWVALID_E: begin

          wr_rotating_mst <= wr_rotating_mst + 1;

          if (mst_awvalid[wr_rotating_mst]) begin
            write_state      <= WAIT_FOR_BVALID_E;
            wr_selected_mst  <= wr_rotating_mst;
            wr_mst_is_chosen <= '1;
          end

        end


        WAIT_FOR_BVALID_E: begin

          if (wr_rotating_mst >= NR_OF_MASTERS_P) begin
            wr_rotating_mst <= '0;
          end

          if (slv_bvalid) begin
            write_state      <= FIND_MST_AWVALID_E;
            wr_mst_is_chosen <= '0;
          end

        end

      endcase
    end
  end


  // MUX
  always_comb begin

    if (!wr_mst_is_chosen) begin

      // Write Address Channel
      slv_awid    <= '0;
      slv_awaddr  <= '0;
      slv_awlen   <= '0;
      slv_awvalid <= '0;
      mst_awready <= '0;

      // Write Data Channel
      slv_wdata   <= '0;
      slv_wstrb   <= '0;
      slv_wlast   <= '0;
      slv_wvalid  <= '0;
      mst_wready  <= '0;

    end
    else begin

      // Default
      mst_awready                  <= '0;
      mst_wready                   <= '0;

      // Write Address Channel
      slv_awid                     <= {'0, wr_selected_mst};
      slv_awaddr                   <= mst_awaddr  [wr_selected_mst];
      slv_awlen                    <= mst_awlen   [wr_selected_mst];
      slv_awvalid                  <= mst_awvalid [wr_selected_mst];
      mst_awready[wr_selected_mst] <= slv_awready;

      // Write Data Channel
      slv_wdata                    <= mst_wdata  [wr_selected_mst];
      slv_wstrb                    <= mst_wstrb  [wr_selected_mst];
      slv_wlast                    <= mst_wlast  [wr_selected_mst];
      slv_wvalid                   <= mst_wvalid [wr_selected_mst];
      mst_wready[wr_selected_mst]  <= slv_wready;

    end

  end

  // ---------------------------------------------------------------------------
  // Read processes
  // ---------------------------------------------------------------------------

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      read_state       <= FIND_MST_ARVALID_E;
      rd_rotating_mst  <= '0;                 // Round Robin counter
      rd_selected_mst  <= '0;                 // MUX select
      rd_mst_is_chosen <= '0;                 // Output enable
    end
    else begin

      case (read_state)

        FIND_MST_ARVALID_E: begin

          rd_rotating_mst <= rd_rotating_mst + 1;

          if (mst_awvalid[rd_rotating_mst]) begin
            read_state       <= WAIT_FOR_RLAST_E;
            rd_selected_mst  <= rd_rotating_mst;
            rd_mst_is_chosen <= '1;
          end

        end


        WAIT_FOR_RLAST_E: begin

          if (rd_rotating_mst >= NR_OF_MASTERS_P) begin
            rd_rotating_mst <= '0;
          end

          if (slv_rlast && slv_rvalid && mst_rready[rd_selected_mst]) begin
            read_state       <= FIND_MST_ARVALID_E;
            rd_mst_is_chosen <= '0;
          end

        end

      endcase
    end
  end


  // MUX
  always_comb begin

    if (!rd_mst_is_chosen) begin

      // Read Address Channel
      slv_arid    <= '0;
      slv_araddr  <= '0;
      slv_arlen   <= '0;
      slv_arvalid <= '0;
      mst_arready <= '0;

      // Read Data Channel
      mst_rlast   <= '0;
      mst_rvalid  <= '0;
      slv_rready  <= '0;

    end
    else begin

      // Default
      mst_arready                  <= '0;
      mst_rvalid                   <= '0;

      // Read Address Channel
      slv_arid                     <= {'0, rd_selected_mst};
      slv_araddr                   <= mst_araddr  [rd_selected_mst];
      slv_arlen                    <= mst_arlen   [rd_selected_mst];
      slv_arvalid                  <= mst_arvalid [rd_selected_mst];
      mst_arready[rd_selected_mst] <= slv_arready;

      // Read Data Channel
      mst_rlast[rd_selected_mst]   <= slv_rlast;
      mst_rvalid[rd_selected_mst]  <= slv_rvalid;
      slv_rready                   <= mst_rready [rd_selected_mst];

    end

  end

endmodule

`default_nettype wire
