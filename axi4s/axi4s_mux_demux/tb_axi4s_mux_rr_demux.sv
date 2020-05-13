`timescale 1ns/1ps

module tb_axi4s_mux_rr_demux;

  //////////////////////////////////////////////////////////////////////////////
  // Testbench settings
  //////////////////////////////////////////////////////////////////////////////

  // How many connections there are to a MUX or from a DEMUX
  localparam int nr_of_streams_c   = 4;
  // AXI4-S tdata width in bytes
  localparam int tdata_width_p     = 3;
  // How many transfers there will be per stream
  localparam int nr_of_transfers_c = 10;
  // Either random data or counter data, i.e., 0, 1, 2, ..., (nr_of_streams_c * nr_of_transfers_c)
  localparam int randomize_stream_data_c = 0;

  //////////////////////////////////////////////////////////////////////////////
  // Signals
  //////////////////////////////////////////////////////////////////////////////

  // Clock and reset
  logic clk;
  logic rst_n;

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

  //////////////////////////////////////////////////////////////////////////////
  // Variables and logics
  //////////////////////////////////////////////////////////////////////////////

  // TB data matrix shape: (y-axis) stream_nr * (x-axis) transfer_data
  logic [nr_of_streams_c-1 : 0] [nr_of_transfers_c-1 : 0] [tdata_width_p*8-1 : 0] axi4s_tdata_ingress;

  // Scoreboard variables
  int nr_of_received;
  int nr_of_mismatches;
  int test_passed_ok;

  // Egress variables
  int stream_counter;
  int transfer_counter;

  //////////////////////////////////////////////////////////////////////////////
  // Main stimuli
  //////////////////////////////////////////////////////////////////////////////
  initial begin

    $display("INFO [run] Running TB: tb_axi4s_mux_rr_demux");

    // Generate ingress data for all (nr_of_streams_c) streams
    for (int stream = 0; stream < nr_of_streams_c; stream++) begin
      for (int transfer = 0; transfer < nr_of_transfers_c; transfer++) begin
        if (!randomize_stream_data_c) begin
          axi4s_tdata_ingress[stream][transfer] <= stream*nr_of_transfers_c + transfer + 1;
        end
        else begin
          axi4s_tdata_ingress[stream][transfer] <= $urandom();
        end
      end
    end

    // Reset
    axi4s_mux_rr_i_tdata  <= '0;
    axi4s_mux_rr_i_tvalid <= '0;
    axi4s_mux_rr_i_tlast  <= '0;
    axi4s_demux_o_tready  <= '0;
    nr_of_received         = 0;
    nr_of_mismatches       = 0;
    test_passed_ok         = 1;
    stream_counter         = 0;
    transfer_counter       = 0;

    @(posedge rst_n);
    $display("INFO [rst_n] Reset complete");

    @(posedge clk)
    axi4s_demux_o_tready  <= '1;

    // Start sending data to multiplexer and receiving from the de-multiplexer
    fork
      // Ingress of multiplexer
      begin

        for (int stream = 0; stream < nr_of_streams_c; stream++) begin

          for (int transfer = 0; transfer < nr_of_transfers_c; transfer++) begin

            axi4s_mux_rr_i_tvalid[stream] <= '1;
            axi4s_mux_rr_i_tdata[stream]  <= axi4s_tdata_ingress[stream][transfer];

            wait (axi4s_mux_rr_i_tready[stream] == '1);

            if (transfer == nr_of_transfers_c-1) begin
              axi4s_mux_rr_i_tlast <= '1;
            end
            else begin
              axi4s_mux_rr_i_tlast <= '0;
            end

            @(posedge clk);

          end

          // Reset before next stream's transfer
          @(negedge clk);
          axi4s_mux_rr_i_tvalid <= '0;
          axi4s_mux_rr_i_tlast  <= '0;
          axi4s_mux_rr_i_tdata  <= '0;
          @(posedge clk);
        end
      end

      // Egress of de-multiplexer
      begin
        while (nr_of_received != nr_of_streams_c*nr_of_transfers_c) begin
          @(posedge clk);
          if (axi4s_demux_o_tvalid) begin

            nr_of_received++;

            if (axi4s_tdata_ingress[stream_counter][transfer_counter] != axi4s_demux_o_tdata) begin
              $display("WARNING [cmp] Data mismatch");
              nr_of_mismatches++;
            end

            transfer_counter++;
            if (transfer_counter == nr_of_transfers_c) begin
              transfer_counter = 0;
              stream_counter++;
              if (stream_counter == nr_of_streams_c) begin
                break;
              end
            end

          end
        end
      end
    join


    if (nr_of_received != nr_of_streams_c*nr_of_transfers_c) begin
      $error("ERROR [tb] Number of ingress transfers mismatches the number of egress transfers");
      test_passed_ok = 0;
    end

    if (nr_of_mismatches != 0) begin
      $error("ERROR [tb] There was (%0d) mismatching transfers", nr_of_mismatches);
      test_passed_ok = 0;
    end

    if (test_passed_ok) begin
      $display("INFO [tb] Finished: Successfully");
    end
    else begin
      $display("ERROR [tb] Finished: Run generated errors");
    end

    $finish;

  end

  //////////////////////////////////////////////////////////////////////////////
  // Clock and reset
  //////////////////////////////////////////////////////////////////////////////

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

  //////////////////////////////////////////////////////////////////////////////
  // DUT instantiation
  //////////////////////////////////////////////////////////////////////////////

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
