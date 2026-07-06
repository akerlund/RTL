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

module ram_lint_top (
    input wire clk
  );

  logic [31:0] sp_data_egress;
  logic [31:0] sp_bw_data_egress;
  logic [31:0] sdp_data_egress;
  logic [31:0] sdp_bw_data_egress;
  logic [31:0] sdp2c_data_egress;
  logic [31:0] tdp_a_data_egress;
  logic [31:0] tdp_b_data_egress;
  logic [31:0] tdp_bw_a_data_egress;
  logic [31:0] tdp_bw_b_data_egress;

  ram_sp #(
    .DATA_WIDTH_P ( 32 ),
    .ADDR_WIDTH_P ( 5  )
  ) ram_sp_i0 (
    .clk          ( clk            ),
    .enable       ( 1'b0           ),
    .write_enable ( 1'b0           ),
    .data_ingress ( 32'h0          ),
    .address      ( 5'h0           ),
    .data_egress  ( sp_data_egress )
  );

  ram_sp_bw #(
    .BYTE_WIDTH_P ( 4 ),
    .ADDR_WIDTH_P ( 5 )
  ) ram_sp_bw_i0 (
    .clk          ( clk               ),
    .enable       ( 1'b0              ),
    .write_enable ( 1'b0              ),
    .data_ingress ( 32'h0             ),
    .address      ( 5'h0              ),
    .write_mask   ( 4'h0              ),
    .data_egress  ( sp_bw_data_egress )
  );

  ram_sdp #(
    .DATA_WIDTH_P     ( 32 ),
    .ADDR_WIDTH_P     ( 5  )
  ) ram_sdp_i0 (
    .clk              ( clk             ),
    .port_a_enable    ( 1'b0            ),
    .port_a_write_enable ( 1'b0         ),
    .port_a_data_ing  ( 32'h0           ),
    .port_a_address   ( 5'h0            ),
    .port_b_enable    ( 1'b0            ),
    .port_b_address   ( 5'h0            ),
    .port_b_data_egr  ( sdp_data_egress )
  );

  ram_sdp_bw #(
    .BYTE_WIDTH_P     ( 4 ),
    .ADDR_WIDTH_P     ( 5 )
  ) ram_sdp_bw_i0 (
    .clk              ( clk                ),
    .port_a_enable    ( 1'b0               ),
    .port_a_write_enable ( 1'b0            ),
    .port_a_address   ( 5'h0               ),
    .port_a_data_ing  ( 32'h0              ),
    .port_a_write_mask ( 4'h0              ),
    .port_b_enable    ( 1'b0               ),
    .port_b_address   ( 5'h0               ),
    .port_b_data_egr  ( sdp_bw_data_egress )
  );

  ram_sdp2c #(
    .DATA_WIDTH_P     ( 32 ),
    .ADDR_WIDTH_P     ( 5  )
  ) ram_sdp2c_i0 (
    .clk_a            ( clk                ),
    .port_a_enable    ( 1'b0               ),
    .port_a_write_enable ( 1'b0            ),
    .port_a_address   ( 5'h0               ),
    .port_a_data_ing  ( 32'h0              ),
    .clk_b            ( clk                ),
    .port_b_enable    ( 1'b0               ),
    .port_b_address   ( 5'h0               ),
    .port_b_data_egr  ( sdp2c_data_egress  )
  );

  ram_tdp #(
    .DATA_WIDTH_P     ( 32 ),
    .ADDR_WIDTH_P     ( 5  )
  ) ram_tdp_i0 (
    .clk              ( clk                ),
    .port_a_enable    ( 1'b0               ),
    .port_a_write_enable ( 1'b0            ),
    .port_a_address   ( 5'h0               ),
    .port_a_data_ing  ( 32'h0              ),
    .port_a_data_egr  ( tdp_a_data_egress  ),
    .port_b_enable    ( 1'b0               ),
    .port_b_write_enable ( 1'b0            ),
    .port_b_address   ( 5'h0               ),
    .port_b_data_ing  ( 32'h0              ),
    .port_b_data_egr  ( tdp_b_data_egress  )
  );

  ram_tdp_bw #(
    .BYTE_WIDTH_P     ( 4 ),
    .ADDR_WIDTH_P     ( 5 )
  ) ram_tdp_bw_i0 (
    .clk              ( clk                   ),
    .port_a_enable    ( 1'b0                  ),
    .port_a_write_enable ( 1'b0               ),
    .port_a_data_ing  ( 32'h0                 ),
    .port_a_write_mask ( 4'h0                 ),
    .port_a_address   ( 5'h0                  ),
    .port_a_data_egr  ( tdp_bw_a_data_egress  ),
    .port_b_enable    ( 1'b0                  ),
    .port_b_write_enable ( 1'b0               ),
    .port_b_data_ing  ( 32'h0                 ),
    .port_b_write_mask ( 4'h0                 ),
    .port_b_address   ( 5'h0                  ),
    .port_b_data_egr  ( tdp_bw_b_data_egress  )
  );

endmodule

`default_nettype wire
