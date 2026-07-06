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

module frequency_enable #(
    parameter int SYS_CLK_FREQUENCY_P = 1,
    parameter int AXI_DATA_WIDTH_P    = 32,
    parameter int AXI_ID_WIDTH_P      = 1,
    parameter int Q_BITS_P            = 0,
    parameter int AXI4S_ID_P          = 0
  )(
    input  wire                                      clk,
    input  wire                                      rst_n,

    output logic                                     enable,
    input  wire  [$clog2(SYS_CLK_FREQUENCY_P+1)-1 : 0] cr_enable_frequency,

    // -------------------------------------------------------------------------
    // Long division interface
    // -------------------------------------------------------------------------

    output logic                                     div_egr_tvalid,
    input  wire                                      div_egr_tready,
    output logic            [AXI_DATA_WIDTH_P-1 : 0] div_egr_tdata,
    output logic                                     div_egr_tlast,
    output logic              [AXI_ID_WIDTH_P-1 : 0] div_egr_tid,

    input  wire                                      div_ing_tvalid,
    output logic                                     div_ing_tready,
    input  wire             [AXI_DATA_WIDTH_P-1 : 0] div_ing_tdata,  // Quotient
    input  wire                                      div_ing_tlast,
    input  wire               [AXI_ID_WIDTH_P-1 : 0] div_ing_tid,
    input  wire                                      div_ing_tuser   // Overflow
  );

  typedef enum {
    SEND_DIVIDEND_E,
    SEND_DIVISOR_E,
    WAIT_QUOTIENT_E,
    ENABLE_COUNTING_E
  } enable_state_t;

  localparam int FREQ_WIDTH_C = $clog2(SYS_CLK_FREQUENCY_P+1);

  enable_state_t enable_state;

  logic [FREQ_WIDTH_C-1 : 0] counter;
  logic [FREQ_WIDTH_C-1 : 0] enable_frequency;
  logic [FREQ_WIDTH_C-1 : 0] frequency_as_sys_clks;
  logic [FREQ_WIDTH_C-1 : 0] quotient_sys_clks;

  assign quotient_sys_clks = div_ing_tdata[Q_BITS_P +: FREQ_WIDTH_C];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // Ports
      enable                <= '0;
      div_egr_tvalid        <= '0;
      div_egr_tdata         <= '0;
      div_egr_tlast         <= '0;
      div_egr_tid           <= '0;
      div_ing_tready        <= '0;

      enable_state          <= SEND_DIVIDEND_E;
      counter               <= '0;
      enable_frequency      <= '0;
      frequency_as_sys_clks <= '0;
    end
    else begin

      enable         <= '0;
      div_ing_tready <= '0;
      div_egr_tid <= AXI_ID_WIDTH_P'(AXI4S_ID_P);

      case (enable_state)

        SEND_DIVIDEND_E: begin

          counter <= '0;

          if (cr_enable_frequency != '0) begin

            enable_frequency <= cr_enable_frequency;

            enable_state     <= SEND_DIVISOR_E;

            div_egr_tvalid   <= '1;
            div_egr_tdata    <= AXI_DATA_WIDTH_P'(SYS_CLK_FREQUENCY_P) << Q_BITS_P;
            div_egr_tlast    <= '0;
            div_egr_tid      <= AXI_ID_WIDTH_P'(AXI4S_ID_P);
          end
        end


        SEND_DIVISOR_E: begin

          if (div_egr_tready) begin

            // Dividend was sent
            if (!div_egr_tlast) begin
              div_egr_tdata  <= AXI_DATA_WIDTH_P'(enable_frequency) << Q_BITS_P;
              div_egr_tlast  <= '1;
            end
            // Divisor was sent
            else begin
              div_egr_tvalid <= '0;
              div_egr_tlast  <= '0;
              enable_state   <= WAIT_QUOTIENT_E;
            end
          end
        end


        WAIT_QUOTIENT_E: begin
          div_ing_tready <= '1;
          if (div_ing_tvalid) begin
            div_ing_tready        <= '0;
            if (div_ing_tuser) begin
              frequency_as_sys_clks <= '0;
              enable_frequency      <= '0;
              enable_state          <= SEND_DIVIDEND_E;
            end
            else begin
              frequency_as_sys_clks <= (quotient_sys_clks == '0) ?
                                       FREQ_WIDTH_C'(1) : quotient_sys_clks;
              enable_state          <= ENABLE_COUNTING_E;
            end
          end
        end


        ENABLE_COUNTING_E: begin

          counter <= counter + 1;

          if (counter >= frequency_as_sys_clks-1) begin
            enable  <= '1;
            counter <= '0;
          end

          if (enable_frequency != cr_enable_frequency || cr_enable_frequency == '0) begin
            enable       <= '0;
            counter      <= '0;
            enable_state <= SEND_DIVIDEND_E;
          end

        end

      endcase

    end
  end

  initial begin
    if (SYS_CLK_FREQUENCY_P <= 0) begin
      $error("SYS_CLK_FREQUENCY_P must be greater than zero");
    end

    if (AXI_DATA_WIDTH_P <= 0 || AXI_ID_WIDTH_P <= 0) begin
      $error("AXI_DATA_WIDTH_P and AXI_ID_WIDTH_P must be greater than zero");
    end

    if (Q_BITS_P < 0) begin
      $error("Q_BITS_P must be zero or greater");
    end

    if (Q_BITS_P + FREQ_WIDTH_C > AXI_DATA_WIDTH_P) begin
      $error("AXI_DATA_WIDTH_P must hold SYS_CLK_FREQUENCY_P << Q_BITS_P and quotient bits");
    end
  end

endmodule

`default_nettype wire
