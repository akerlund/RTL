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

    input  wire                           ing0_tvalid,
    output logic                          ing0_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] ing0_tdata,
    input  wire  [AXI_STRB_WIDTH_P-1 : 0] ing0_tstrb,
    input  wire  [AXI_KEEP_WIDTH_P-1 : 0] ing0_tkeep,
    input  wire                           ing0_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] ing0_tid,
    input  wire  [AXI_DEST_WIDTH_P-1 : 0] ing0_tdest,
    input  wire  [AXI_USER_WIDTH_P-1 : 0] ing0_tuser,

    input  wire                           ing1_tvalid,
    output logic                          ing1_tready,
    input  wire  [AXI_DATA_WIDTH_P-1 : 0] ing1_tdata,
    input  wire  [AXI_STRB_WIDTH_P-1 : 0] ing1_tstrb,
    input  wire  [AXI_KEEP_WIDTH_P-1 : 0] ing1_tkeep,
    input  wire                           ing1_tlast,
    input  wire    [AXI_ID_WIDTH_P-1 : 0] ing1_tid,
    input  wire  [AXI_DEST_WIDTH_P-1 : 0] ing1_tdest,
    input  wire  [AXI_USER_WIDTH_P-1 : 0] ing1_tuser,

    // -------------------------------------------------------------------------
    // Egress
    // -------------------------------------------------------------------------

    output logic                          egr_tvalid,
    input  wire                           egr_tready,
    output logic [AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
    output logic [AXI_STRB_WIDTH_P-1 : 0] egr_tstrb,
    output logic [AXI_KEEP_WIDTH_P-1 : 0] egr_tkeep,
    output logic                          egr_tlast,
    output logic   [AXI_ID_WIDTH_P-1 : 0] egr_tid,
    output logic [AXI_DEST_WIDTH_P-1 : 0] egr_tdest,
    output logic [AXI_USER_WIDTH_P-1 : 0] egr_tuser
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

    ing0_tready = '0;
    ing1_tready = '0;

    case (selected_master)

      NO_SELECTED_E: begin
        ing0_tready = '0;
        ing1_tready = '0;
        egr_tvalid  = '0;
        egr_tdata   = '0;
        egr_tstrb   = '0;
        egr_tkeep   = '0;
        egr_tlast   = '0;
        egr_tid     = '0;
        egr_tdest   = '0;
        egr_tuser   = '0;
      end

      MASTER0_E: begin
        egr_tvalid  = ing0_tvalid;
        ing0_tready = egr_tready;
        egr_tdata   = ing0_tdata;
        egr_tstrb   = ing0_tstrb;
        egr_tkeep   = ing0_tkeep;
        egr_tlast   = ing0_tlast;
        egr_tid     = ing0_tid;
        egr_tdest   = ing0_tdest;
        egr_tuser   = ing0_tuser;
      end

      MASTER1_E: begin
        egr_tvalid  = ing1_tvalid;
        ing1_tready = egr_tready;
        egr_tdata   = ing1_tdata;
        egr_tstrb   = ing1_tstrb;
        egr_tkeep   = ing1_tkeep;
        egr_tlast   = ing1_tlast;
        egr_tid     = ing1_tid;
        egr_tdest   = ing1_tdest;
        egr_tuser   = ing1_tuser;
      end

      default: begin
        ing0_tready = '0;
        ing1_tready = '0;
        egr_tvalid  = '0;
        egr_tdata   = '0;
        egr_tstrb   = '0;
        egr_tkeep   = '0;
        egr_tlast   = '0;
        egr_tid     = '0;
        egr_tdest   = '0;
        egr_tuser   = '0;
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
        selected_master        = NO_SELECTED_E;

        if (egr_tready) begin

          if (ing0_tvalid) begin      // Master 0
            next_rr_priority_state = BURST_MST_0;
          end
          else if (ing1_tvalid) begin // Master 1
            next_rr_priority_state = BURST_MST_1;
          end
        end
        else begin
          next_rr_priority_state = next_rr_priority_state;
        end
      end


      RR_PRIO_MST_1: begin
        selected_master        = NO_SELECTED_E;

        if (egr_tready) begin

          if (ing1_tvalid) begin      // Master 1
            next_rr_priority_state = BURST_MST_1;
          end
          else if (ing0_tvalid) begin // Master 0
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
        if (ing0_tvalid && ing0_tready && ing0_tlast) begin
          next_rr_priority_state = RR_PRIO_MST_1;
        end
        else begin
          next_rr_priority_state = next_rr_priority_state;
        end
      end

      BURST_MST_1: begin
        next_rr_priority_state = next_rr_priority_state;
        selected_master = MASTER1_E;
        if (ing1_tvalid && ing1_tready && ing1_tlast) begin
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
