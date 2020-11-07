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

`ifndef AXI4_TYPES_PKG
`define AXI4_TYPES_PKG

package axi4_types_pkg;

  // ---------------------------------------------------------------------------
  // AXI4 specification defines
  // ---------------------------------------------------------------------------

  localparam int AXI4_MAX_BURST_LENGTH_C    = 256;
  localparam int AXI4_4K_ADDRESS_BOUNDARY_C = 4096;

  // Burst codes
  localparam logic [1 : 0] AXI4_BURST_FIXED_C    = 2'b00;
  localparam logic [1 : 0] AXI4_BURST_INCR_C     = 2'b01;
  localparam logic [1 : 0] AXI4_BURST_WRAP_C     = 2'b10;
  localparam logic [1 : 0] AXI4_BURST_RESERVED_C = 2'b11;

  // Response codes
  localparam logic [1 : 0] AXI4_RESP_OK_C        = 2'b00;
  localparam logic [1 : 0] AXI4_RESP_EXOK_C      = 2'b01;
  localparam logic [1 : 0] AXI4_RESP_SLVERR_C    = 2'b10;
  localparam logic [1 : 0] AXI4_RESP_DECERR_C    = 2'b11;

  // Burst size encoding
  localparam logic [2 : 0] AXI4_SIZE_1B_C        = 3'b000;
  localparam logic [2 : 0] AXI4_SIZE_2B_C        = 3'b001;
  localparam logic [2 : 0] AXI4_SIZE_4B_C        = 3'b010;
  localparam logic [2 : 0] AXI4_SIZE_8B_C        = 3'b011;
  localparam logic [2 : 0] AXI4_SIZE_16B_C       = 3'b100;
  localparam logic [2 : 0] AXI4_SIZE_32B_C       = 3'b101;
  localparam logic [2 : 0] AXI4_SIZE_64B_C       = 3'b110;
  localparam logic [2 : 0] AXI4_SIZE_128B_C      = 3'b111;

  // ---------------------------------------------------------------------------
  // AXI4 types
  // ---------------------------------------------------------------------------

  typedef enum logic [2 : 0] {
    AXI4_BURST_SIZE_1_BYTE_E    = AXI4_SIZE_1B_C,
    AXI4_BURST_SIZE_2_BYTES_E   = AXI4_SIZE_2B_C,
    AXI4_BURST_SIZE_4_BYTES_E   = AXI4_SIZE_4B_C,
    AXI4_BURST_SIZE_8_BYTES_E   = AXI4_SIZE_8B_C,
    AXI4_BURST_SIZE_16_BYTES_E  = AXI4_SIZE_16B_C,
    AXI4_BURST_SIZE_32_BYTES_E  = AXI4_SIZE_32B_C,
    AXI4_BURST_SIZE_64_BYTES_E  = AXI4_SIZE_64B_C,
    AXI4_BURST_SIZE_128_BYTES_E = AXI4_SIZE_128B_C
  } axi4_burst_size_t;


  typedef enum logic [1 : 0] {
    AXI4_BURST_FIXED_E    = AXI4_BURST_FIXED_C,
    AXI4_BURST_INCR_E     = AXI4_BURST_INCR_C,
    AXI4_BURST_WRAPPING_E = AXI4_BURST_WRAP_C,
    AXI4_BURST_RESERVED_E = AXI4_BURST_RESERVED_C
  } axi4_burst_type_t;


  typedef enum logic [1 : 0] {
    AXI4_RESP_OKAY_E         = AXI4_RESP_OK_C,
    AXI4_RESP_EXOKAY_E       = AXI4_RESP_EXOK_C,
    AXI4_RESP_SLAVE_ERROR_E  = AXI4_RESP_SLVERR_C,
    AXI4_RESP_DECODE_ERROR_E = AXI4_RESP_DECERR_C
  } axi4_response_t;


  typedef enum {
    AXI4_E,
    AXI4_LITE_E
  } axi4_protocol_t;


  typedef enum {
    AXI4_IN_ORDER_E,
    AXI4_OUT_OF_ORDER_E
  } axi4_ordering_mode_t;


  typedef enum {
    AXI4_WRITE_ACCESS_E,
    AXI4_READ_ACCESS_E
  } axi4_access_type_t;


  function automatic axi4_burst_size_t burst_size_as_enum(int burst_size);
    case (burst_size)
      1:   return AXI4_BURST_SIZE_1_BYTE_E;
      2:   return AXI4_BURST_SIZE_2_BYTES_E;
      4:   return AXI4_BURST_SIZE_4_BYTES_E;
      8:   return AXI4_BURST_SIZE_8_BYTES_E;
      16:  return AXI4_BURST_SIZE_16_BYTES_E;
      32:  return AXI4_BURST_SIZE_32_BYTES_E;
      64:  return AXI4_BURST_SIZE_64_BYTES_E;
      128: return AXI4_BURST_SIZE_128_BYTES_E;
    endcase
  endfunction


  function automatic int burst_size_as_integer(axi4_burst_size_t burst_size);
    case (burst_size)
      AXI4_BURST_SIZE_1_BYTE_E:    return 1;
      AXI4_BURST_SIZE_2_BYTES_E:   return 2;
      AXI4_BURST_SIZE_4_BYTES_E:   return 4;
      AXI4_BURST_SIZE_8_BYTES_E:   return 8;
      AXI4_BURST_SIZE_16_BYTES_E:  return 16;
      AXI4_BURST_SIZE_32_BYTES_E:  return 32;
      AXI4_BURST_SIZE_64_BYTES_E:  return 64;
      AXI4_BURST_SIZE_128_BYTES_E: return 128;
    endcase
  endfunction


  function automatic logic [7 : 0] burst_length_as_logic(int burst_length);
    if (burst_length inside { [1 : 256] }) begin
      return (burst_length - 1);
    end
    else begin
      return '0;
    end
  endfunction


  function automatic int burst_length_as_int(logic [7 : 0] burst_length);
    return int'(burst_length) + 1;
  endfunction

endpackage

`endif
