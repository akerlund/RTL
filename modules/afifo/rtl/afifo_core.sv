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

module afifo_core #(
    parameter int DATA_WIDTH_P = -1,
    parameter int ADDR_WIDTH_P = -1
  )(
    input  wire                       wclk,
    input  wire                       rst_w_n,
    input  wire                       wclk_wr_en,
    input  wire  [DATA_WIDTH_P-1 : 0] wclk_data,
    output logic                      wclk_full,

    input  wire                       rclk,
    input  wire                       rst_r_n,
    input  wire                       rclk_rd_en,
    output logic [DATA_WIDTH_P-1 : 0] rclk_data,
    output logic                      rclk_empty,

    output logic   [ADDR_WIDTH_P : 0] sr_wclk_fill_level,
    output logic   [ADDR_WIDTH_P : 0] sr_rclk_fill_level
  );

  localparam logic [ADDR_WIDTH_P+1 : 0] PTR_MODULUS_C = {1'b1, {(ADDR_WIDTH_P+1){1'b0}}};

  function automatic logic [ADDR_WIDTH_P : 0] ptr_distance(
    input logic [ADDR_WIDTH_P : 0] newer,
    input logic [ADDR_WIDTH_P : 0] older
  );
    logic [ADDR_WIDTH_P+1 : 0] distance;
    begin
      if (newer >= older) begin
        distance = newer - older;
      end else begin
        distance = PTR_MODULUS_C - older + newer;
      end
      ptr_distance = distance[ADDR_WIDTH_P : 0];
    end
  endfunction

  logic                      wclk_rst_n;
  logic                      wclk_rclk_rst_n;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_bin;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_bin_next;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_gray;
  logic   [ADDR_WIDTH_P : 0] wclk_wr_gray_next;
  logic [ADDR_WIDTH_P-1 : 0] wclk_wr_addr;
  logic                      wclk_full_next;
  logic   [ADDR_WIDTH_P : 0] wclk_full_gray;
  logic   [ADDR_WIDTH_P : 0] wclk_rd_gray;
  logic   [ADDR_WIDTH_P : 0] wclk_rd_bin;
  logic                      wclk_mem_wr_en;

  logic                      rclk_rst_n;
  logic                      rclk_wclk_rst_n;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_bin;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_bin_next;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_gray;
  logic   [ADDR_WIDTH_P : 0] rclk_rd_gray_next;
  logic [ADDR_WIDTH_P-1 : 0] rclk_rd_addr;
  logic                      rclk_empty_next;
  logic   [ADDR_WIDTH_P : 0] rclk_wr_gray;
  logic   [ADDR_WIDTH_P : 0] rclk_wr_bin;

  // ---------------------------------------------------------------------------
  // Write logic
  // ---------------------------------------------------------------------------

  assign wclk_wr_bin_next  = wclk_wr_bin + {{ADDR_WIDTH_P{1'b0}}, wclk_wr_en && !wclk_full};
  assign wclk_wr_gray_next = (wclk_wr_bin_next >> 1) ^ wclk_wr_bin_next;
  assign wclk_wr_addr      = wclk_wr_bin[ADDR_WIDTH_P-1 : 0];
  assign wclk_mem_wr_en    = wclk_wr_en && !wclk_full;

  generate
    if (ADDR_WIDTH_P > 1) begin : gen_wide_full_gray
      assign wclk_full_gray = {~wclk_rd_gray[ADDR_WIDTH_P : ADDR_WIDTH_P-1], wclk_rd_gray[ADDR_WIDTH_P-2 : 0]};
    end else begin : gen_narrow_full_gray
      assign wclk_full_gray = ~wclk_rd_gray;
    end
  endgenerate

  assign wclk_full_next = wclk_wr_gray_next == wclk_full_gray;


  always_ff @(posedge wclk or negedge rst_w_n) begin
    if (!rst_w_n) begin
      wclk_rst_n   <= '0;
      wclk_full    <= '1;
      wclk_wr_bin  <= '0;
      wclk_wr_gray <= '0;
    end else begin
      wclk_rst_n <= '1;
      if (wclk_rclk_rst_n) begin
        wclk_wr_bin  <= wclk_wr_bin_next;
        wclk_wr_gray <= wclk_wr_gray_next;
        wclk_full    <= wclk_full_next;
      end
    end
  end


  always_ff @(posedge wclk or negedge rst_w_n) begin
    if (!rst_w_n) begin
      sr_wclk_fill_level <= '0;
    end else begin
      sr_wclk_fill_level <= ptr_distance(wclk_wr_bin, wclk_rd_bin);
    end
  end


  // ---------------------------------------------------------------------------
  // Read logic
  // ---------------------------------------------------------------------------

  assign rclk_rd_bin_next  = rclk_rd_bin + {{ADDR_WIDTH_P{1'b0}}, rclk_rd_en && !rclk_empty};
  assign rclk_rd_gray_next = (rclk_rd_bin_next >> 1) ^ rclk_rd_bin_next;
  assign rclk_rd_addr      = rclk_rd_bin[ADDR_WIDTH_P-1 : 0];
  assign rclk_empty_next   = (rclk_rd_gray_next == rclk_wr_gray);


  always_ff @(posedge rclk or negedge rst_r_n) begin
    if (!rst_r_n) begin
      rclk_rst_n   <= '0;
      rclk_empty   <= '1;
      rclk_rd_bin  <= '0;
      rclk_rd_gray <= '0;
    end else begin
      rclk_rst_n <= '1;
      if (rclk_wclk_rst_n) begin
        rclk_rd_bin  <= rclk_rd_bin_next;
        rclk_rd_gray <= rclk_rd_gray_next;
        rclk_empty   <= rclk_empty_next;
      end
    end
  end


  always_ff @(posedge rclk or negedge rst_r_n) begin
    if (!rst_r_n) begin
      sr_rclk_fill_level <= '0;
    end else begin
      sr_rclk_fill_level <= ptr_distance(rclk_wr_bin, rclk_rd_bin);
    end
  end


  ram_sdp2c #(
    .DATA_WIDTH_P        ( DATA_WIDTH_P   ),
    .ADDR_WIDTH_P        ( ADDR_WIDTH_P   )
  ) ram_sdp2c_i0 (
    .clk_a               ( wclk           ),
    .port_a_enable       ( '1             ),
    .port_a_write_enable ( wclk_mem_wr_en ),
    .port_a_address      ( wclk_wr_addr   ),
    .port_a_data_ing     ( wclk_data      ),
    .clk_b               ( rclk           ),
    .port_b_enable       ( '1             ),
    .port_b_address      ( rclk_rd_addr   ),
    .port_b_data_egr     ( rclk_data      )
  );


  cdc_bit_sync cdc_bit_sync_i0 (
    .clk_src   ( wclk            ),
    .rst_src_n ( rst_w_n         ),
    .clk_dst   ( rclk            ),
    .rst_dst_n ( rst_r_n         ),
    .src_bit   ( wclk_rst_n      ),
    .dst_bit   ( rclk_wclk_rst_n )
  );


  cdc_bit_sync cdc_bit_sync_i1 (
    .clk_src   ( rclk            ),
    .rst_src_n ( rst_r_n         ),
    .clk_dst   ( wclk            ),
    .rst_dst_n ( rst_w_n         ),
    .src_bit   ( rclk_rst_n      ),
    .dst_bit   ( wclk_rclk_rst_n )
  );


  gray_to_bin #(
    .WIDTH_P ( ADDR_WIDTH_P+1 )
  ) gray_to_bin_i0 (
    .gray    ( wclk_rd_gray   ),
    .bin     ( wclk_rd_bin    )
  );


  gray_to_bin #(
    .WIDTH_P ( ADDR_WIDTH_P+1 )
  ) gray_to_bin_i1 (
    .gray    ( rclk_wr_gray   ),
    .bin     ( rclk_wr_bin    )
  );

  genvar i;

  // Write pointer, wclk to rclk
  generate
    for (i = 0; i <= ADDR_WIDTH_P; i++) begin
      cdc_bit_sync cdc_bit_sync_i (
        .clk_src   ( wclk            ),
        .rst_src_n ( rst_w_n         ),
        .clk_dst   ( rclk            ),
        .rst_dst_n ( rst_r_n         ),
        .src_bit   ( wclk_wr_gray[i] ),
        .dst_bit   ( rclk_wr_gray[i] )
      );
    end
  endgenerate

  // Read pointer, rclk to wclk
  generate
    for (i = 0; i <= ADDR_WIDTH_P; i++) begin
      cdc_bit_sync cdc_bit_sync_i (
        .clk_src   ( rclk            ),
        .rst_src_n ( rst_r_n         ),
        .clk_dst   ( wclk            ),
        .rst_dst_n ( rst_w_n         ),
        .src_bit   ( rclk_rd_gray[i] ),
        .dst_bit   ( wclk_rd_gray[i] )
      );
    end
  endgenerate

`ifndef SYNTHESIS
  always_ff @(posedge wclk) begin
    if (rst_w_n && !wclk_rclk_rst_n) begin
      assert (wclk_full)
        else $error("wclk_full must stay asserted until rclk reset has synchronized");
    end
  end

  always_ff @(posedge rclk) begin
    if (rst_r_n && !rclk_wclk_rst_n) begin
      assert (rclk_empty)
        else $error("rclk_empty must stay asserted until wclk reset has synchronized");
    end
  end
`endif

endmodule

`default_nettype wire
