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

module rgb_led_pwm #(
    parameter int COLOR_WIDTH_P   = -1,
    parameter int TID_BIT_WIDTH_P = -1,
    parameter int CR_AXI4S_TID_P  = -1
  )(
    // Clock and reset
    input  wire                          clk,
    input  wire                          rst_n,

    // RGB LED pins
    output logic   [COLOR_WIDTH_P-1 : 0] pwm_red,
    output logic   [COLOR_WIDTH_P-1 : 0] pwm_green,
    output logic   [COLOR_WIDTH_P-1 : 0] pwm_blue,

    // HSL
    input  wire    [COLOR_WIDTH_P-1 : 0] cr_hue,
    input  wire    [COLOR_WIDTH_P-1 : 0] cr_saturation,
    input  wire    [COLOR_WIDTH_P-1 : 0] cr_light,

    // AXI4-S slave side: For sending HSL data
    input  wire                          axi4s_o_tready,
    output logic                [23 : 0] axi4s_o_tdata,
    output logic                         axi4s_o_tvalid,
    output logic [TID_BIT_WIDTH_P-1 : 0] axi4s_o_tid,

    // AXI4-S master side: For receiving RGB data
    output logic                         axi4s_i_tready,
    input  wire                 [23 : 0] axi4s_i_tdata,
    input  wire                          axi4s_i_tvalid
  );

  localparam logic [TID_BIT_WIDTH_P-1 : 0] axi4s_tid_id_c = CR_AXI4S_TID_P;

  logic  [COLOR_WIDTH_P-1 : 0] color_red;
  logic  [COLOR_WIDTH_P-1 : 0] color_green;
  logic  [COLOR_WIDTH_P-1 : 0] color_blue;

  logic                        axi4s_o_transaction;
  logic                        axi4s_i_transaction;

  logic               [23 : 0] axi4s_o_tdata_hsl;

  assign axi4s_o_transaction = axi4s_o_tready && axi4s_o_tvalid;
  assign axi4s_i_transaction = axi4s_i_tready && axi4s_i_tvalid;

  assign axi4s_o_tdata_hsl   = {cr_light, cr_saturation, cr_hue};

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      axi4s_o_tdata  <= '0;
      axi4s_o_tvalid <= '0;
      axi4s_o_tid    <= '0;
      axi4s_i_tready <= '0;
      color_red      <= '0;
      color_green    <= '0;
      color_blue     <= '0;
    end
    else begin

      axi4s_o_tid    <= axi4s_tid_id_c;
      axi4s_o_tdata  <= axi4s_o_tdata_hsl;

      axi4s_i_tready <= 1;

      if (axi4s_i_transaction) begin
        color_red   <= axi4s_i_tdata[7:0];
        color_green <= axi4s_i_tdata[15:8];
        color_blue  <= axi4s_i_tdata[23:16];
      end

      if ( axi4s_o_tdata != axi4s_o_tdata_hsl) begin
        axi4s_o_tvalid <= 1;
      end
      if (axi4s_o_transaction) begin
        axi4s_o_tvalid <= '0;
      end
    end
  end

  rgb_led_pwm_core #(
    .COUNTER_WIDTH_P ( COLOR_WIDTH_P )
  ) rgb_led_pwm_core_i0 (
    .clk               ( clk         ),
    .rst_n             ( rst_n       ),
    .pwm_red           ( pwm_red     ),
    .pwm_green         ( pwm_green   ),
    .pwm_blue          ( pwm_blue    ),
    .cr_pwm_duty_red   ( color_red   ),
    .cr_pwm_duty_green ( color_green ),
    .cr_pwm_duty_blue  ( color_blue  )
  );

endmodule

`default_nettype wire
