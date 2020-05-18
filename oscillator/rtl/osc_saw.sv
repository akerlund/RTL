////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module osc_saw #(
    parameter int SAW_WIDTH_P     = -1
    parameter int COUNTER_WIDTH_P = -1
  )(
    input  wire                          clk,
    input  wire                          rst_n,

    output logic     [SAW_WIDTH_P-1 : 0] osc_saw,
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_frequency
  );

  localparam logic [COUNTER_WIDTH_P-1 : 0] SAW_HIGH_C = {1'b0, {(COUNTER_WIDTH_P-1){1'b1}}};
  localparam logic [COUNTER_WIDTH_P-1 : 0] SAW_LOW_C  = {1'b1, {(COUNTER_WIDTH_P-1){1'b0}}};

  typedef enum {
    RELOAD_E = 0,
    COUNTING_E
  } state_t;

  state_t state;

  logic [COUNTER_WIDTH_P-1 : 0] frequency;
  logic [COUNTER_WIDTH_P-1 : 0] osc_counter;



  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      osc_saw     <= '0;
      frequency   <= '0;
      osc_counter <= '0;
      state       <= RELOAD_E;
    end
    else begin

      case (state)

        RELOAD_E: begin

          frequency   <= cr_frequency;
          osc_saw     <= SAW_HIGH_C;
          state       <= COUNTING_E;
          osc_counter <= '0;
        end


        COUNTING_E: begin

          osc_counter <= osc_counter + 1;

          if (osc_counter == duty_cycle-1) begin
            osc_saw <= SAW_LOW_C;
          end
          else if (osc_counter == frequency-1) begin
            state   <= RELOAD_E;
          end
          else begin
          end
        end

      endcase

    end
  end

endmodule

`default_nettype wire
