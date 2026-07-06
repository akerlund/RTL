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

import iir_address_pkg::*;

module iir_axi_slave #(
    parameter int AXI_ADDR_WIDTH_P = -1,
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_ID_P = -1,
    parameter int N_BITS_C = -1
  )(
    axi4_reg_if.slave cif,
    output logic [N_BITS_C-1 : 0] cr_iir_f0,
    output logic [N_BITS_C-1 : 0] cr_iir_fs,
    output logic [N_BITS_C-1 : 0] cr_iir_q,
    output logic [N_BITS_C-1 : 0] cr_iir_type,
    output logic                  cr_iir_bypass,
    input  wire  [N_BITS_C-1 : 0] sr_iir_w0,
    input  wire  [N_BITS_C-1 : 0] sr_iir_alfa,
    input  wire  [N_BITS_C-1 : 0] sr_iir_b0,
    input  wire  [N_BITS_C-1 : 0] sr_iir_b1,
    input  wire  [N_BITS_C-1 : 0] sr_iir_b2,
    input  wire  [N_BITS_C-1 : 0] sr_iir_a0,
    input  wire  [N_BITS_C-1 : 0] sr_iir_a1,
    input  wire  [N_BITS_C-1 : 0] sr_iir_a2
  );

  localparam logic [1 : 0] AXI_RESP_SLVERR_C = 2'b01;

  // ---------------------------------------------------------------------------
  // Internal signals
  // ---------------------------------------------------------------------------

  typedef enum {
    WAIT_MST_AWVALID_E,
    WAIT_FOR_BREADY_E,
    WAIT_MST_WLAST_E
  } write_state_t;

  write_state_t write_state;

  logic [AXI_ADDR_WIDTH_P-1 : 0] awaddr_r0;

  typedef enum {
    WAIT_MST_ARVALID_E,
    WAIT_SLV_RLAST_E
  } read_state_t;

  read_state_t read_state;

  logic [AXI_ADDR_WIDTH_P-1 : 0] araddr_r0;
  logic                  [7 : 0] arlen_r0;



  // ---------------------------------------------------------------------------
  // Port assignments
  // ---------------------------------------------------------------------------

  assign cif.rid = AXI_ID_P;

  // ---------------------------------------------------------------------------
  // Write processes
  // ---------------------------------------------------------------------------
  always_ff @(posedge cif.clk or negedge cif.rst_n) begin
    if (!cif.rst_n) begin

      write_state <= WAIT_MST_AWVALID_E;
      awaddr_r0   <= '0;
      cif.awready <= '0;
      cif.wready  <= '0;
      cif.bvalid  <= '0;
      cif.bresp   <= '0;
      cr_iir_f0     <= 0;
      cr_iir_fs     <= 0;
      cr_iir_q      <= 0;
      cr_iir_type   <= 0;
      cr_iir_bypass <= 0;

    end
    else begin




      case (write_state)

        default: begin
          write_state <= WAIT_MST_AWVALID_E;
        end

        WAIT_MST_AWVALID_E: begin

          cif.awready <= '1;

          if (cif.awvalid) begin
            write_state <= WAIT_MST_WLAST_E;
            cif.awready <= '0;
            awaddr_r0   <= cif.awaddr;
            cif.wready  <= '1;
          end

        end


        WAIT_FOR_BREADY_E: begin

          if (cif.bvalid && cif.bready) begin
            write_state <= WAIT_MST_AWVALID_E;
            cif.awready <= '1;
            cif.bvalid  <= '0;
            cif.bresp   <= '0;
          end

        end


        WAIT_MST_WLAST_E: begin

          if (cif.wlast && cif.wvalid) begin
            write_state <= WAIT_FOR_BREADY_E;
            cif.bvalid  <= '1;
            cif.wready  <= '0;
          end


          if (cif.wvalid) begin

            awaddr_r0 <= awaddr_r0 + (AXI_DATA_WIDTH_P/8);

            case (awaddr_r0)

              IIR_F0_ADDR: begin
                cr_iir_f0 <= cif.wdata[N_BITS_C-1 : 0];
              end

              IIR_FS_ADDR: begin
                cr_iir_fs <= cif.wdata[N_BITS_C-1 : 0];
              end

              IIR_Q_ADDR: begin
                cr_iir_q <= cif.wdata[N_BITS_C-1 : 0];
              end

              IIR_TYPE_ADDR: begin
                cr_iir_type <= cif.wdata[N_BITS_C-1 : 0];
              end

              IIR_BYPASS_ADDR: begin
                cr_iir_bypass <= cif.wdata[0];
              end


              default: begin
                cif.bresp <= AXI_RESP_SLVERR_C;
              end

            endcase


          end
        end
      endcase
    end
  end

  // ---------------------------------------------------------------------------
  // Read process
  // ---------------------------------------------------------------------------

  assign cif.rlast = (arlen_r0 == '0);

  // FSM
  always_ff @(posedge cif.clk or negedge cif.rst_n) begin
    if (!cif.rst_n) begin

      read_state  <= WAIT_MST_ARVALID_E;
      cif.arready <= '0;
      araddr_r0   <= '0;
      arlen_r0    <= '0;
      cif.rvalid  <= '0;

    end
    else begin

      case (read_state)

        default: begin
          read_state <= WAIT_MST_ARVALID_E;
        end

        WAIT_MST_ARVALID_E: begin

          cif.arready <= '1;

          if (cif.arvalid) begin
            read_state  <= WAIT_SLV_RLAST_E;
            araddr_r0   <= cif.araddr;
            arlen_r0    <= cif.arlen;
            cif.arready <= '0;
            cif.rvalid  <= '1;
          end

        end

        WAIT_SLV_RLAST_E: begin


          if (cif.rready) begin
            araddr_r0 <= araddr_r0 + (AXI_DATA_WIDTH_P/8);
          end

          if (cif.rlast && cif.rready) begin
            read_state  <= WAIT_MST_ARVALID_E;
            cif.arready <= '1;
            cif.rvalid  <= '0;
          end

          if (cif.rready && arlen_r0 != '0) begin
            arlen_r0 <= arlen_r0 - 1;
          end

        end
      endcase
    end
  end


  always_comb begin

    cif.rdata = '0;
    cif.rresp = '0;


    case (araddr_r0)

      IIR_F0_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = cr_iir_f0;
      end

      IIR_FS_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = cr_iir_fs;
      end

      IIR_Q_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = cr_iir_q;
      end

      IIR_TYPE_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = cr_iir_type;
      end

      IIR_BYPASS_ADDR: begin
        cif.rdata[0] = cr_iir_bypass;
      end

      IIR_W0_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = sr_iir_w0;
      end

      IIR_ALFA_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = sr_iir_alfa;
      end

      IIR_B0_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = sr_iir_b0;
      end

      IIR_B1_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = sr_iir_b1;
      end

      IIR_B2_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = sr_iir_b2;
      end

      IIR_A0_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = sr_iir_a0;
      end

      IIR_A1_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = sr_iir_a1;
      end

      IIR_A2_ADDR: begin
        cif.rdata[N_BITS_C-1 : 0] = sr_iir_a2;
      end


      default: begin
        cif.rresp = AXI_RESP_SLVERR_C;
        cif.rdata = '0;
      end

    endcase
  end

endmodule
