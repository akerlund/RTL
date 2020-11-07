
module axi4s_m2s_arbiter #(
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
    // AXI4-S Masters
    // -------------------------------------------------------------------------

    input wire   [NR_OF_MASTERS_P-1 : 0]                          mst_tvalid,
    output logic [NR_OF_MASTERS_P-1 : 0]                          mst_tready,
    input wire   [NR_OF_MASTERS_P-1 : 0] [AXI_DATA_WIDTH_P-1 : 0] mst_tdata,
    input wire   [NR_OF_MASTERS_P-1 : 0] [AXI_STRB_WIDTH_P-1 : 0] mst_tstrb,
    input wire   [NR_OF_MASTERS_P-1 : 0] [AXI_KEEP_WIDTH_P-1 : 0] mst_tkeep,
    input wire   [NR_OF_MASTERS_P-1 : 0]                          mst_tlast,
    input wire   [NR_OF_MASTERS_P-1 : 0]   [AXI_ID_WIDTH_P-1 : 0] mst_tid,
    input wire   [NR_OF_MASTERS_P-1 : 0] [AXI_DEST_WIDTH_P-1 : 0] mst_tdest,
    input wire   [NR_OF_MASTERS_P-1 : 0] [AXI_USER_WIDTH_P-1 : 0] mst_tuser,

    // -------------------------------------------------------------------------
    // AXI4-S Slave
    // -------------------------------------------------------------------------

    output logic                                                  slv_tvalid,
    input wire                                                    slv_tready,
    output logic                         [AXI_DATA_WIDTH_P-1 : 0] slv_tdata,
    output logic                         [AXI_STRB_WIDTH_P-1 : 0] slv_tstrb,
    output logic                         [AXI_KEEP_WIDTH_P-1 : 0] slv_tkeep,
    output logic                                                  slv_tlast,
    output logic                           [AXI_ID_WIDTH_P-1 : 0] slv_tid,
    output logic                         [AXI_DEST_WIDTH_P-1 : 0] slv_tdest,
    output logic                         [AXI_USER_WIDTH_P-1 : 0] slv_tuser
  );


  localparam logic [$clog2(NR_OF_MASTERS_P)-1 : 0] NR_OF_MASTERS_C = NR_OF_MASTERS_P;

  // ---------------------------------------------------------------------------
  // Write Channel signals
  // ---------------------------------------------------------------------------

  typedef enum {
    FIND_MST_TVALID_E,
    WAIT_MST_TLAST_E
  } write_state_t;

  write_state_t write_state;

  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] wr_rotating_mst;
  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] wr_selected_mst;
  logic                                 wr_mst_is_chosen;

  // ---------------------------------------------------------------------------
  // Write processes
  // ---------------------------------------------------------------------------

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      write_state      <= FIND_MST_TVALID_E;
      wr_rotating_mst  <= '0;                 // Round Robin counter
      wr_selected_mst  <= '0;                 // MUX select
      wr_mst_is_chosen <= '0;                 // Output enable
    end
    else begin

      case (write_state)

        FIND_MST_TVALID_E: begin

          if (slv_tready) begin

            if (wr_rotating_mst == NR_OF_MASTERS_C-1) begin
              wr_rotating_mst <= '0;
            end
            else begin
              wr_rotating_mst <= wr_rotating_mst + 1;
            end

            if (mst_tvalid[wr_rotating_mst]) begin
              write_state                  <= WAIT_MST_TLAST_E;
              wr_selected_mst              <= wr_rotating_mst;
              wr_mst_is_chosen             <= '1;
            end

          end
        end


        WAIT_MST_TLAST_E: begin

          if (slv_tlast && slv_tvalid && slv_tready) begin
            write_state      <= FIND_MST_TVALID_E;
            wr_mst_is_chosen <= '0;
          end

        end

      endcase
    end
  end


  // MUX
  always_comb begin

    slv_tvalid = '0;
    slv_tdata  = '0;
    slv_tstrb  = '0;
    slv_tkeep  = '0;
    slv_tlast  = '0;
    slv_tid    = '0;
    slv_tdest  = '0;
    slv_tuser  = '0;
    mst_tready = '0;


    if (!wr_mst_is_chosen) begin

      slv_tvalid = '0;
      slv_tdata  = slv_tdata;
      slv_tstrb  = slv_tstrb;
      slv_tkeep  = slv_tkeep;
      slv_tlast  = slv_tlast;
      slv_tid    = slv_tid;
      slv_tdest  = slv_tdest;
      slv_tuser  = slv_tuser;
      mst_tready = '0;

    end
    else begin

      slv_tvalid = mst_tvalid [wr_selected_mst];
      slv_tdata  = mst_tdata  [wr_selected_mst];
      slv_tstrb  = mst_tstrb  [wr_selected_mst];
      slv_tkeep  = mst_tkeep  [wr_selected_mst];
      slv_tlast  = mst_tlast  [wr_selected_mst];
      slv_tid    = mst_tid    [wr_selected_mst];
      slv_tdest  = mst_tdest  [wr_selected_mst];
      slv_tuser  = mst_tuser  [wr_selected_mst];

      mst_tready[wr_selected_mst] = slv_tready;

    end

  end

endmodule
