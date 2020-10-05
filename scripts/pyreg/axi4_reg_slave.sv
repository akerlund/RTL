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

module __APB_SLAVE_NAME__ #(
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
__PORTS__
  output logic     [AXI_DATA_WIDTH_C-1 : 0] cr_led_0,
  input  wire      [AXI_DATA_WIDTH_C-1 : 0] sr_led_counter,

  output logic     [AXI_DATA_WIDTH_C-1 : 0] cr_axi_address,
  output logic     [AXI_DATA_WIDTH_C-1 : 0] cr_wdata,
  input  wire      [AXI_DATA_WIDTH_C-1 : 0] sr_rdata,

  output logic     [AXI_DATA_WIDTH_C-1 : 0] cmd_mc_axi4_write,
  output logic     [AXI_DATA_WIDTH_C-1 : 0] cmd_mc_axi4_read,
  input  wire      [AXI_DATA_WIDTH_C-1 : 0] sr_mc_axi4_rdata
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

integer                        byte_index;

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

    __RESETS__
    cr_led_0          <= '0;

    cr_axi_address    <= '0;
    cr_wdata          <= '0;
    cmd_mc_axi4_write <= '0;
    cmd_mc_axi4_read  <= '0;

  end
  else begin

    __COMMANDS__
    cmd_mc_axi4_write <= '0;
    cmd_mc_axi4_read  <= '0;

    if (write_enable) begin

      case (awaddr_d0[ADDR_LSB_C+OPT_MEM_ADDR_BITS_C : ADDR_LSB_C])

        __WRITES__


        5'h00: begin
          for (byte_index = 0; byte_index <= (AXI_DATA_WIDTH_C/8)-1; byte_index++) begin
            if (wstrb[byte_index] == 1) begin
              cr_led_0[(byte_index*8) +: 8] <= wdata[(byte_index*8) +: 8];
            end
          end
        end

        5'h01: begin
          for (byte_index = 0; byte_index <= (AXI_DATA_WIDTH_C/8)-1; byte_index++) begin
            if (wstrb[byte_index] == 1) begin
              cr_axi_address[(byte_index*8) +: 8] <= wdata[(byte_index*8) +: 8];
            end
          end
        end

        5'h02: begin
          for (byte_index = 0; byte_index <= (AXI_DATA_WIDTH_C/8)-1; byte_index++) begin
            if (wstrb[byte_index] == 1) begin
              cr_wdata[(byte_index*8) +: 8] <= wdata[(byte_index*8) +: 8];
            end
          end
        end

        5'h03: begin
          for (byte_index = 0; byte_index <= (AXI_DATA_WIDTH_C/8)-1; byte_index++) begin
            if (wstrb[byte_index] == 1) begin
              cmd_mc_axi4_write[(byte_index*8) +: 8] <= wdata[(byte_index*8) +: 8];
            end
          end
        end

        5'h04: begin
          for (byte_index = 0; byte_index <= (AXI_DATA_WIDTH_C/8)-1; byte_index++) begin
            if (wstrb[byte_index] == 1) begin
              cmd_mc_axi4_read[(byte_index*8) +: 8] <= wdata[(byte_index*8) +: 8];
            end
          end
        end

        default : begin

          cr_led_0          <= cr_led_0;
          cr_axi_address    <= cr_axi_address;
          cr_wdata          <= cr_wdata;
          cmd_mc_axi4_write <= cmd_mc_axi4_write;
          cmd_mc_axi4_read  <= cmd_mc_axi4_read;

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

    __READS__
    5'h00   : rdata_d0 <= 1;
    5'h01   : rdata_d0 <= 2;
    5'h02   : rdata_d0 <= 3;
    5'h03   : rdata_d0 <= 4;
    5'h04   : rdata_d0 <= 5;
    5'h05   : rdata_d0 <= sr_led_counter;
    5'h06   : rdata_d0 <= 6;

    default : rdata_d0 <= '0;
  endcase
end

endmodule
