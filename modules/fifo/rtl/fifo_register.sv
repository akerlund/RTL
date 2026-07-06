////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module fifo_register #(
    parameter int DATA_WIDTH_P = 64,
    parameter int ADDR_WIDTH_P = 5
  )(
    input  wire                       clk,
    input  wire                       rst_n,

    input  wire                       ing_enable,
    input  wire  [DATA_WIDTH_P-1 : 0] ing_data,
    output logic                      ing_full,

    input  wire                       egr_enable,
    output logic [DATA_WIDTH_P-1 : 0] egr_data,
    output logic                      egr_empty,

    output logic   [ADDR_WIDTH_P : 0] sr_fill_level
  );

  logic                      write_enable;
  logic [ADDR_WIDTH_P-1 : 0] write_address;
  logic                      read_enable;
  logic [ADDR_WIDTH_P-1 : 0] read_address;

  assign read_enable  = egr_enable && !egr_empty;
  assign write_enable = ing_enable && (!ing_full || read_enable);

  assign ing_full = sr_fill_level[ADDR_WIDTH_P];

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      write_address <= '0;
      read_address  <= '0;
      sr_fill_level <= '0;
      egr_empty     <= '1;

    end
    else begin

      if (write_enable) begin

        write_address <= write_address + 1;

        if (read_enable) begin
          read_address <= read_address + 1;
        end
        else begin
          egr_empty     <= '0;
          sr_fill_level <= sr_fill_level + 1;
        end

      end
      else if (read_enable) begin

        read_address  <= read_address  + 1;
        sr_fill_level <= sr_fill_level - 1;

        if (sr_fill_level == 1) begin
          egr_empty <= '1;
        end

      end
    end
  end

  reg_sp_rf #(
    .DATA_WIDTH_P    ( DATA_WIDTH_P  ),
    .ADDR_WIDTH_P    ( ADDR_WIDTH_P  )
  ) reg_sp_rf_i0 (
    .clk             ( clk           ), // input
    .port_a_write_en ( write_enable  ), // input
    .port_a_address  ( write_address ), // input
    .port_a_data_in  ( ing_data      ), // input
    .port_b_address  ( read_address  ), // input
    .port_b_data_out ( egr_data      )  // output
  );

  initial begin
    if (DATA_WIDTH_P <= 0) begin
      $error("DATA_WIDTH_P must be greater than zero");
    end

    if (ADDR_WIDTH_P <= 0) begin
      $error("ADDR_WIDTH_P must be greater than zero");
    end
  end

endmodule

`default_nettype wire
