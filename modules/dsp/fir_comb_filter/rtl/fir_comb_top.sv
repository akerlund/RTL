////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
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
// y(n) = x(n) + g*x(n - t/fs)
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module iir_comb_top #(
    parameter int N_BITS_P         = -1,
    parameter int Q_BITS_P         = -1,
    parameter int MEM_BASE_ADDR_P  = -1,
    parameter int MEM_HIGH_ADDR_P  = -1,
    parameter int MEM_ADDR_WIDTH_P = -1,
    parameter int MEM_DATA_WIDTH_P = -1,
    parameter int AXI4_ID_P        = -1
  )(
    // Clock and reset
    input  wire                           clk,
    input  wire                           rst_n,

    // Data
    input  wire   signed [N_BITS_P-1 : 0] x,
    input  wire                           x_valid,
    output logic  signed [N_BITS_P-1 : 0] y,
    output logic                          y_valid,

    // AXI4 memory
    axi4_if.master                        mc,

    // Configuration
    input  wire                           cmd_fir_calculate_delay,
    input  wire          [N_BITS_P-1 : 0] cr_fir_delay_time,
    input  wire          [N_BITS_P-1 : 0] cr_fir_delay_gain
  );

  localparam int WORDS_IN_BUFFER_C    = MEM_DATA_WIDTH_P / N_BITS_P;
  localparam int PREFETCH_BYTE_SIZE_C = 2**6;
  localparam int FIFO_ADDR_WIDTH_C    = $clog2(PREFETCH_BYTE_SIZE_C / (N_BITS_P / 8));

  typedef enum {
    WR_WAIT_MEM_WR_REQ_E,
    WR_HS_WITH_MC_E,
    WR_DATA_TRANSFER_E
  } wr_state_t;

  typedef enum {
    RD_WAIT_MEM_RD_REQ_E,
    RD_HS_WITH_MC_E,
    RD_DATA_TRANSFER_E,
    RD_WRITE_TO_FIFO_E
  } rd_state_t;

  wr_state_t wr_state;
  rd_state_t rd_state;



  // Memory write
  logic [MEM_ADDR_WIDTH_P-1 : 0] mem_wr_addr;
  logic         [N_BITS_P-1 : 0] mem_wr_data;
  logic                          mem_wr_valid;

  // Memory read
  logic [MEM_ADDR_WIDTH_P-1 : 0] mem_rd_addr;
  logic                          mem_rd_avalid;
  logic         [N_BITS_P-1 : 0] mem_rd_data;
  logic                          mem_rd_dvalid;
  logic                          mem_rd_dready;

  // Write process
  logic [WORDS_IN_BUFFER_C-1 : 0] [N_BITS_P-1 : 0] wr_r0;
  logic          [$clog2(WORDS_IN_BUFFER_C)-1 : 0] wr_counter;

  // Read process
  logic [1 : 0] rd_counter; // TODO: Width
  logic [WORDS_IN_BUFFER_C-1 : 0] [N_BITS_P-1 : 0] rdata_r0;
  logic                                            rlast_r0;

  // FIFO
  logic                  ing_enable;
  logic [N_BITS_P-1 : 0] ing_data;
  logic                  egr_enable;
  logic [N_BITS_P-1 : 0] egr_data;
  logic                  egr_empty;

  // Write ports
  assign mc.awid    = AXI4_ID_P;
  assign mc.awlen   = '0;
  assign mc.awsize  = $clog2(N_BITS_P/8);
  assign mc.awburst = 2'b01;
  assign mc.wdata   = wr_r0;
  assign mc.wstrb   = '1;
  assign mc.wlast   = '1;
  assign mc.bready  = '1;

  // Read ports
  assign mc.arid   = AXI4_ID_P;
  assign mc.arlen  = PREFETCH_BYTE_SIZE_C / (MEM_DATA_WIDTH_P/8) - 1;
  assign mc.arsize = $clog2(N_BITS_P/8);

  // Memory read response input
  assign mem_rd_data   = egr_data;
  assign mem_rd_dvalid = egr_enable;

  // FIFO
  assign egr_enable = !egr_empty && mem_rd_dready;

  // Write process
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_state   <= WR_WAIT_MEM_WR_REQ_E;
      wr_r0      <= '0;
      wr_counter <= '0;
      mc.awaddr  <= '0;
      mc.awvalid <= '0;
      mc.wvalid  <= '0;
    end
    else begin

      case (wr_state)

        WR_WAIT_MEM_WR_REQ_E: begin
          if (mem_wr_valid) begin
            wr_counter <= wr_counter + 1;
            wr_r0[wr_counter] <= mem_wr_data;
            if (wr_counter == '0) begin
              mc.awaddr <= MEM_ADDR_WIDTH_P + mem_wr_addr;
            end else if (wr_counter == '1) begin
              wr_counter <= '0;
              wr_state   <= WR_HS_WITH_MC_E;
              mc.awvalid <= '1;
            end
          end
        end

        WR_HS_WITH_MC_E: begin
          if (mc.awready) begin
            wr_state   <= WR_DATA_TRANSFER_E;
            mc.awvalid <= '0;
            mc.wvalid  <= '1;
          end
        end

        WR_DATA_TRANSFER_E: begin
          if (mc.wready) begin
            wr_state  <= WR_WAIT_MEM_WR_REQ_E;
            mc.wvalid <= '0;
          end
        end

      endcase
    end
  end


  // Read process
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_state   <= RD_WAIT_MEM_RD_REQ_E;
      rd_counter <= '0;
      mc.araddr  <= '0;
      mc.arvalid <= '0;
      mc.rready  <= '0;
      rlast_r0   <= '0;
    end
    else begin

      ing_enable <= '0;

      case (rd_state)

        RD_WAIT_MEM_RD_REQ_E: begin
          if (mem_rd_avalid) begin
            if (mem_rd_addr[3 : 0] == '0) begin // TODO: Hmm?
              rd_state   <= RD_HS_WITH_MC_E;
              mc.araddr  <= mem_rd_addr;
              mc.arvalid <= '1;
            end
          end
        end

        RD_HS_WITH_MC_E: begin
          if (mc.arready) begin
            rd_state   <= RD_DATA_TRANSFER_E;
            mc.arvalid <= '0;
            mc.rready  <= '1;
          end
        end

        RD_DATA_TRANSFER_E: begin
          if (mc.rvalid) begin
            rd_state  <= RD_WRITE_TO_FIFO_E;
            rdata_r0  <= mc.rdata;
            rlast_r0  <= mc.rlast;
            mc.rready <= '0;
          end
        end

        RD_WRITE_TO_FIFO_E: begin

          ing_enable <= '1;
          ing_data   <= rdata_r0[rd_counter];

          if (rd_counter == 3) begin // TODO: Hmm?
            rd_counter <= '0;
            if (rlast_r0) begin
              rlast_r0 <= '0;
              rd_state <= RD_WAIT_MEM_RD_REQ_E;
            end else begin
              mc.rready <= '1;
              rd_state  <= RD_DATA_TRANSFER_E;
            end
          end else begin
            rd_counter <= rd_counter + 1;
          end
        end

      endcase
    end
  end


  iir_comb_core #(
    .N_BITS_P                ( N_BITS_P                ),
    .Q_BITS_P                ( Q_BITS_P                ),
    .MEM_BASE_ADDR_P         ( MEM_BASE_ADDR_P         ),
    .MEM_HIGH_ADDR_P         ( MEM_HIGH_ADDR_P         ),
    .MEM_ADDR_WIDTH_P        ( MEM_ADDR_WIDTH_P        ),
    .AXI4_ID_P               ( AXI4_ID_P               )
  ) iir_comb_core_i0 (

    // Clock and reset
    .clk                     ( clk                     ), // input
    .rst_n                   ( rst_n                   ), // input

    // Data
    .x                       ( x                       ), // input
    .x_valid                 ( x_valid                 ), // input
    .y                       ( y                       ), // output
    .y_valid                 ( y_valid                 ), // output

    // Memory write
    .mem_wr_addr             ( mem_wr_addr             ), // output
    .mem_wr_data             ( mem_wr_data             ), // output
    .mem_wr_valid            ( mem_wr_valid            ), // output

    // Memory read
    .mem_rd_addr             ( mem_rd_addr             ), // output
    .mem_rd_avalid           ( mem_rd_avalid           ), // output
    .mem_rd_data             ( mem_rd_data             ), // input
    .mem_rd_dvalid           ( mem_rd_dvalid           ), // input
    .mem_rd_dready           ( mem_rd_dready           ), // output

    // Configuration
    .cmd_fir_calculate_delay ( cmd_fir_calculate_delay ), // input
    .cr_fir_delay_time       ( cr_fir_delay_time       ), // input
    .cr_fir_delay_gain       ( cr_fir_delay_gain       )  // input
  );


  fifo #(
    .DATA_WIDTH_P         ( N_BITS_P          ),
    .ADDR_WIDTH_P         ( FIFO_ADDR_WIDTH_C )
  ) fifo_i0 (
    // Clock and reset
    .clk                  ( clk               ), // input
    .rst_n                ( rst_n             ), // input

    // Ingress
    .ing_enable           ( ing_enable        ), // input
    .ing_data             ( ing_data          ), // input
    .ing_full             (                   ), // output
    .ing_almost_full      (                   ), // output

    // Egress
    .egr_enable           ( egr_enable        ), // input
    .egr_data             ( egr_data          ), // output
    .egr_empty            ( egr_empty         ), // output

    // Configuration and status registers
    .sr_fill_level        (                   ), // output
    .sr_max_fill_level    (                   ), // output
    .cr_almost_full_level ( '0                ) // input
  );

endmodule

`default_nettype wire
