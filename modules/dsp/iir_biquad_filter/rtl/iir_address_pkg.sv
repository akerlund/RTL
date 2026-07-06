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

`ifndef IIR_ADDRESS_PKG
`define IIR_ADDRESS_PKG

package iir_address_pkg;

  localparam logic [15 : 0] IIR_HIGH_ADDRESS = 16'h0068;
  localparam logic [15 : 0] IIR_F0_ADDR     = 16'h0000;
  localparam logic [15 : 0] IIR_FS_ADDR     = 16'h0008;
  localparam logic [15 : 0] IIR_Q_ADDR      = 16'h0010;
  localparam logic [15 : 0] IIR_TYPE_ADDR   = 16'h0018;
  localparam logic [15 : 0] IIR_BYPASS_ADDR = 16'h0020;
  localparam logic [15 : 0] IIR_W0_ADDR     = 16'h0028;
  localparam logic [15 : 0] IIR_ALFA_ADDR   = 16'h0030;
  localparam logic [15 : 0] IIR_B0_ADDR     = 16'h0038;
  localparam logic [15 : 0] IIR_B1_ADDR     = 16'h0040;
  localparam logic [15 : 0] IIR_B2_ADDR     = 16'h0048;
  localparam logic [15 : 0] IIR_A0_ADDR     = 16'h0050;
  localparam logic [15 : 0] IIR_A1_ADDR     = 16'h0058;
  localparam logic [15 : 0] IIR_A2_ADDR     = 16'h0060;

endpackage

`endif
