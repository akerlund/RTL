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
    parameter int CLK_FREQUENCY_P = -1,
    parameter int ENA_FREQUENCY_P = -1
  )(
    input  wire  clk,
    input  wire  rst_n,
    output logic enable
  );

  localparam int NR_OF_CLK_PERIODS_C = CLK_FREQUENCY_P / ENA_FREQUENCY_P;

  localparam logic [$clog2(NR_OF_CLK_PERIODS_C)-1 : 0] clock_enable_counter;


  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      enable               <= '0;
      clock_enable_counter <= '0;
    end
    else begin
      enable <= '0;
      if (clock_enable_counter >= NR_OF_CLK_PERIODS_C-1) begin
        enable               <= 1;
        clock_enable_counter <= '0;
      end
      else begin
        clock_enable_counter <= clock_enable_counter + 1;
      end
    end
  end

endmodule

`default_nettype wire
