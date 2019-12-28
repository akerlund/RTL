`timescale 1ns / 1ps

module xadc_wrapper (
  input  wire         clk,
  input  wire         rst_n,
  input  wire         axis_o_tready,
  output logic [15:0] axis_o_tdata,
  output logic        axis_o_tvalid,
  output logic  [4:0] axis_o_tuser,

  // XDC Pins
  input  wire         DCLK,  // Clock input for DRP
  input  wire   [3:0] VAUXP, // Auxiliary analog channel inputs
  input  wire   [3:0] VAUXN,
  input  wire         VP,    // Dedicated and Hardwired Analog Input Pair
  input  wire         VN
);

  assign axis_o_tdata  = {4'h0, MEASURED_VCCAUX[15:4]};
  assign axis_o_tvalid = axis_o_tready;

  ug480 ug480_i0 (v
    .DCLK             ( clk              ),
    .RESET            ( ~rst_n           ),
    .VAUXP            ( VAUXP            ),
    .VAUXN            ( VAUXN            ),
    .VP               ( VP               ),
    .VN               ( VN               ),
    .MEASURED_TEMP    ( MEASURED_TEMP    ),
    .MEASURED_VCCINT  ( MEASURED_VCCINT  ),
    .MEASURED_VCCAUX  ( MEASURED_VCCAUX  ),
    .MEASURED_VCCBRAM ( MEASURED_VCCBRAM ),
    .MEASURED_AUX0    ( MEASURED_AUX0    ),
    .MEASURED_AUX1    ( MEASURED_AUX1    ),
    .MEASURED_AUX2    ( MEASURED_AUX2    ),
    .MEASURED_AUX3    ( MEASURED_AUX3    ),
    .ALM              ( ALM              ),
    .CHANNEL          ( CHANNEL          ),
    .OT               ( OT               ),
    .XADC_EOC         ( XADC_EOC         ),
    .XADC_EO          ( XADC_EO          )
   );

endmodule