`timescale 1ns / 1ps

module ug480 (
  input wire          DCLK,  // Clock input for DRP
  input wire          RESET,
  input wire    [3:0] VAUXP, // Auxiliary analog channel inputs
  input wire    [3:0] VAUXN,
  input wire          VP,
  input wire          VN,    // Dedicated and Hardwired Analog Input Pair

  output logic [15:0] MEASURED_TEMP,
  output logic [15:0] MEASURED_VCCINT,
  output logic [15:0] MEASURED_VCCAUX,
  output logic [15:0] MEASURED_VCCBRAM,
  output logic [15:0] MEASURED_AUX0,
  output logic [15:0] MEASURED_AUX1,
  output logic [15:0] MEASURED_AUX2,
  output logic [15:0] MEASURED_AUX3,
  output logic  [7:0] ALM,
  output logic  [4:0] CHANNEL,
  output logic        OT,
  output logic        XADC_EOC,
  output logic        XADC_EOS
 );

  parameter bit [7:0] init_read      = 8'h00;
  parameter bit [7:0] read_waitdrdy  = 8'h01;
  parameter bit [7:0] write_waitdrdy = 8'h03;
  parameter bit [7:0] read_reg00     = 8'h04;
  parameter bit [7:0] reg00_waitdrdy = 8'h05;
  parameter bit [7:0] read_reg01     = 8'h06;
  parameter bit [7:0] reg01_waitdrdy = 8'h07;
  parameter bit [7:0] read_reg02     = 8'h08;
  parameter bit [7:0] reg02_waitdrdy = 8'h09;
  parameter bit [7:0] read_reg06     = 8'h0a;
  parameter bit [7:0] reg06_waitdrdy = 8'h0b;
  parameter bit [7:0] read_reg10     = 8'h0c;
  parameter bit [7:0] reg10_waitdrdy = 8'h0d;
  parameter bit [7:0] read_reg11     = 8'h0e;
  parameter bit [7:0] reg11_waitdrdy = 8'h0f;
  parameter bit [7:0] read_reg12     = 8'h10;
  parameter bit [7:0] reg12_waitdrdy = 8'h11;
  parameter bit [7:0] read_reg13     = 8'h12;
  parameter bit [7:0] reg13_waitdrdy = 8'h13;

  wire         busy;
  wire   [5:0] channel;
  wire         drdy;
  logic  [6:0] daddr;
  logic [15:0] di_drp;
  wire  [15:0] do_drp;
  wire  [15:0] vauxp_active;
  wire  [15:0] vauxn_active;
  logic  [1:0] den_reg;
  logic  [1:0] dwe_reg;

  logic  [7:0] state = init_read;

  assign vauxp_active = {12'h000, VAUXP[3:0]};
  assign vauxn_active = {12'h000, VAUXN[3:0]};


  always @(negedge RESET or posedge DCLK) begin
    if (~RESET) begin
      state   <= init_read;
      den_reg <= 2'h0;
      dwe_reg <= 2'h0;
      di_drp  <= 16'h0000;
    end
    else begin
      case (state)

        init_read : begin
          daddr   = 7'h40;
          den_reg = 2'h2;           // performing read
          if (busy == 0 ) begin
            state <= read_waitdrdy;
          end
        end

        read_waitdrdy : begin
          if (drdy == 1) begin
            di_drp  = do_drp & 16'h03_FF; //Clearing AVG bits for Configreg0
            daddr   = 7'h40;
            den_reg = 2'h2;
            dwe_reg = 2'h2;               // performing write
            state   = write_waitdrdy;
          end
          else begin
            den_reg = { 1'b0, den_reg[1] };
            dwe_reg = { 1'b0, dwe_reg[1] };
            state   = state;
          end
        end

        write_waitdrdy : begin
          if (drdy == 1) begin
            state = read_reg00;
          end
          else begin
            den_reg = { 1'b0, den_reg[1] };
            dwe_reg = { 1'b0, dwe_reg[1] };
            state   = state;
          end
        end

        read_reg00 : begin
          daddr   = 7'h00;
          den_reg = 2'h2; // performing read
          if (XADC_EOC == 1) begin
            state <= reg00_waitdrdy;
          end
        end

        reg00_waitdrdy : begin
          if (drdy == 1) begin
            MEASURED_TEMP =  do_drp;
            state         <= read_reg01;
          end
          else begin
            den_reg = { 1'b0, den_reg[1] };
            dwe_reg = { 1'b0, dwe_reg[1] };
            state   = state;
          end
        end

        read_reg01 : begin
          daddr   = 7'h01;
          den_reg = 2'h2; // performing read
          state   <= reg01_waitdrdy;
        end

        reg01_waitdrdy :
        if (drdy == 1) begin
          MEASURED_VCCINT = do_drp;
          state <= read_reg02;
        end
        else begin
          den_reg = { 1'b0, den_reg[1] };
          dwe_reg = { 1'b0, dwe_reg[1] };
          state   = state;
        end

        read_reg02 : begin
          daddr   = 7'h02;
          den_reg = 2'h2; // performing read
          state   <= reg02_waitdrdy;
        end

        reg02_waitdrdy : begin
          if (drdy == 1) begin
          MEASURED_VCCAUX =  do_drp;
          state           <= read_reg06;
          end
          else begin
          den_reg = { 1'b0, den_reg[1] };
          dwe_reg = { 1'b0, dwe_reg[1] };
          state   = state;
          end
        end

        read_reg06 : begin
          daddr   = 7'h06;
          den_reg = 2'h2; // performing read
          state   <= reg06_waitdrdy;
        end

        reg06_waitdrdy : begin
          if (drdy == 1) begin
          	MEASURED_VCCBRAM =  do_drp;
            state            <= read_reg10;
          end
          else begin
          den_reg = { 1'b0, den_reg[1] };
          dwe_reg = { 1'b0, dwe_reg[1] };
          state   = state;
          end
        end

        read_reg10 : begin
          daddr   = 7'h10;
          den_reg = 2'h2; // performing read
          state   <= reg10_waitdrdy;
        end

        reg10_waitdrdy : begin
          if (drdy == 1) begin
          MEASURED_AUX0 = do_drp;
          state <= read_reg11;
          end
          else begin
          den_reg = { 1'b0, den_reg[1] };
          dwe_reg = { 1'b0, dwe_reg[1] };
          state   = state;
          end
        end

        read_reg11 : begin
          daddr   = 7'h11;
          den_reg = 2'h2; // performing read
          state   <= reg11_waitdrdy;
        end

        reg11_waitdrdy : begin
          if (drdy == 1) begin
            MEASURED_AUX1 = do_drp;
            state         <= read_reg12;
          end
          else begin
            den_reg = { 1'b0, den_reg[1] };
            dwe_reg = { 1'b0, dwe_reg[1] };
            state   = state;
          end
        end

        read_reg12 : begin
          daddr   = 7'h12;
          den_reg = 2'h2; // performing read
          state   <= reg12_waitdrdy;
        end

        reg12_waitdrdy : begin
          if (drdy == 1) begin
            MEASURED_AUX2 = do_drp;
            state         <= read_reg13;
          end
          else begin
            den_reg = { 1'b0, den_reg[1] };
            dwe_reg = { 1'b0, dwe_reg[1] };
            state   = state;
          end
        end

        read_reg13 : begin
        daddr   = 7'h13;
        den_reg = 2'h2; // performing read
        state <= reg13_waitdrdy;
        end

        reg13_waitdrdy : begin
          if (drdy == 1) begin
            MEASURED_AUX3 =  do_drp;
            state         <= read_reg00;
            daddr         =  7'h00;
          end
          else begin
            den_reg = { 1'b0, den_reg[1] };
            dwe_reg = { 1'b0, dwe_reg[1] };
            state   = state;
          end
        end
      endcase
    end
  end

  XADC #(
    // Configuration registers
    .INIT_40          ( 16'h9000      ), // averaging of 16 selected for external channels
    .INIT_41          ( 16'h2ef0      ), // Continuous Seq Mode, Disable unused ALMs, Enable calibration
    .INIT_42          ( 16'h0400      ), // Set DCLK divides
    // Sequence registers
    .INIT_48          ( 16'h4701      ), // CHSEL1 - enable Temp VCCINT, VCCAUX, VCCBRAM, and calibration
    .INIT_49          ( 16'h000f      ), // CHSEL2 - enable aux analog channels 0 - 3
    .INIT_4A          ( 16'h0000      ), // SEQAVG1 disabled
    .INIT_4B          ( 16'h0000      ), // SEQAVG2 disabled
    .INIT_4C          ( 16'h0000      ), // SEQINMODE0
    .INIT_4D          ( 16'h0000      ), // SEQINMODE1
    .INIT_4E          ( 16'h0000      ), // SEQACQ0
    .INIT_4F          ( 16'h0000      ), // SEQACQ1
    // Alarm registers
    .INIT_50          ( 16'hb5ed      ), // Temp upper alarm trigger 85°C
    .INIT_51          ( 16'h5999      ), // Vccint upper alarm limit 1.05V
    .INIT_52          ( 16'hA147      ), // Vccaux upper alarm limit 1.89V
    .INIT_53          ( 16'h0000      ), // OT upper alarm limit 125°C using automatic shutdown - see Thermal Management
    .INIT_54          ( 16'ha93a      ), // Temp lower alarm reset 60°C
    .INIT_55          ( 16'h5111      ), // Vccint lower alarm limit 0.95V
    .INIT_56          ( 16'h91Eb      ), // Vccaux lower alarm limit 1.71V
    .INIT_57          ( 16'hae4e      ), // OT lower alarm reset 70°C - see Thermal Management
    .INIT_58          ( 16'h5999      ), // VCCBRAM upper alarm limit 1.05V
    .SIM_MONITOR_FILE ( "design.txt"  )  // Analog Stimulus file for simulation
  ) xadc_i0 (
    // Connect up instance IO.
    // See UG580 for port descriptions.
    .RESET            ( RESET         ), // Asynchronous reset signal for the XADC control logic. 
    .DCLK             ( DCLK          ),
    .DADDR            ( daddr         ),
    .DEN              ( den_reg[0]    ),
    .DI               ( di_drp        ),
    .DWE              ( dwe_reg[0]    ),
    .VAUXN            ( vauxn_active  ),
    .VAUXP            ( vauxp_active  ),
    .ALM              ( ALM           ),
    .BUSY             ( busy          ),
    .CHANNEL          ( CHANNEL       ),
    .DO               ( do_drp        ),
    .DRDY             ( drdy          ),
    .EOC              ( XADC_EOC      ),
    .EOS              ( XADC_EOS      ),
    .OT               ( OT            ),
    .VP               ( VP            ),
    .VN               ( VN            ),
    .CONVST           ( 1'b0          ), // not used
    .CONVSTCLK        ( 1'b0          ), // not used
    .JTAGBUSY         (               ), // not used
    .JTAGLOCKED       (               ), // not used
    .JTAGMODIFIED     (               ), // not used
    .MUXADDR          (               )  // not used
);

endmodule