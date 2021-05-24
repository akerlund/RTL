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
    parameter int MEM_SAMPLES_P    = -1,
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
    input  wire                           cmd_calculate_delay,
    input  wire          [N_BITS_P-1 : 0] cr_delay_time,
    input  wire          [N_BITS_P-1 : 0] cr_delay_gain
  );

  localparam int WORDS_IN_BUFFER_C = MEM_DATA_WIDTH_P / N_BITS_P;

  typedef enum {
    WR_WAIT_MEM_WR_REQ_E,
    WR_HS_WITH_MC_E,
    WR_DATA_TRANSFER_E,
  } wr_state_t;

  wr_state_t wr_state;


  logic [WORDS_IN_BUFFER_C-1 : 0] [N_BITS_P-1 : 0] wr_reg;
  logic          [$clog2(WORDS_IN_BUFFER_C)-1 : 0] wr_counter;

  // Memory write
  logic [MEM_ADDR_WIDTH_P-1 : 0] mem_wr_addr;
  logic         [N_BITS_P-1 : 0] mem_wr_data;
  logic                          mem_wr_valid;

  // Memory read
  logic [MEM_ADDR_WIDTH_P-1 : 0] mem_rd_addr;
  logic                          mem_rd_avalid;
  logic         [N_BITS_P-1 : 0] mem_rd_data;
  logic                          mem_rd_dvalid;

  // Ports
  assign awid    = AXI4_ID_P;
  assign awlen   = '0;
  assign awsize  = $clog2(N_BITS_P/8);
  assign awburst = VIP_AXI4_BURST_INCR_C;
  assign wdata   = wr_reg;
  assign wstrb   = '1;
  assign wlast   = '1;
  assign bready  = '1;

  // Write process
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_state   <= WR_WAIT_MEM_WR_REQ_E;
      wr_reg     <= '0;
      wr_counter <= '0;
      awvalid    <= '0;
      wvalid     <= '0;
    end
    else begin

      case (wr_state)

        WR_WAIT_MEM_WR_REQ_E: begin
          if (mem_wr_valid) begin
            wr_reg[wr_counter] <= mem_wr_data;
            if (wr_counter == '0) begin
              awaddr <= MEM_ADDR_WIDTH_P + mem_wr_addr;
            end else if (wr_counter == '1) begin
              wr_counter <= '0;
              wr_state   <= WR_HS_WITH_MC_E;
              awvalid    <= '1;
            end else begin
              wr_counter <= wr_counter + 1;
            end
          end
        end

        WR_HS_WITH_MC_E: begin
          if (mc.awready) begin
            wr_state <= WR_DATA_TRANSFER_E;
            awvalid  <= '0;
            wdata    <= wr_reg;
            wvalid   <= '1;
          end
        end

        WR_DATA_TRANSFER_E: begin
          if (mc.wready) begin
            wr_state <= WR_WAIT_MEM_WR_REQ_E;
            wvalid   <= '0;
          end
        end

      endcase
    end
  end


  iir_comb_core #(
    .N_BITS_P            ( N_BITS_P            ),
    .Q_BITS_P            ( Q_BITS_P            ),
    .MEM_ADDR_WIDTH_P    ( MEM_ADDR_WIDTH_P    ),
    .MEM_ADDR_P          ( MEM_ADDR_P          ),
    .MEM_SAMPLES_P       ( MEM_SAMPLES_P       ),
    .AXI4_ID_P           ( AXI4_ID_P           )
  ) iir_comb_core_i0 (

    // Clock and reset
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input

    // Data
    .x                   ( x                   ), // input
    .x_valid             ( x_valid             ), // input
    .y                   ( y                   ), // output
    .y_valid             ( y_valid             ), // output

    // Memory write
    .mem_wr_addr         ( mem_wr_addr         ), // output
    .mem_wr_data         ( mem_wr_data         ), // output
    .mem_wr_valid        ( mem_wr_valid        ), // output

    // Memory read
    .mem_rd_addr         ( mem_rd_addr         ), // output
    .mem_rd_avalid       ( mem_rd_avalid       ), // output
    .mem_rd_data         ( mem_rd_data         ), // input
    .mem_rd_dvalid       ( mem_rd_dvalid       ), // input

    // Configuration
    .cmd_calculate_delay ( cmd_calculate_delay ), // input
    .cr_delay_time       ( cr_delay_time       ), // input
    .cr_delay_gain       ( cr_delay_gain       )  // input
  );


  fifo #(
    .DATA_WIDTH_P         (                      ),
    .ADDR_WIDTH_P         (                      ),
    .MAX_REG_BYTES_P      (                      )
  ) fifo_i0 (
    // Clock and reset
    .clk                  ( clk                  ), // input
    .rst_n                ( rst_n                ), // input

    // Ingress
    .ing_enable           ( ing_enable           ), // input
    .ing_data             ( ing_data             ), // input
    .ing_full             ( ing_full             ), // output
    .ing_almost_full      ( ing_almost_full      ), // output

    // Egress
    .egr_enable           ( egr_enable           ), // input
    .egr_data             ( egr_data             ), // output
    .egr_empty            ( egr_empty            ), // output

    // Configuration and status registers
    .sr_fill_level        ( sr_fill_level        ), // output
    .sr_max_fill_level    ( sr_max_fill_level    ), // output
    .cr_almost_full_level ( cr_almost_full_level ), // input
  );



endmodule

`default_nettype wire
