`default_nettype none

module synchronous_fifo #(
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

    output logic [address_width_p:0] sr_fill_level,
    output logic [address_width_p:0] sr_max_fill_level
  );

  // FPGA will use RAM if the memory is larger than 2048 bits
  localparam bit generate_reg_fifo_c = data_width_p * 2**address_width_p <= 2048 ? 1'b1 : 1'b0;

  // Maximum fill level
  localparam logic [address_width_p:0] fifo_max_level_c = 2**address_width_p;

  logic                       write_enable;
  logic [address_width_p-1:0] write_address;
  logic                       read_enable;
  logic [address_width_p-1:0] read_address;

  assign write_enable = wp_write_en && (!wp_fifo_full || rp_read_en);
  assign read_enable  = rp_read_en  && !rp_fifo_empty;

  generate
    if (generate_reg_fifo_c) begin : gen_sync_reg

      // Generate with registers

      synchronous_fifo_register #(
        .data_width_p    ( data_width_p    ),
        .address_width_p ( address_width_p )
      ) synchronous_fifo_register_i0 (
        .clk             ( clk             ),
        .rst_n           ( rst_n           ),
        .wp_write_en     ( write_enable    ),
        .wp_data_in      ( wp_data_in      ),
        .wp_fifo_full    (                 ),
        .rp_read_en      ( read_enable     ),
        .rp_data_out     ( rp_data_out     ),
        .rp_fifo_empty   ( rp_fifo_empty   ),
        .sr_fill_level   (                 )
      );

    end
    else begin : gen_sync_ram

      // Generate with RAM

      logic [address_width_p-1:0] ram_write_address;
      logic [address_width_p-1:0] ram_read_address;
      logic    [data_width_p-1:0] ram_read_data;
      logic [address_width_p-1:0] ram_fill_level;

      logic                       reg_write_enable;
      logic                 [2:0] reg_fill_level;

      assign ram_fill_level = ram_write_address >= ram_read_address ?
                              {1'b0, ram_write_address} - {1'b0, ram_read_address} :
                              fifo_max_level_c - ({1'b0, ram_read_address} - {1'b0, ram_write_address});

      // Read and write process
      always_ff @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          ram_write_address <='0;
          ram_read_address  <='0;
          reg_write_enable  <='0;
        end
        else begin
          if (write_enable) begin
            ram_write_address <= ram_write_address + 1;
          end
          if (ram_fill_level > 0 && (reg_fill_level < 3 || read_enable)) begin
            ram_read_address <= ram_read_address + 1;
            reg_write_enable <= '1;
          end
          else begin
            reg_write_enable <= '0;
          end
        end
      end

      // Generate the FIFO's RAM
      fpga_ram_1c_1w_1r #(
        .data_width_p    ( data_width_p      ),
        .address_width_p ( address_width_p   )
      ) fpga_ram_1c_1w_1r_i0 (
        .clk             ( clk               ),
        .port_a_write_en ( write_enable      ),
        .port_a_address  ( ram_write_address ),
        .port_a_data_in  ( wp_data_in        ),
        .port_b_address  ( ram_read_address  ),
        .port_b_data_out ( ram_read_data     )
      );

      // Register at the output removes the delay of 1 clk period
      // it takes for RAM memories to output data
      synchronous_fifo_register #(
        .data_width_p    ( data_width_p     ),
        .address_width_p ( address_width_p  )
      ) synchronous_fifo_register_i0 (
        .clk             ( clk              ),
        .rst_n           ( rst_n            ),
        .wp_write_en     ( reg_write_enable ),
        .wp_data_in      ( ram_read_data    ),
        .wp_fifo_full    (                  ),
        .rp_read_en      ( read_enable      ),
        .rp_data_out     ( rp_data_out      ),
        .rp_fifo_empty   ( rp_fifo_empty    ),
        .sr_fill_level   ( reg_fill_level   )
      );

    end
  endgenerate

  // Status process
  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wp_fifo_full      <='0;
      sr_fill_level     <='0;
      sr_max_fill_level <='0;
    end
    else begin

      if (sr_fill_level == fifo_max_level_c) begin
        wp_fifo_full <= '1;
      end
      else begin
        wp_fifo_full <= '0;
      end

      if (read_enable && !write_enable) begin
        sr_fill_level <= sr_fill_level - 1;
      end
      else if (read_enable && !write_enable) begin
        sr_fill_level <= sr_fill_level + 1;
      end

      if (sr_fill_level >= sr_max_fill_level) begin
        sr_max_fill_level <= sr_fill_level;
      end

    end
  end

endmodule

`default_nettype wire
