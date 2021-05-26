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

module iir_comb_core #(
    parameter int N_BITS_P         = -1,
    parameter int Q_BITS_P         = -1,
    parameter int MEM_BASE_ADDR_P  = -1,
    parameter int MEM_HIGH_ADDR_P  = -1,
    parameter int MEM_ADDR_WIDTH_P = -1,
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

    // Memory write
    output logic [MEM_ADDR_WIDTH_P-1 : 0] mem_wr_addr,
    output logic         [N_BITS_P-1 : 0] mem_wr_data,
    output logic                          mem_wr_valid,

    // Memory read
    output logic [MEM_ADDR_WIDTH_P-1 : 0] mem_rd_addr,
    output logic                          mem_rd_avalid,
    input  wire          [N_BITS_P-1 : 0] mem_rd_data,
    input  wire                           mem_rd_dvalid,
    output logic                          mem_rd_dready,

    // Configuration
    input  wire                           cmd_fir_calculate_delay,
    input  wire          [N_BITS_P-1 : 0] cr_fir_delay_time,
    input  wire          [N_BITS_P-1 : 0] cr_fir_delay_gain
  );

  typedef enum {
    DELAY_CALC_IDLE_E,
    DELAY_CALC_DIFF_E,
    DELAY_CALC_ADDR_NEG_E,
    DELAY_CALC_ADDR_POS_E
  } delay_state_t;

  typedef enum {
    MEMORY_RD_REQ_E,
    MEMORY_RD_RES_E,
    WAIT_FOR_X_VALID_E,
    MEMORY_WR_REQ_E,
    MEMORY_WR_RES_E
  } fir_state_t;

  delay_state_t delay_state;
  fir_state_t   fir_state;

  // Delay calculation
  logic                [N_BITS_P-1 : 0] cr_fir_delay_time_r0;
  logic          [MEM_ADDR_WIDTH_P : 0] rd_addr_r0;
  logic signed           [N_BITS_P : 0] delay_delta;
  logic signed           [N_BITS_P : 0] delay_diff;

  // FIR calculation
  logic        [MEM_ADDR_WIDTH_P-1 : 0] wr_addr;
  logic        [MEM_ADDR_WIDTH_P-1 : 0] rd_addr;
  logic signed         [N_BITS_P-1 : 0] y_delay;

  // Delay calculation
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      delay_state      <= DELAY_CALC_IDLE_E;
      cr_fir_delay_time_r0 <= '0;
      rd_addr          <= '0;
      rd_addr_r0       <= '0;
      delay_delta      <= '0;
      delay_diff       <= '0;
    end
    else begin

      if (fir_state == MEMORY_RD_REQ_E) begin
        rd_addr <= rd_addr + 1;
      end

      case (delay_state)

        DELAY_CALC_IDLE_E: begin
          if (cmd_fir_calculate_delay) begin
            delay_state      <= DELAY_CALC_DIFF_E;
            delay_delta      <= cr_fir_delay_time_r0 - cr_fir_delay_time;
            cr_fir_delay_time_r0 <= cr_fir_delay_time;
          end
        end

        DELAY_CALC_DIFF_E: begin
          // More delay, decrease the read pointer
          if (delay_delta < 0) begin
            delay_state <= DELAY_CALC_ADDR_NEG_E;
            delay_diff  <= {1'b0, rd_addr} - {'0, delay_delta};
          end
          // Less delay, increase the read pointer
          else begin
            delay_state <= DELAY_CALC_ADDR_POS_E;
            delay_diff  <= {1'b0, rd_addr} + {'0, delay_delta};
          end
        end

        DELAY_CALC_ADDR_NEG_E: begin
          delay_state <= DELAY_CALC_IDLE_E;
          if (delay_diff < 0) begin
            rd_addr_r0 <= {1'b0, {MEM_ADDR_WIDTH_P{1'b1}}} + {'1, delay_diff};
          end else begin
            rd_addr_r0 <= {'0, delay_diff};
          end
        end

        DELAY_CALC_ADDR_POS_E: begin
          delay_state <= DELAY_CALC_IDLE_E;
          if (delay_diff >= 0) begin
            rd_addr_r0 <= {'0, delay_diff} - {1'b0, {MEM_ADDR_WIDTH_P{1'b1}}};
          end else begin
            rd_addr_r0 <= {'0, delay_diff};
          end
        end

      endcase
    end
  end


  // Filter
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      fir_state     <= MEMORY_RD_REQ_E;
      wr_addr       <= MEM_BASE_ADDR_P;
      mem_wr_addr   <= '0;
      mem_wr_valid  <= '0;
      mem_wr_data   <= '0;
      mem_rd_addr   <= '0;
      mem_rd_avalid <= '0;
      mem_rd_dready <= '0;
      y             <= '0;
      y_valid       <= '0;
    end
    else begin

      mem_rd_avalid  <= '0;
      y_valid      <= '0;
      mem_wr_valid <= '0;

      case (fir_state)

        MEMORY_RD_REQ_E: begin
          fir_state     <= MEMORY_RD_RES_E;
          mem_rd_addr   <= rd_addr;
          mem_rd_avalid <= '1;
          mem_rd_dready <= '1;
        end

        MEMORY_RD_RES_E: begin
          if (mem_rd_dvalid) begin
            mem_rd_dready <= '0;
            fir_state     <= WAIT_FOR_X_VALID_E;
            y_delay       <= (mem_rd_data * cr_fir_delay_gain) >> Q_BITS_P;
          end
        end

        WAIT_FOR_X_VALID_E: begin
          if (x_valid) begin
            fir_state <= MEMORY_WR_REQ_E;
            y         <= x + y_delay;
            y_valid   <= '1;
          end
        end

        MEMORY_WR_REQ_E: begin
          fir_state    <= MEMORY_RD_REQ_E;
          mem_wr_addr  <= wr_addr;
          mem_wr_valid <= '1;
          mem_wr_data  <= y;
          wr_addr      <= wr_addr + 1;
        end

      endcase
    end
  end

endmodule

`default_nettype wire
