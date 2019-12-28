`timescale 1ns/1ps

module tb_axi4s_mux_rr_demux;

  logic clk_125;
  logic res_n;

  // Clock generation
  initial begin
    clk_125 = 1'b0;
    forever clk_125 = #4.0 ~clk_125;
  end

  // Reset logic
  initial begin
    res_n       = 1'b0;
    #10ns res_n = 1'b1;
  end

  // Constant parameters
  localparam int nr_of_streams_c    = 4;
  localparam int tdata_byte_width_c = 3;

  // TB data vectors
  logic                 [tdata_byte_width_c*8-1 : 0] axi4s_tdata_ingress [nr_of_streams_c];
  logic                 [tdata_byte_width_c*8-1 : 0] axi4s_tdata_egress  [nr_of_streams_c];

  // Input signals to the MUX
  logic                      [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tready;
  logic [nr_of_streams_c*tdata_byte_width_c*8-1 : 0] axi4s_mux_rr_i_tdata;
  logic                      [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tvalid;
  logic                      [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tlast;
  logic              [$clog2(nr_of_streams_c)-1 : 0] axi4s_mux_rr_i_tid;

  // Signals between MUX and DEMUX
  logic                   [tdata_byte_width_c-1 : 0] axi4s_mux_rr_o_tdata;
  logic                                              axi4s_mux_rr_o_tvalid;
  logic                                              axi4s_mux_rr_o_tlast;
  logic              [$clog2(nr_of_streams_c)-1 : 0] axi4s_mux_rr_o_tid;

  logic                                              axi4s_demux_i_tready;

  // Output signals from the DEMUX
  logic                   [tdata_byte_width_c-1 : 0] axi4s_demux_o_tdata;
  logic                      [nr_of_streams_c-1 : 0] axi4s_demux_o_tvalid;
  logic                      [nr_of_streams_c-1 : 0] axi4s_demux_o_tlast;
  logic              [$clog2(nr_of_streams_c)-1 : 0] axi4s_demux_o_tid;

  // Main stimuli
  initial begin

    for (int i = 0; i < nr_of_streams_c; i++) begin
      // Data
      for (int j = 0; j < tdata_byte_width_c; j++) begin
        axi4s_tdata_ingress[i] <= axi4s_tdata_ingress[i] + ((i+1) << (j*8));
      end
      // ID
      axi4s_mux_rr_i_tid[$clog2(nr_of_streams_c)*(i+1) +: $clog2(nr_of_streams_c)] <= i;
    end

    axi4s_mux_rr_i_tdata  <= {<<{axi4s_tdata_ingress}};
    axi4s_mux_rr_i_tvalid <= {nr_of_streams_c{1'b1}};
    axi4s_mux_rr_i_tlast  <= {nr_of_streams_c{1'b1}};

    @(posedge res_n); $display("Reset complete");


    // Save the output data
    for (int i = 0; i < nr_of_streams_c; i++) begin
      wait (axi4s_demux_o_tvalid[i]);
      axi4s_mux_rr_i_tvalid[i] <= '0;
      axi4s_tdata_egress[i]    <= axi4s_tdata_egress[i] + (axi4s_demux_o_tdata << i);
    end

    $display("Finished");
    $finish;

  end


  task name;

  endtask

   // DUT instantiation
  axi4s_mux_rr_demux #(
    .nr_of_streams_p       ( nr_of_streams_c       ),
    .tdata_byte_width_p    ( tdata_byte_width_c    )
  ) axi4s_mux_rr_demux_i0 (
    .clk                   ( clk_125               ),
    .rst_n                 ( res_n                 ),
    .axi4s_mux_rr_i_tready ( axi4s_mux_rr_i_tready ),
    .axi4s_mux_rr_i_tdata  ( axi4s_mux_rr_i_tdata  ),
    .axi4s_mux_rr_i_tvalid ( axi4s_mux_rr_i_tvalid ),
    .axi4s_mux_rr_i_tlast  ( axi4s_mux_rr_i_tlast  ),
    .axi4s_mux_rr_i_tid    ( axi4s_mux_rr_i_tid    ),
    .axi4s_mux_rr_o_tready ( axi4s_demux_i_tready  ),
    .axi4s_mux_rr_o_tdata  ( axi4s_mux_rr_o_tdata  ),
    .axi4s_mux_rr_o_tvalid ( axi4s_mux_rr_o_tvalid ),
    .axi4s_mux_rr_o_tlast  ( axi4s_mux_rr_o_tlast  ),
    .axi4s_mux_rr_o_tid    ( axi4s_mux_rr_o_tid    ),
    .axi4s_demux_i_tready  ( axi4s_demux_i_tready  ),
    .axi4s_demux_i_tdata   ( axi4s_mux_rr_o_tdata  ),
    .axi4s_demux_i_tvalid  ( axi4s_mux_rr_o_tvalid ),
    .axi4s_demux_i_tlast   ( axi4s_mux_rr_o_tlast  ),
    .axi4s_demux_i_tid     ( axi4s_mux_rr_o_tid    ),
    .axi4s_demux_o_tready  ( 1'b1                  ),
    .axi4s_demux_o_tdata   ( axi4s_demux_o_tdata   ),
    .axi4s_demux_o_tvalid  ( axi4s_demux_o_tvalid  ),
    .axi4s_demux_o_tlast   ( axi4s_demux_o_tlast   ),
    .axi4s_demux_o_tid     ( axi4s_demux_o_tid     )
  );

endmodule
