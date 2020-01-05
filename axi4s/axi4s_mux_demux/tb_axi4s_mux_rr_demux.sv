`timescale 1ns/1ps

module tb_axi4s_mux_rr_demux;

  logic clk;
  logic rst_n;

  // Clock generation
  initial begin
    clk = 1'b0;
    forever clk = #4.0 ~clk;
  end

  // Reset logic
  initial begin
    rst_n       = 1'b0;
    #10ns rst_n = 1'b1;
  end

  // Constant parameters
  localparam int nr_of_streams_c   = 4;
  localparam int tdata_width_p     = 3;
  localparam int nr_of_transfers_c = 10;

  // TB data vectors
  logic [nr_of_streams_c-1 : 0] [tdata_width_p*8-1 : 0] axi4s_tdata_ingress [nr_of_transfers_c];
  logic [nr_of_streams_c-1 : 0] [tdata_width_p*8-1 : 0] axi4s_tdata_egress  [nr_of_transfers_c];


  // Output signals from the MUX
  logic                         [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tready;

  // Input signals to the MUX
  logic                         [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tvalid;
  logic                         [nr_of_streams_c-1 : 0] axi4s_mux_rr_i_tlast;
  logic [nr_of_streams_c-1 : 0] [tdata_width_p*8-1 : 0] axi4s_mux_rr_i_tdata;

  // Signals from MUX to DEMUX
  logic                                                 axi4s_mux_rr_o_tvalid;
  logic                                                 axi4s_mux_rr_o_tlast;
  logic                 [$clog2(nr_of_streams_c)-1 : 0] axi4s_mux_rr_o_tid;
  logic                         [tdata_width_p*8-1 : 0] axi4s_mux_rr_o_tdata;

  // Signals from DEMUX to MUX
  logic                                                 axi4s_demux_i_tready;

  // Output signals from the DEMUX
  logic                         [nr_of_streams_c-1 : 0] axi4s_demux_o_tvalid;
  logic                         [nr_of_streams_c-1 : 0] axi4s_demux_o_tlast;
  logic [nr_of_streams_c-1 : 0] [tdata_width_p*8-1 : 0] axi4s_demux_o_tdata;

  // Input signals to the DEMUX
  logic                         [nr_of_streams_c-1 : 0] axi4s_demux_o_tready;


  // Main stimuli
  initial begin

    $display("INFO [run] Running TB: tb_axi4s_mux_rr_demux");

    // Generate ingress data for all streams
    for (int stream = 0; stream < nr_of_streams_c; stream++) begin
      for (int transfer = 0; transfer < nr_of_transfers_c; transfer++) begin
        axi4s_tdata_ingress[transfer][stream] <= $urandom();
      end
    end

    // Reset
    axi4s_tdata_egress = '{default:0};

    axi4s_mux_rr_i_tdata  <= '0;
    axi4s_mux_rr_i_tvalid <= '0;
    axi4s_mux_rr_i_tlast  <= '0;

    axi4s_demux_o_tready  <= '0;

    @(posedge rst_n); $display("INFO [rst_n] Reset complete");

    axi4s_demux_o_tready  <= '1;

    fork

      // Ingress
      begin

        for (int stream = 0; stream < nr_of_streams_c; stream++) begin

          axi4s_mux_rr_i_tvalid[stream] <= '1;

          for (int transfer = 0; transfer < nr_of_transfers_c; transfer++) begin

            wait (axi4s_mux_rr_i_tready);
            @(posedge clk)

            axi4s_mux_rr_i_tdata[stream]  <= axi4s_tdata_ingress[transfer][stream];

            if (transfer == nr_of_transfers_c-1) begin
              axi4s_mux_rr_i_tlast <= '1;
            end
            else begin
              axi4s_mux_rr_i_tlast <= '0;
            end

          end

          // Reset before next stream's transfer
          @(negedge clk);
          axi4s_mux_rr_i_tvalid <= '0;
          axi4s_mux_rr_i_tlast  <= '0;
          axi4s_mux_rr_i_tdata  <= '0;
          @(posedge clk);

        end
      end

      // Egress
      begin
      end
    join

    $display("Finished");
    $finish;

  end


  task collect_egress_data;
    for (int i = 0; i < nr_of_streams_c; i++) begin
      wait (axi4s_demux_o_tvalid[i]);
      axi4s_mux_rr_i_tvalid[i] <= '0;
      axi4s_tdata_egress[i]    <= axi4s_tdata_egress[i] + (axi4s_demux_o_tdata << i);
    end
  endtask


  // DUT instantiation
  axi4s_mux_rr_demux #(
    .nr_of_streams_p       ( nr_of_streams_c       ),
    .tdata_width_p         ( tdata_width_p         )
  ) axi4s_mux_rr_demux_i0 (

    // Clock and reset
    .clk                   ( clk                   ), // input
    .rst_n                 ( rst_n                 ), // input

    // MUX AXI4-S master side
    .axi4s_mux_rr_i_tready ( axi4s_mux_rr_i_tready ), // output
    .axi4s_mux_rr_i_tvalid ( axi4s_mux_rr_i_tvalid ), // input
    .axi4s_mux_rr_i_tlast  ( axi4s_mux_rr_i_tlast  ), // input
    .axi4s_mux_rr_i_tdata  ( axi4s_mux_rr_i_tdata  ), // input

    // MUX AXI4-S slave side
    .axi4s_mux_rr_o_tready ( axi4s_demux_i_tready  ), // input
    .axi4s_mux_rr_o_tvalid ( axi4s_mux_rr_o_tvalid ), // output
    .axi4s_mux_rr_o_tlast  ( axi4s_mux_rr_o_tlast  ), // output
    .axi4s_mux_rr_o_tid    ( axi4s_mux_rr_o_tid    ), // output
    .axi4s_mux_rr_o_tdata  ( axi4s_mux_rr_o_tdata  ), // output

    // DEMUX AXI4-S master side
    .axi4s_demux_i_tready  ( axi4s_demux_i_tready  ), // output
    .axi4s_demux_i_tvalid  ( axi4s_mux_rr_o_tvalid ), // input
    .axi4s_demux_i_tlast   ( axi4s_mux_rr_o_tlast  ), // input
    .axi4s_demux_i_tid     ( axi4s_mux_rr_o_tid    ), // input
    .axi4s_demux_i_tdata   ( axi4s_mux_rr_o_tdata  ), // input

    // DEMUX AXI4-S slave side
    .axi4s_demux_o_tready  ( '1                    ), // input
    .axi4s_demux_o_tvalid  ( axi4s_demux_o_tvalid  ), // output
    .axi4s_demux_o_tlast   ( axi4s_demux_o_tlast   ), // output
    .axi4s_demux_o_tdata   ( axi4s_demux_o_tdata   )  // output
  );

endmodule
