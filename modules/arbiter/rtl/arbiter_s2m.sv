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
// This arbiter uses the 'tdest' field from the slave to select which
// connected master's tvalid signal to assert.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module arbiter_s2m #(
    parameter int NR_OF_MASTERS_P = -1,
    parameter int DATA_WIDTH_P    = -1,
    parameter int ID_WIDTH_P      = -1
  )(
    // Clock and reset
    input  wire                                               clk,
    input  wire                                               rst_n,

    // -------------------------------------------------------------------------
    // Slave
    // -------------------------------------------------------------------------

    input  wire                                               slv_valid,
    output logic                                              slv_ready,
    input  wire                          [DATA_WIDTH_P-1 : 0] slv_data,
    input  wire                                               slv_last,
    input  wire                            [ID_WIDTH_P-1 : 0] slv_id,

    // -------------------------------------------------------------------------
    // Masters
    // -------------------------------------------------------------------------

    output logic [NR_OF_MASTERS_P-1 : 0]                      mst_valid,
    input  wire  [NR_OF_MASTERS_P-1 : 0]                      mst_ready,
    output logic                         [DATA_WIDTH_P-1 : 0] mst_data,
    output logic                                              mst_last,
    output logic                           [ID_WIDTH_P-1 : 0] mst_id
  );

  typedef enum {
    WAIT_SLV_VALID_E,
    WAIT_SLV_LAST_E
  } arbiter_state_t;

  arbiter_state_t arbiter_state;

  logic [$clog2(NR_OF_MASTERS_P)-1 : 0] mux_address;
  logic                                 output_enable;

  // FSM
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      arbiter_state <= WAIT_SLV_VALID_E;
      mux_address   <= '0;
      output_enable <= '0;
    end
    else begin

      case (arbiter_state)

        WAIT_SLV_VALID_E: begin

          if (slv_valid) begin

            arbiter_state <= WAIT_SLV_LAST_E;
            mux_address   <= slv_id;
            output_enable <= '1;

          end
        end


        WAIT_SLV_LAST_E: begin

          if (slv_last && slv_valid && slv_ready) begin
            arbiter_state <= WAIT_SLV_VALID_E;
            output_enable <= '0;
          end

        end

      endcase
    end
  end

  // Interface muxing
  always_comb begin

    slv_ready = '0;
    mst_valid = '0;

    mst_data  = slv_data;
    mst_last  = slv_last;
    mst_id    = slv_id;

    if (!output_enable) begin

        slv_ready = '0;
        mst_valid = '0;

    end
    else begin

      slv_ready              = mst_ready[mux_address];
      mst_valid[mux_address] = slv_valid;

    end

  end

endmodule

`default_nettype wire
