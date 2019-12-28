module arbiter #(
    parameter nr_of_ports_p  = 4,    
    parameter arbiter_type_p = "PRIORITY", // arbitration arbiter_type_p: "PRIORITY" or "ROUND_ROBIN"
    parameter block_type_p   = "NONE",     // block_type_p arbiter_type_p: "NONE", "REQUEST", "ACKNOWLEDGE"
    parameter lsb_priority_p = "LOW"       // LSB priority: "LOW", "HIGH"
  )(
    input   wire                             clk,
    input   wire                             rst,
    input   wire         [nr_of_ports_p-1:0] request,
    input   wire         [nr_of_ports_p-1:0] acknowledge,
    output logic         [nr_of_ports_p-1:0] grant,
    output logic                             grant_valid,
    output logic [$clog2(nr_of_ports_p)-1:0] grant_encoded
);

  logic         [nr_of_ports_p-1:0] grant_reg;
  logic         [nr_of_ports_p-1:0] grant_next;
  logic                             grant_valid_reg;
  logic                             grant_valid_next;
  logic [$clog2(nr_of_ports_p)-1:0] grant_encoded_reg;
  logic [$clog2(nr_of_ports_p)-1:0] grant_encoded_next;

  logic                             request_valid;
  logic [$clog2(nr_of_ports_p)-1:0] request_index;
  logic         [nr_of_ports_p-1:0] request_mask;

  logic         [nr_of_ports_p-1:0] mask_reg;
  logic         [nr_of_ports_p-1:0] mask_next;

  logic                             masked_request_valid;
  logic [$clog2(nr_of_ports_p)-1:0] masked_request_index;
  logic         [nr_of_ports_p-1:0] masked_request_mask;


  assign grant_valid   = grant_valid_reg;
  assign grant         = grant_reg;
  assign grant_encoded = grant_encoded_reg;

  priority_encoder #(
    .nr_of_ports_p    ( nr_of_ports_p  ),
    .lsb_priority_p   ( lsb_priority_p )
  ) priority_encoder_i0 (
    .input_unencoded  ( request        ),
    .output_valid     ( request_valid  ),
    .output_encoded   ( request_index  ),
    .output_unencoded ( request_mask   )
  );

  // masked
  priority_encoder #(
    .nr_of_ports_p    ( nr_of_ports_p        ),
    .lsb_priority_p   ( lsb_priority_p       )
  ) priority_encoder_i1 (
    .input_unencoded  ( request & mask_reg   ),
    .output_valid     ( masked_request_valid ),
    .output_encoded   ( masked_request_index ),
    .output_unencoded ( masked_request_mask  )
  );

  always_comb begin
    grant_next         <= 0;
    grant_valid_next   <= 0;
    grant_encoded_next <= 0;
    mask_next          <= mask_reg;

    if (block_type_p == "REQUEST" && grant_reg & request) begin
      // granted request still asserted; hold it
      grant_valid_next   = grant_valid_reg;
      grant_next         = grant_reg;
      grant_encoded_next = grant_encoded_reg;

    end
    else if (block_type_p == "ACKNOWLEDGE" && grant_valid && !(grant_reg & acknowledge)) begin
      // granted request not yet acknowledged; hold it
      grant_valid_next   <= grant_valid_reg;
      grant_next         <= grant_reg;
      grant_encoded_next <= grant_encoded_reg;

    end
    else if (request_valid) begin

      if (arbiter_type_p == "PRIORITY") begin
        grant_valid_next   <= 1;
        grant_next         <= request_mask;
        grant_encoded_next <= request_index;
      end
      else if (arbiter_type_p == "ROUND_ROBIN") begin
        if (masked_request_valid) begin
          grant_valid_next   <= 1;
          grant_next         <= masked_request_mask;
          grant_encoded_next <= masked_request_index;

          if (lsb_priority_p == "LOW") begin
            mask_next <= {nr_of_ports_p{1'b1}} >> (nr_of_ports_p - masked_request_index);
          end
          else begin
            mask_next <= {nr_of_ports_p{1'b1}} << (masked_request_index + 1);
          end
        end
        else begin
          grant_valid_next   <= 1;
          grant_next         <= request_mask;
          grant_encoded_next <= request_index;
          if (lsb_priority_p == "LOW") begin
            mask_next <= {nr_of_ports_p{1'b1}} >> (nr_of_ports_p - request_index);
          end else begin
            mask_next <= {nr_of_ports_p{1'b1}} << (request_index + 1);
          end
        end
      end
    end
end

always_ff @ (posedge clk or negedge rst_n) begin
  if (rst_n) begin
    grant_reg         <= 0;
    grant_valid_reg   <= 0;
    grant_encoded_reg <= 0;
    mask_reg          <= 0;
  end
  else begin
    grant_reg         <= grant_next;
    grant_valid_reg   <= grant_valid_next;
    grant_encoded_reg <= grant_encoded_next;
    mask_reg          <= mask_next;
  end
end

endmodule
