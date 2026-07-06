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

module cordic_axi4s_if #(
    parameter int AXI_DATA_WIDTH_P = -1,
    parameter int AXI_ID_WIDTH_P   = -1,
    parameter int NR_OF_STAGES_P   = -1
  )(
    // Clock and reset
    input  wire                             clk,
    input  wire                             rst_n,

    // AXI4-S master side
    input  wire                             ing_tvalid,
    input  wire    [AXI_DATA_WIDTH_P-1 : 0] ing_tdata,
    input  wire      [AXI_ID_WIDTH_P-1 : 0] ing_tid,
    input  wire                             ing_tuser,  // Reserved metadata bit, latency-matched to the response

    // AXI4-S slave side
    output logic                            egr_tvalid,
    output logic [2*AXI_DATA_WIDTH_P-1 : 0] egr_tdata,
    output logic     [AXI_ID_WIDTH_P-1 : 0] egr_tid
 );

 localparam int ING_FIFO_SIZE_C   = $bits(ing_tvalid) + $bits(ing_tid) + $bits(ing_tuser);
 localparam int ING_FIFO_STAGES_C = NR_OF_STAGES_P-1;

  // Used to shift the ing_tvalid which is used to assing egr_tvalid
  logic [ING_FIFO_STAGES_C-1 : 0] [ING_FIFO_SIZE_C-1 : 0] axi4s_ing_fifo;

  // CORDIC signals
  logic [AXI_DATA_WIDTH_P-1 : 0] egr_sine_vector;
  logic [AXI_DATA_WIDTH_P-1 : 0] egr_cosine_vector;

  // Latency-matched metadata
  logic egr_tuser;

  // AXI4-S egress "tdata" port
  assign egr_tdata = !egr_tvalid ? '0 : {egr_sine_vector, egr_cosine_vector};


  // Shift the ing_tvalid which is used to assing egr_tvalid
  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      axi4s_ing_fifo <= '0;
      egr_tvalid     <= '0;
      egr_tid        <= '0;
    end
    else begin

      // Input requests
      axi4s_ing_fifo[0] <= {ing_tvalid, ing_tid, ing_tuser};

      // Shift requests
      for (int i = 0; i < ING_FIFO_STAGES_C-1; i++) begin
        axi4s_ing_fifo[i+1] <= axi4s_ing_fifo[i];
      end

      // Data output
      {egr_tvalid, egr_tid, egr_tuser} <= axi4s_ing_fifo[ING_FIFO_STAGES_C-1];

    end
  end


  cordic_radian_top #(
    .DATA_WIDTH_P      ( AXI_DATA_WIDTH_P  ),
    .NR_OF_STAGES_P    ( NR_OF_STAGES_P    )

  ) cordic_radian_top_i0 (

    // Clock and reset
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),

    // Vectors
    .ing_theta_vector  ( ing_tdata         ),
    .egr_sine_vector   ( egr_sine_vector   ),
    .egr_cosine_vector ( egr_cosine_vector )
  );

endmodule

`default_nettype wire
