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

IMPORT

module CLASS_NAME #(
    parameter integer AXI_DATA_WIDTH_C = -1,
    parameter integer AXI_ADDR_WIDTH_C = -1
  )(

    // ---------------------------------------------------------------------------
    // AXI ports
    // ---------------------------------------------------------------------------

    // Clock and reset
    input  wire                               clk,
    input  wire                               rst_n,

    // Write Address Channel
    input  wire      [AXI_ADDR_WIDTH_C-1 : 0] awaddr,
    input  wire                               awvalid,
    output logic                              awready,

    // Write Data Channel
    input  wire      [AXI_DATA_WIDTH_C-1 : 0] wdata,
    input  wire  [(AXI_DATA_WIDTH_C/8)-1 : 0] wstrb,
    input  wire                               wvalid,
    output logic                              wready,

    // Write Response Channel
    output logic                      [1 : 0] bresp,
    output logic                              bvalid,
    input  wire                               bready,

    // Read Address Channel
    input  wire      [AXI_ADDR_WIDTH_C-1 : 0] araddr,
    input  wire                               arvalid,
    output logic                              arready,

    // Read Data Channel
    output logic     [AXI_DATA_WIDTH_C-1 : 0] rdata,
    output logic                      [1 : 0] rresp,
    output logic                              rvalid,
    input  wire                               rready,

    // ---------------------------------------------------------------------------
    // Register Ports
    // ---------------------------------------------------------------------------
PORTS
);

  // ---------------------------------------------------------------------------
  // Internal AXI signals
  // ---------------------------------------------------------------------------

  // Example-specific design signals
  // local parameter for addressing 32 bit / 64 bit AXI_DATA_WIDTH_C
  // ADDR_LSB_C is used for addressing 32/64 bit registers/memories
  // ADDR_LSB_C = 2 for 32 bits (n downto 2)
  // ADDR_LSB_C = 3 for 64 bits (n downto 3)
  localparam int ADDR_LSB_C          = (AXI_DATA_WIDTH_C / 32) + 1;
  localparam int OPT_MEM_ADDR_BITS_C = 4;

  // ---------------------------------------------------------------------------
  // Internal signals
  // ---------------------------------------------------------------------------

  logic                          aw_enable;
  logic [AXI_ADDR_WIDTH_C-1 : 0] awaddr_d0;
  logic                          write_enable;
  logic                          read_enable;
  logic [AXI_ADDR_WIDTH_C-1 : 0] araddr_d0;
  logic [AXI_DATA_WIDTH_C-1 : 0] rdata_d0;

LOGIC_DECLARATIONS

  // ---------------------------------------------------------------------------
  // Internal assignments
  // ---------------------------------------------------------------------------

  assign write_enable = wready  & wvalid  & awready & awvalid;
  assign read_enable  = arready & arvalid & ~rvalid;


  // ---------------------------------------------------------------------------
  // Write Address Channel
  // Generate "awready" and internal address write enable
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      awaddr_d0 <= '0;
      awready   <= '0;
      aw_enable <= '1;
    end
    else begin

      // awready
      if (!awready && awvalid && wvalid && aw_enable) begin
        awready   <= '1;
        aw_enable <= '0;
      end
      else if (bready && bvalid) begin
        aw_enable <= '1;
        awready   <= '0;
      end
      else begin
        awready   <= '0;
      end

      // awaddr
      if (!awready && awvalid && wvalid && aw_enable) begin
        awaddr_d0 <= awaddr;
      end

    end
  end


  // ---------------------------------------------------------------------------
  // Write Data Channel
  // Generate "wready"
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wready <= '0;
    end
    else begin

      if (!wready && wvalid && awvalid && aw_enable) begin
        wready <= '1;
      end
      else begin
        wready <= '0;
      end

    end
  end


  // ---------------------------------------------------------------------------
  // Register writes
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

RESETS

    end
    else begin

CMD_REGISTERS

      if (write_enable) begin

        case (awaddr_d0[ADDR_LSB_C+OPT_MEM_ADDR_BITS_C : ADDR_LSB_C])

AXI_WRITES


          //5'h00: begin
          //  for (int byte = 0; byte <= (AXI_DATA_WIDTH_C/8)-1; byte++) begin
          //    if (wstrb[byte] == 1) begin
          //      cr_led_0[(byte*8) +: 8] <= wdata[(byte*8) +: 8];
          //    end
          //  end
          //end

          default : begin

          end
        endcase
      end
    end
  end


  // ---------------------------------------------------------------------------
  // Write Response Channel
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bvalid <= '0;
      bresp  <= '0;
    end
    else begin

      if (awready && awvalid && !bvalid && wready && wvalid) begin
        bvalid <= '1;
        bresp  <= '0;
      end
      else begin
        if (bready && bvalid) begin
          bvalid <= '0;
        end
      end
    end
  end


  // ---------------------------------------------------------------------------
  // Read Address Channel
  // Generate "arready"
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      arready   <= '0;
      araddr_d0 <= '0;
    end
    else begin

      if (!arready && arvalid) begin
        arready   <= '1;
        araddr_d0 <= araddr;
      end
      else begin
        arready <= '0;
      end

    end
  end


  // ---------------------------------------------------------------------------
  // Read Data Channel
  // Generate "rvalid"
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rdata  <= 0;
      rresp  <= 0;
      rvalid <= 0;
    end
    else begin

RC_ASSIGNMENTS

      if (read_enable) begin
        rdata <= rdata_d0;
      end

      if (arready && arvalid && !rvalid) begin
        rvalid <= '1;
        rresp  <= '0;
      end
      else if (rvalid && rready) begin
        rvalid <= '0;
      end

    end
  end


  // ---------------------------------------------------------------------------
  // Register reads
  // ---------------------------------------------------------------------------
  always_comb begin

    // Address decoding for reading registers
    case (araddr_d0[ADDR_LSB_C+OPT_MEM_ADDR_BITS_C : ADDR_LSB_C])

AXI_READS
//    5'h00   : rdata_d0 <= 1;

      default : rdata_d0 <= rdata_d0;
    endcase
  end

endmodule
