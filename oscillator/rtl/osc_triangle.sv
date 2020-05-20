////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module osc_triangle #(
    parameter int triangle_width_p  = -1
    parameter int counter_width_p = -1
  )(
    input  wire                         clk,
    input  wire                         rst_n,

    output logic [triangle_width_p-1:0] osc_triangle,

    input  wire  [counter_width_p-1:0]  cr_frequency,
    input  wire  [counter_width_p-1:0]  cr_granularity
  );

  localparam logic signed [counter_width_p-1:0] triangle_high_c = {1'b0,(counter_width_p-1){1'b1}};
  localparam logic signed [counter_width_p-1:0] triangle_low_c  = {1'b1,(counter_width_p-1){1'b0}};

  typedef enum {
    reload_e = 0,
    counting_e
  } state_t;

  typedef enum {
    count_up_e = 0,
    count_down_e
  } counter_direction_t;

  logic [counter_width_p-1:0] frequency;
  logic [counter_width_p-1:0] granularity;

  logic [counter_width_p-1:0] osc_counter;

  state_t             state;
  counter_direction_t counter_direction;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      osc_triangle      <= '0;
      frequency         <= '0;
      granularity       <= '0;
      osc_counter       <= '0;
      state             <= reload_e;
      counter_direction <= count_up_e;
    end
    else begin

      case (state)

        reload_e: begin

          frequency         <= cr_frequency >> 1;
          osc_triangle      <= triangle_low_c;
          state             <= counting_e;
          osc_counter       <= '0;
          counter_direction <= count_up_e;
        end


        counting_e: begin

          // Counting down
          if (counter_direction == count_down_e) begin

            osc_counter <= osc_counter + 1;
            if (osc_counter >= frequency-1) begin
              osc_counter <= '0;
              state       <= reload_e;
            end

            if (osc_counter == cr_granularity) begin
              osc_triangle <= osc_triangle - 1;
            end
          end

          // Counting up
          else begin

            osc_counter <= osc_counter + 1;
            if (osc_counter >= frequency-1) begin
              osc_counter       <= '0;
              counter_direction <= count_down_e;
            end

            if (osc_counter == cr_granularity) begin
              osc_triangle <= osc_triangle + 1;
            end
          end
        end

      endcase

    end
endmodule

`default_nettype wire