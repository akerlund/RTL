`default_nettype none

module synchronous_fifo_register #(
    parameter int data_width_p    = -1,
    parameter int address_width_p = -1
  )(
    input  wire                      clk,
    input  wire                      rst_n,

    input  wire                      wp_write_en,
    input  wire   [data_width_p-1:0] wp_data_in,
    output logic                     wp_fifo_full,

    input  wire                      rp_read_en,
    output logic  [data_width_p-1:0] rp_data_out,
    output logic                     rp_fifo_empty,

    output logic [address_width_p:0] sr_fill_level
  );

  logic                       write_enable;
  logic [address_width_p-1:0] write_address;
  logic                       read_enable;
  logic [address_width_p-1:0] read_address;

  assign write_enable = wp_write_en && !wp_fifo_full;
  assign read_enable  = rp_read_en  && !rp_fifo_empty;

  assign wp_fifo_full = sr_fill_level[address_width_p];

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      write_address <= '0;
      read_address  <= '0;
      sr_fill_level <= '0;
      rp_fifo_empty <= '1;
    end
    else begin
      if (write_enable) begin
        write_address <= write_address + 1;
        if (read_enable) begin
          read_address <= read_address + 1;
        end
        else begin
          sr_fill_level <= sr_fill_level + 1;
          rp_fifo_empty <= '0;
        end
      end
      else if (read_enable) begin
        read_address  <= read_address  + 1;
        sr_fill_level <= sr_fill_level - 1;
        if (sr_fill_level == 1) begin
          rp_fifo_empty <= '1;
        end
      end
    end
  end

  fpga_reg_1c_1w_1r #(
    .data_width_p    ( data_width_p    ),
    .address_width_p ( address_width_p )
  ) fpga_reg_1c_1w_1r_i0 (
    .clk             ( clk             ),
    .port_a_write_en ( write_enable    ),
    .port_a_address  ( write_address   ),
    .port_a_data_in  ( wp_data_in      ),
    .port_b_address  ( read_address    ),
    .port_b_data_out ( rp_data_out     )
  );


endmodule

`default_nettype wire
