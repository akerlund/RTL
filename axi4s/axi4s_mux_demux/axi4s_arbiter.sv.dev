`default_nettype none

module axi4s_arbiter #(
    parameter int nr_of_streams_p     = -1,
    parameter int byte_width_in       = -1,
    parameter int byte_width_out      = -1,
    parameter int axi4s_i_tdata_width = nr_of_streams_p*data_width_p
  )(
    input  wire                            clk,
    input  wire                            rst_n,

    // AXI4S slave side
    input  wire  [axi4s_i_tdata_width-1:0] axi4s_i_tdata,
    input  wire      [nr_of_streams_p-1:0] axi4s_i_tvalid,
    input  wire      [nr_of_streams_p-1:0] axi4s_i_tlast,
    output logic     [nr_of_streams_p-1:0] axi4s_i_tready,

    output logic        [data_width_p-1:0] axi4s_o_tdata,
    output logic                           axi4s_o_tvalid,
    input  wire      [nr_of_streams_p-1:0] axi4s_o_tready
  );

  logic                               bus_is_locked;
  logic [$clog2(nr_of_streams_p)-1:0] round_robin_counter;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      axi4s_i_tready      <= '0;
      axi4s_o_tdata       <= '0;
      axi4s_o_tvalid      <= '0;

      bus_is_locked       <= '0;
      round_robin_counter <= '0;
    end 
    else begin

      axi4s_i_tready      <= '0;
      axi4s_o_tvalid      <= '0;

      if (!bus_is_locked) begin
        if ( round_robin_counter == nr_of_streams_p - 1) begin
          round_robin_counter <= '0;
        end
        else begin
          round_robin_counter <= round_robin_counter + 1;
        end
      end

      if (axi4s_i_tvalid[round_robin_counter] && !axi4s_o_tvalid) begin
        bus_is_locked <= 1;
        axi4s_i_tready[round_robin_counter] <= 1;
        axi4s_o_tvalid                      <= 1;
        axi4s_o_tdata                       <= memory[axi4s_i_tdata];
      end
      else begin
        bus_is_locked <= '0;
      end

      if (axi4s_o_tvalid) begin
        axi4s_o_tvalid <= '0;
      end

    end
  end

endmodule

`default_nettype wire