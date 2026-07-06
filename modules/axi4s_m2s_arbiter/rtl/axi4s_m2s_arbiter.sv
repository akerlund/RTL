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

  localparam int unsigned MST_SEL_WIDTH_C = $clog2(NR_OF_MASTERS_P);
  localparam logic [MST_SEL_WIDTH_C-1 : 0] LAST_MST_IDX_C = MST_SEL_WIDTH_C'(NR_OF_MASTERS_P - 1);

  initial begin
    if (NR_OF_MASTERS_P < 2) begin
      $fatal(1, "axi4s_m2s_arbiter: NR_OF_MASTERS_P must be >= 2 (got %0d)", NR_OF_MASTERS_P);
    end
  end

  typedef enum {
    FIND_MST_TVALID_E,
    WAIT_MST_TLAST_E
  } arbiter_state_t;

  arbiter_state_t arbiter_state;

  logic [MST_SEL_WIDTH_C-1 : 0] rotating_mst;
  logic [MST_SEL_WIDTH_C-1 : 0] mux_address;
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

          if (rotating_mst == LAST_MST_IDX_C) begin
            rotating_mst <= '0;
          end
          else begin
            rotating_mst <= rotating_mst + 1;
          end

          if (mst_tvalid[rotating_mst]) begin
            arbiter_state <= WAIT_MST_TLAST_E;
            mux_address   <= rotating_mst;
            output_enable <= '1;
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

    if (output_enable) begin

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
