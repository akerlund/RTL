`default_nettype none

module cdc_bit_sync_core (

    input  wire  clk_src,
    input  wire  rst_src_n,
    input  wire  clk_dst,
    input  wire  rst_dst_n,

    input  wire  src_bit,
    output logic dst_bit
  );

  logic src_bit_d0;
  logic dst_bit_d0;

  always_ff @ (posedge clk_src or negedge rst_src_n) begin
    if (!rst_src_n) begin
      src_bit_d0 <= '0;
    end
    else begin
      src_bit_d0 <= src_bit;
    end
  end

  always_ff @ (posedge clk_dst or negedge rst_dst_n) begin
    if (!rst_dst_n) begin
      dst_bit_d0 <= '0;
      dst_bit    <= '0;
    end
    else begin
      dst_bit_d0 <= src_bit_d0;
      dst_bit    <= dst_bit_d0;
    end
  end

endmodule

`default_nettype wire
