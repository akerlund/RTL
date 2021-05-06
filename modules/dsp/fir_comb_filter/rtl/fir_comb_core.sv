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
    parameter int MEM_ADDR_WIDTH_P = -1,
    parameter int MEM_ADDR_P       = -1,
    parameter int MEM_SAMPLES_P    = -1,
    parameter int AXI4_ID_P        = -1
  )(
    // Clock and reset
    input  wire                          clk,
    input  wire                          rst_n,

    // MC
    axi4_if.master                       mem,

    // Data
    input  wire  signed [N_BITS_P-1 : 0] x,
    input  wire                          x_valid,
    output logic signed [N_BITS_P-1 : 0] y,
    output logic                         y_valid,

    // Configuration
    input  wire  [N_BITS_P-1 : 0] cr_fs,
    input  wire  [N_BITS_P-1 : 0] cr_delay_time
  );

  typedef enum {
    MEMORY_RD_REQ_E,
    MEMORY_RD_RES_E,
    WAIT_FOR_X_VALID_E,
    MULTIPLY_E,
    ADD_E,
    MEMORY_WR_REQ_E,
    MEMORY_WR_RES_E
  } fir_state_t;

  fir_state_t fir_state;

  logic [$clog2(MEM_SAMPLES_P)-1 : 0] n;
  logic      [MEM_ADDR_WIDTH_P-1 : 0] wr_addr;
  logic      [MEM_ADDR_WIDTH_P-1 : 0] rd_addr;

  assign mem.awid = AXI4_ID_P;
  assign mem.arid = AXI4_ID_P;

  always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      fir_state <= MEMORY_RD_REQ_E;
      wr_addr   <= MEM_ADDR_P;
      rd_addr   <= '0;
    end
    else begin

      case (fir_state)

        MEMORY_RD_REQ_E: begin

          mem.araddr <= wr_addr - cr_delay_time;

        end

      endcase

    end
  end

endmodule

`default_nettype wire
