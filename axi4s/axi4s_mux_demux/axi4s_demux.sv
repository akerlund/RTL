`default_nettype none

module axi4s_demux #(
    parameter int nr_of_streams_p = -1,
    parameter int tdata_width_p   = -1,
    parameter int tid_bit_width_p = $clog2(nr_of_streams_p)
  )(
    // Clock and reset
    input  wire                                                clk,
    input  wire                                                rst_n,

    // AXI4-S master side
    output logic                                               axi4s_i_tready,
    input  wire                                                axi4s_i_tvalid,
    input  wire                                                axi4s_i_tlast,
    input  wire                        [tid_bit_width_p-1 : 0] axi4s_i_tid,
    input  wire                          [tdata_width_p-1 : 0] axi4s_i_tdata,

    // AXI4-S slave side
    input  wire                        [nr_of_streams_p-1 : 0] axi4s_o_tready,
    output logic                       [nr_of_streams_p-1 : 0] axi4s_o_tvalid,
    output logic                       [nr_of_streams_p-1 : 0] axi4s_o_tlast,
    output logic [nr_of_streams_p-1 : 0] [tdata_width_p-1 : 0] axi4s_o_tdata
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      axi4s_i_tready <= '0;
      axi4s_o_tdata  <= '0;
      axi4s_o_tvalid <= '0;
      axi4s_o_tlast  <= '0;
    end
    else begin

      if (axi4s_i_tvalid) begin
        axi4s_i_tready              <= axi4s_o_tready[axi4s_i_tid];
        axi4s_o_tvalid[axi4s_i_tid] <= axi4s_i_tvalid;
        axi4s_o_tlast[axi4s_i_tid]  <= axi4s_i_tlast;
        axi4s_o_tdata[axi4s_i_tid]  <= axi4s_i_tdata;
      end
      else begin
        axi4s_i_tready              <= '0;
        axi4s_o_tvalid[axi4s_i_tid] <= '0;
        axi4s_o_tlast[axi4s_i_tid]  <= '0;
        axi4s_o_tdata[axi4s_i_tid]  <= '0;
      end
    end
  end
endmodule

`default_nettype wire
