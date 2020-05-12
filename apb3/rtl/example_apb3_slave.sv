`default_nettype none

module example_apb3_slave #(
    parameter int APB3_BASE_ADDR  = -1,
    parameter int APB3_ADDR_WIDTH = -1,
    parameter int APB3_DATA_WIDTH = -1
  )(
    input  wire                          clk,
    input  wire                          rst_n,

    input  wire                          apb3_psel,
    output logic                         apb3_pready,
    output logic [APB3_DATA_WIDTH-1 : 0] apb3_prdata,
    input  wire                          apb3_pwrite,
    input  wire                          apb3_penable,
    input  wire  [APB3_ADDR_WIDTH-1 : 0] apb3_paddr,
    input  wire  [APB3_DATA_WIDTH-1 : 0] apb3_pwdata,

    // Configuration registers
    output logic [APB3_DATA_WIDTH-1 : 0] cr_example0,

    // Status registers
    input  wire  [APB3_DATA_WIDTH-1 : 0] sr_example0
  );

  localparam logic [APB3_ADDR_WIDTH-1 : 0] CR_EXAMPLE0_ADDR_C = APB3_BASE_ADDR + 0;
  localparam logic [APB3_ADDR_WIDTH-1 : 0] SR_EXAMPLE0_ADDR_C = APB3_BASE_ADDR + 4;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin

      // APB interfaces
      apb3_pready  <= '0;
      apb3_prdata  <= '0;

      // Configuration registers
      cr_example0 <= '0;

    end
    else begin

      apb3_pready <= '0;
      apb3_prdata <= '0;

      if (apb3_psel) begin

        apb3_pready <= '1;

        if (apb3_penable && apb3_pready) begin

          // ---------------------------------------------------------------------
          // Writes
          // ---------------------------------------------------------------------

          if (apb3_pwrite) begin

            if (apb3_paddr == CR_EXAMPLE0_ADDR_C) begin
              cr_example0 <= apb3_pwdata;
            end

          end

          // ---------------------------------------------------------------------
          // Reads
          // ---------------------------------------------------------------------

          else begin

            if (apb3_paddr == SR_EXAMPLE0_ADDR_C) begin
              apb3_prdata <= sr_example0;
            end

          end
        end
      end
    end
  end

endmodule

`default_nettype wire
