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

module switch_core #(
    parameter int NR_OF_DEBOUNCE_CLKS_P = -1
  )(
    input  wire  clk,
    input  wire  rst_n,
    input  wire  switch_in_pin,
    output logic switch_out
  );

  logic synchronized_switch;
  logic synchronized_switch_d0;

  io_synchronizer io_synchronizer_i0 (
    .clk         ( clk                 ),
    .rst_n       ( rst_n               ),
    .bit_ingress ( switch_in_pin       ),
    .bit_egress  ( synchronized_switch )
  );

  // Debouncer
  always_ff @( posedge clk or negedge rst_n ) begin
    int debounce_counter_v;
    if (!rst_n) begin
      switch_out             <= '0;
      synchronized_switch_d0 <= '0;
      debounce_counter_v     <= '0;
    end
    else begin
      debounce_counter_v <= '0;
       if (synchronized_switch_d0 != synchronized_switch) begin
        if (debounce_counter_v == NR_OF_DEBOUNCE_CLKS_P) begin
          synchronized_switch_d0 <= switch_out;
          debounce_counter_v     <= '0;
          switch_out             <= switch_out;
        end
        else begin
          debounce_counter_v     <= debounce_counter_v + 1;
        end
      end
    end
  end

endmodule

`default_nettype wire
