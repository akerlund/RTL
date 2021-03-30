////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module delay_enable #(
    parameter int COUNTER_WIDTH_P = -1
  )(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          reset_counter_n,
    input  wire                          start,
    output logic                         delay_out,
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_delay_period
  );

  logic [COUNTER_WIDTH_P-1 : 0] delay_counter;
  logic                         delaying;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      delay_out     <= '0;
      delaying      <= '0;
      delay_counter <= '0;
    end
    else begin

      delay_out <= '0;

      if (!reset_counter_n) begin
        delay_counter <= '0;
      end
      else if (delaying == '0 && start == '1) begin
        delaying      <= '1;
        delay_counter <= '0;
      end
      else begin
        if (delaying == '1) begin
          if (delay_counter >= cr_delay_period-1) begin
            delaying      <= '0;
            delay_counter <= '0;
            delay_out     <= '1;
          end
          else begin
            delay_counter <= delay_counter + 1;
          end
        end
      end
    end
  end

endmodule

`default_nettype wire
