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

module clock_enable #(
    parameter int COUNTER_WIDTH_P = -1
  )(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          reset_counter_n,
    output logic                         enable,
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_enable_period
  );

  logic [COUNTER_WIDTH_P-1 : 0] clock_enable_counter;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      enable               <= '0;
      clock_enable_counter <= '0;
    end
    else begin

      enable               <= '0;
      clock_enable_counter <= clock_enable_counter + 1;

      if (!reset_counter_n) begin
        clock_enable_counter <= '0;
      end
      else if (clock_enable_counter >= cr_enable_period-1) begin
        enable               <= '1;
        clock_enable_counter <= '0;
      end

    end
  end

endmodule

`default_nettype wire
