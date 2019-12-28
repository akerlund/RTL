`default_nettype none

module axi4s_mux_rr #(
    // User parameters
    parameter int nr_of_streams_p    = -1,
    parameter int tdata_byte_width_p = -1,
    // Internally used parameters
    parameter int byte_width_p       = nr_of_streams_p * tdata_byte_width_p,
    parameter int tid_bit_width_p    = nr_of_streams_p * $clog2(nr_of_streams_p)
  )(
    input  wire                                clk,
    input  wire                                rst_n,

    // AXI4-S master side
    output logic         [nr_of_streams_p-1:0] axi4s_i_tready,
    input  wire             [byte_width_p-1:0] axi4s_i_tdata,
    input  wire          [nr_of_streams_p-1:0] axi4s_i_tvalid,
    input  wire          [nr_of_streams_p-1:0] axi4s_i_tlast,
    input  wire          [tid_bit_width_p-1:0] axi4s_i_tid,

    // AXI4-S slave side
    input  wire                                axi4s_o_tready,
    output logic      [tdata_byte_width_p-1:0] axi4s_o_tdata,
    output logic                               axi4s_o_tvalid,
    output logic                               axi4s_o_tlast,
    output logic [$clog2(nr_of_streams_p)-1:0] axi4s_o_tid
  );

  logic                               bus_is_locked;
  logic [$clog2(nr_of_streams_p)-1:0] round_robin_counter;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      axi4s_i_tready      <= '0;

      axi4s_o_tvalid      <= '0;
      axi4s_o_tdata       <= '0;
      axi4s_o_tlast       <= '0;
      axi4s_o_tid         <= '0;

      bus_is_locked       <= '0;
      round_robin_counter <= '0;
    end
    else begin

      axi4s_i_tready[round_robin_counter] <= axi4s_o_tready;
      axi4s_o_tvalid                      <= axi4s_i_tvalid[round_robin_counter];
      axi4s_o_tdata                       <= axi4s_i_tdata[round_robin_counter*tdata_byte_width_p +: tdata_byte_width_p];
      axi4s_o_tlast                       <= axi4s_i_tlast[round_robin_counter];
      axi4s_o_tid                         <= axi4s_i_tid;

      // MUX is not locked, finding a valid input
      if (!bus_is_locked) begin

        if (axi4s_i_tvalid[round_robin_counter] && !axi4s_o_tvalid && !bus_is_locked) begin
          bus_is_locked <= 1;
        end
        else if ( round_robin_counter == (nr_of_streams_p-1) ) begin
            round_robin_counter <= '0;
        end
        else begin
          round_robin_counter <= round_robin_counter + 1;
        end

      end
      // MUX is locked, waiting for transaction to finish
      else begin

        // Stop when: tlast == 1 or tvalid != 1
        if ( axi4s_i_tlast[round_robin_counter] || !axi4s_i_tvalid[round_robin_counter] ) begin
          bus_is_locked                       <= '0;
          axi4s_i_tready[round_robin_counter] <= '0;
        end

      end
    end
  end

endmodule

`default_nettype wire