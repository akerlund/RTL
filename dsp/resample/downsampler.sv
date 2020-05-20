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

module downsampler #(
    parameter int  data_width_p       = -1,
    parameter int  decimation_M_p     = -1
  )(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     x_valid,
    input  wire  [data_width_p-1:0] x,
    output logic                    y_valid,
    output logic [data_width_p-1:0] y
  );

  localparam logic [$log2(decimation_M_p)-1 : 0] decimation_M_c = decimation_M_p;

  logic [$log2(decimation_M_p)-1 : 0] sample_counter;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      y_valid        <= '0;
      y              <= '0;
      sample_counter <= '0;
    end
    else begin

      y_valid <= '0;
      y       <= '0;

      if (x_valid) begin
        if (sample_counter == 0) begin
          y_valid <= 1;
          y       <= x;
        end
        else if (sample_counter == decimation_M_p) begin
          sample_counter <= '0;
        end
        else begin
          sample_counter <= sample_counter + 1;
        end
      end
    end
  end

endmodule

`default_nettype wire