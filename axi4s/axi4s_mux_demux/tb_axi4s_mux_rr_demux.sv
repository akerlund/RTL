`timescale 1ns/1ps

module tb_axi4s_mux_rr_demux;

  logic clk_125;
  logic rst_n;

  // Clock generation
  initial begin
    clk_125 = 1'b0;
    forever clk_125 = #4.0 ~clk_125;
  end

  // Reset logic
  initial begin
    rst_n       = 1'b0;
    #10ns rst_n = 1'b1;
  end

  // Constant parameters
  localparam int nr_of_streams_c = 4;
  localparam int tdata_width_p   = 3;
  localparam int nr_of_transfers = 5;

  // TB data vectors
  logic [nr_of_streams_c-1 : 0] [tdata_width_p*8-1 : 0] axi4s_tdata_ingress [nr_of_transfers];
  logic [nr_of_streams_c-1 : 0] [tdata_width_p*8-1 : 0] axi4s_tdata_egress  [nr_of_transfers];


  // Output signals fromthe MUX
  logic                       [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tready;

  // Input signals to the MUX
  logic                       [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tvalid;
  logic                       [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tlast;
  logic [nr_of_streams_c-1 : 0] [tdata_width_p-1 : 0] axi4s_mux_rr_i_tdata;

  // Signals from MUX to DEMUX
  logic                                               axi4s_mux_rr_o_tvalid;
  logic                                               axi4s_mux_rr_o_tlast;
  logic               [$clog2(nr_of_streams_c)-1 : 0] axi4s_mux_rr_o_tid;
  logic                         [tdata_width_p-1 : 0] axi4s_mux_rr_o_tdata;

  // Signals from DEMUX to MUX
  logic                                               axi4s_demux_i_tready;

  // Output signals from the DEMUX
  logic                       [nr_of_streams_c-1 : 0] axi4s_demux_o_tvalid;
  logic                       [nr_of_streams_c-1 : 0] axi4s_demux_o_tlast;
  logic [nr_of_streams_c-1 : 0] [tdata_width_p-1 : 0] axi4s_demux_o_tdata;

  // Input signals to the DEMUX
  logic                       [nr_of_streams_c-1 : 0] axi4s_demux_o_tready;


  // Main stimuli
  initial begin

    // Generate ingress data for all streams
    // for (int transfer = 0; transfer < nr_of_transfers; transfer++) begin
    //   for (int stream = 0; stream < nr_of_streams_c; stream++) begin
    //     axi4s_tdata_ingress[stream][transfer] <= $urandom();
    //     $display(axi4s_tdata_ingress[stream][transfer]);
    //   end
    // end

    //axi4s_mux_rr_i_tdata  <= {<<{axi4s_tdata_ingress}};
    //axi4s_mux_rr_i_tvalid <= {nr_of_streams_c{1'b1}};
    //axi4s_mux_rr_i_tlast  <= {nr_of_streams_c{1'b1}};

    @(posedge rst_n); $display("INFO [rst_n] Reset complete");


    // Save the output data
    // for (int i = 0; i < nr_of_streams_c; i++) begin
    //   wait (axi4s_demux_o_tvalid[i]);
    //   axi4s_mux_rr_i_tvalid[i] <= '0;
    //   axi4s_tdata_egress[i]    <= axi4s_tdata_egress[i] + (axi4s_demux_o_tdata << i);
    // end

    $display("Finished");
    $finish;

  end


  task name;

  endtask


  // // DUT instantiation
  // axi4s_mux_rr_demux #(
  //   .nr_of_streams_p       ( nr_of_streams_c       ),
  //   .tdata_width_p         ( tdata_width_p         )
  // ) axi4s_mux_rr_demux_i0 (

  //   // Clock and reset
  //   .clk                   ( clk_125               ), // input
  //   .rst_n                 ( rst_n                 ), // input

  //   // MUX AXI4-S master side
  //   .axi4s_mux_rr_i_tready ( axi4s_mux_rr_i_tready ), // output
  //   .axi4s_mux_rr_i_tvalid ( axi4s_mux_rr_i_tvalid ), // input
  //   .axi4s_mux_rr_i_tlast  ( axi4s_mux_rr_i_tlast  ), // input
  //   .axi4s_mux_rr_i_tdata  ( axi4s_mux_rr_i_tdata  ), // input

  //   // MUX AXI4-S slave side
  //   .axi4s_mux_rr_o_tready ( axi4s_demux_i_tready  ), // input
  //   .axi4s_mux_rr_o_tvalid ( axi4s_mux_rr_o_tvalid ), // output
  //   .axi4s_mux_rr_o_tlast  ( axi4s_mux_rr_o_tlast  ), // output
  //   .axi4s_mux_rr_o_tid    ( axi4s_mux_rr_o_tid    ), // output
  //   .axi4s_mux_rr_o_tdata  ( axi4s_mux_rr_o_tdata  ), // output

  //   // DEMUX AXI4-S master side
  //   .axi4s_demux_i_tready  ( axi4s_demux_i_tready  ), // output
  //   .axi4s_demux_i_tvalid  ( axi4s_mux_rr_o_tvalid ), // input
  //   .axi4s_demux_i_tlast   ( axi4s_mux_rr_o_tlast  ), // input
  //   .axi4s_demux_i_tid     ( axi4s_mux_rr_o_tid    ), // input
  //   .axi4s_demux_i_tdata   ( axi4s_mux_rr_o_tdata  ), // input

  //   // DEMUX AXI4-S slave side
  //   .axi4s_demux_o_tready  ( 1'b1                  ), // input
  //   .axi4s_demux_o_tvalid  ( axi4s_demux_o_tvalid  ), // output
  //   .axi4s_demux_o_tlast   ( axi4s_demux_o_tlast   ), // output
  //   .axi4s_demux_o_tdata   ( axi4s_demux_o_tdata   )  // output
  // );

endmodule
