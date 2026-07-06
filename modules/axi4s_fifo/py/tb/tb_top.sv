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

module tb_top #(
    parameter int AXI_DATA_WIDTH_P  = 32,
    parameter int FIFO_ADDR_WIDTH_P = 6
  )(
    input  wire clk,
    input  wire rst_n,

    input  wire                          mst_tvalid,
    output wire                          mst_tready,
    input  wire [AXI_DATA_WIDTH_P-1 : 0] mst_tdata,
    input  wire                          mst_tlast,

    output wire                          slv_tvalid,
    input  wire                          slv_tready,
    output wire [AXI_DATA_WIDTH_P-1 : 0] slv_tdata,
    output wire                          slv_tlast,

    output wire [FIFO_ADDR_WIDTH_P : 0]  sr_fill_level,
    output wire [FIFO_ADDR_WIDTH_P : 0]  sr_max_fill_level,
    output wire                          sr_almost_full
  );

  localparam int TUSER_WIDTH_C = AXI_DATA_WIDTH_P + 1;

  wire [TUSER_WIDTH_C-1 : 0] ing_tuser;
  wire [TUSER_WIDTH_C-1 : 0] egr_tuser;

  assign ing_tuser = {mst_tlast, mst_tdata};
  assign {slv_tlast, slv_tdata} = egr_tuser;

  axi4s_fifo #(
    .TUSER_WIDTH_P        ( TUSER_WIDTH_C        ),
    .ADDR_WIDTH_P         ( FIFO_ADDR_WIDTH_P    )
  ) dut (
    .clk                  ( clk                  ),
    .rst_n                ( rst_n                ),
    .ing_tready           ( mst_tready           ),
    .ing_tuser            ( ing_tuser            ),
    .ing_tvalid           ( mst_tvalid           ),
    .egr_tready           ( slv_tready           ),
    .egr_tuser            ( egr_tuser            ),
    .egr_tvalid           ( slv_tvalid           ),
    .sr_fill_level        ( sr_fill_level        ),
    .sr_max_fill_level    ( sr_max_fill_level    ),
    .sr_almost_full       ( sr_almost_full       ),
    .cr_almost_full_level ( '0                   )
  );

endmodule
