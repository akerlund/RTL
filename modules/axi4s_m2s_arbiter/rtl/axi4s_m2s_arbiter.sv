
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

  typedef enum {
    FIND_MST_TVALID_E,
    WAIT_MST_TLAST_E
  } arbiter_state_t;

  arbiter_state_t arbiter_state;

  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] rotating_mst;
  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] mux_address;
  logic                                 output_enable;

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      arbiter_state <= FIND_MST_TVALID_E;
      rotating_mst  <= '0;
      mux_address   <= '0;
      output_enable <= '0;
    end
    else begin

      case (arbiter_state)

        FIND_MST_TVALID_E: begin

          if (slv_tready) begin

            if (rotating_mst == NR_OF_MASTERS_C-1) begin
              rotating_mst <= '0;
            end
            else begin
              rotating_mst <= rotating_mst + 1;
            end

            if (mst_tvalid[rotating_mst]) begin
              arbiter_state <= WAIT_MST_TLAST_E;
              mux_address  <= rotating_mst;
              output_enable <= '1;
            end

          end
        end


        WAIT_MST_TLAST_E: begin

          if (slv_tlast && slv_tvalid && slv_tready) begin
            arbiter_state <= FIND_MST_TVALID_E;
            output_enable <= '0;
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


    if (!output_enable) begin

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

      slv_tvalid = mst_tvalid [mux_address];
      slv_tdata  = mst_tdata  [mux_address];
      slv_tstrb  = mst_tstrb  [mux_address];
      slv_tkeep  = mst_tkeep  [mux_address];
      slv_tlast  = mst_tlast  [mux_address];
      slv_tid    = mst_tid    [mux_address];
      slv_tdest  = mst_tdest  [mux_address];
      slv_tuser  = mst_tuser  [mux_address];

      mst_tready[mux_address] = slv_tready;

    end

  end

endmodule
