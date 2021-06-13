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
//
///////////////////////////////////////////////////////////////////////////////

module arbiter_m2s #(
    parameter int NR_OF_MASTERS_P = -1,
    parameter int DATA_WIDTH_P    = -1,
    parameter int ID_WIDTH_P      = -1
  )(

    // Clock and reset
    input  wire                                               clk,
    input  wire                                               rst_n,

    // -------------------------------------------------------------------------
    // Masters
    // -------------------------------------------------------------------------

    input wire   [NR_OF_MASTERS_P-1 : 0]                      mst_valid,
    output logic [NR_OF_MASTERS_P-1 : 0]                      mst_ready,
    input wire   [NR_OF_MASTERS_P-1 : 0] [DATA_WIDTH_P-1 : 0] mst_data,
    input wire   [NR_OF_MASTERS_P-1 : 0]                      mst_last,
    input wire   [NR_OF_MASTERS_P-1 : 0]   [ID_WIDTH_P-1 : 0] mst_id,

    // -------------------------------------------------------------------------
    // Slave
    // -------------------------------------------------------------------------

    output logic                                              slv_valid,
    input wire                                                slv_ready,
    output logic                         [DATA_WIDTH_P-1 : 0] slv_data,
    output logic                                              slv_last,
    output logic                           [ID_WIDTH_P-1 : 0] slv_id
  );

  localparam logic [$clog2(NR_OF_MASTERS_P)-1 : 0] NR_OF_MASTERS_C = NR_OF_MASTERS_P;

  typedef enum {
    FIND_MST_VALID_E,
    WAIT_MST_LAST_E
  } arbiter_state_t;

  arbiter_state_t arbiter_state;

  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] rotating_mst;
  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] mux_address;
  logic                                 output_enable;

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      arbiter_state <= FIND_MST_VALID_E;
      rotating_mst  <= '0;
      mux_address   <= '0;
      output_enable <= '0;
    end
    else begin

      case (arbiter_state)

        FIND_MST_VALID_E: begin

          if (slv_ready) begin

            if (rotating_mst == NR_OF_MASTERS_C-1) begin
              rotating_mst <= '0;
            end
            else begin
              rotating_mst <= rotating_mst + 1;
            end

            if (mst_valid[rotating_mst]) begin
              arbiter_state <= WAIT_MST_LAST_E;
              mux_address   <= rotating_mst;
              output_enable <= '1;
            end

          end
        end


        WAIT_MST_LAST_E: begin

          if (slv_last && slv_valid && slv_ready) begin
            arbiter_state <= FIND_MST_VALID_E;
            output_enable <= '0;
          end

        end

      endcase
    end
  end


  // MUX
  always_comb begin

    slv_valid = '0;
    slv_data  = '0;
    slv_last  = '0;
    slv_id    = '0;
    mst_ready = '0;


    if (!output_enable) begin

      slv_valid = '0;
      slv_data  = slv_data;
      slv_last  = slv_last;
      slv_id    = slv_id;
      mst_ready = '0;

    end
    else begin

      slv_valid = mst_valid [mux_address];
      slv_data  = mst_data  [mux_address];
      slv_last  = mst_last  [mux_address];
      slv_id    = mst_id    [mux_address];

      mst_ready[mux_address] = slv_ready;

    end

  end

endmodule
