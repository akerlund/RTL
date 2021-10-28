/*
 * BCH Encode/Decoder Modules
 *
 * Copyright 2014 - Russ Dill <russ.dill@asu.edu>
 * Distributed under 2-clause BSD license as contained in COPYING file.
 */
`timescale 1ns / 1ps

`include "bch_defs.vh"

module sim #(
    parameter [`BCH_PARAM_SZ-1:0] P = `BCH_SANE,
    parameter OPTION                = "SERIAL",
    parameter BITS                  = 1,
    parameter REG_RATIO             = 1
  )(
    input                         clk,
    input                         reset,
    input [`BCH_DATA_BITS(P)-1:0] data_in,
    input [`BCH_CODE_BITS(P)-1:0] error,
    input                         encode_start,
    output                        ready,
    output reg                    wrong = 0
);

  `include "bch.vh"

  localparam TCQ = 1;
  localparam N = `BCH_N(P);
  localparam E = `BCH_ECC_BITS(P);
  localparam M = `BCH_M(P);
  localparam T = `BCH_T(P);
  localparam K = `BCH_K(P);
  localparam B = `BCH_DATA_BITS(P);

  if (`BCH_DATA_BITS(P) % BITS)
    sim_only_supports_factors_of_BCH_DATA_BITS_for_BITS u_sosfobdbfb();

  function [BITS-1:0] reverse;
    input [BITS-1:0] in;
    integer i;
    begin
      for (i = 0; i < BITS; i = i + 1) begin
        reverse[i] = in[BITS - i - 1];
      end
    end
  endfunction

  reg [B-1:0] encode_buf = 0;
  reg [E+B-1:0] flip_buf = 0;
  reg [B-1:0] err_buf = 0;
  reg last_data_valid = 0;

  wire [BITS-1:0] encoded_data;
  wire encoded_first;
  wire encoded_last;
  wire [BITS-1:0] decoder_in;
  wire syndrome_ready;
  wire encode_ready;
  wire [`BCH_SYNDROMES_SZ(P)-1:0] syndromes;
  wire syn_done;
  wire err_first;
  wire err_last;
  wire err_valid;
  wire [BITS-1:0] err;
  wire            key_ready;
  wire            errors_present;
  wire            errors_present_done;
  wire [`BCH_ERR_SZ(P)-1:0] err_count;


  localparam STACK_SZ = 16;

  reg [STACK_SZ*`BCH_ERR_SZ(P)-1:0] err_count_stack = 0;
  reg [STACK_SZ-1:0] err_present_stack = 0;
  reg [STACK_SZ*`BCH_DATA_BITS(P)-1:0] err_stack = 0;

  reg [log2(STACK_SZ)-1:0] wr_pos = 0;
  reg [log2(STACK_SZ)-1:0] err_count_rd_pos = 0;
  reg [log2(STACK_SZ)-1:0] err_present_rd_pos = 0;
  reg [log2(STACK_SZ)-1:0] err_rd_pos = 0;

  wire err_count_overflow = ((wr_pos + 1) % STACK_SZ) === err_count_rd_pos;
  wire err_present_overflow = ((wr_pos + 1) % STACK_SZ) === err_present_rd_pos;
  wire err_overflow = ((wr_pos + 1) % STACK_SZ) === err_rd_pos;

  function integer bit_count;
    input [N-1:0] bits;
    integer count;
    integer i;
    begin
      count = 0;
      for (i = 0; i < N; i = i + 1) begin
        count = count + bits[i];
      end
      bit_count = count;
    end
  endfunction

  /* Don't assert start until we get the ready signal */
  wire syndrome_start = encoded_first && syndrome_ready;
  /* Keep adding data until the next stage is busy */
  wire syndrome_ce = !syn_done || key_ready;
  wire syndrome_accepted = syndrome_start && syndrome_ce;

  /* Don't assert start until we get the ready signal*/
  wire encode_ce = (!encoded_first || syndrome_ready) && syndrome_ce;
  /* Keep adding data until the decoder is busy */
  wire encode_accepted = encode_start && encode_ready && encode_ce;

  assign ready = encode_ready && encode_ce;

  always @(posedge clk) begin
    if (encode_accepted) begin
      err_stack[B*wr_pos+:B] <= #TCQ error;
      err_count_stack[`BCH_ERR_SZ(P)*wr_pos+:`BCH_ERR_SZ(P)] <= #TCQ bit_count(error);
      err_present_stack[wr_pos] <= #TCQ |error;
      wr_pos <= #TCQ (wr_pos + 1) % STACK_SZ;
    end

    if (encode_accepted) begin
      encode_buf <= #TCQ data_in >> BITS;
    end
    else if (!encode_ready && encode_ce) begin
      encode_buf <= #TCQ encode_buf >> BITS;
    end
  end

  /* Make it so we get the same syndromes, no matter what the word size */
  wire [BITS-1:0] encoder_in = reverse(encode_accepted ? data_in[BITS-1:0] : encode_buf[BITS-1:0]);

  wire data_bits;
  wire ecc_bits;

  /* Generate code */
  bch_encode #(
    .P               ( P                            ),
    .BITS            ( BITS                         ),
    .PIPELINE_STAGES ( 0                            )
  ) bch_encode_i0 (
    .clk             ( clk                          ), // input
    .start           ( encode_start && encode_ready ), // input
    .ready           ( encode_ready                 ), // output
    .ce              ( encode_ce                    ), // input
    .data_in         ( encoder_in                   ), // input
    .data_out        ( encoded_data                 ), // output
    .data_bits       ( data_bits                    ), // output
    .ecc_bits        ( ecc_bits                     ), // output
    .first           ( encoded_first                ), // output
    .last            ( encoded_last                 )  // output
  );

  reg ecc_bits_last = 0;

  always @(posedge clk) begin
    if (encode_ce) begin
      ecc_bits_last <= #TCQ ecc_bits;
    end
  end

  wire [BITS-1:0] xor_out;
  wire [BITS-1:0] encoded_data_xor;

  bch_blank_ecc #(
    .P               ( P                          ),
    .BITS            ( BITS                       ),
    .PIPELINE_STAGES ( 0                          )
  ) bch_blank_ecc_i0 (
    .clk             ( clk                        ), // input
    .start           ( ecc_bits && !ecc_bits_last ), // input
    .ce              ( encode_ce                  ), // input
    .xor_out         ( xor_out                    ), // output
    .first           (                            ), // output
    .last            (                            )  // output
  );

  assign encoded_data_xor = ecc_bits ? (encoded_data ^ xor_out) : encoded_data;

  wire [BITS-1:0] flip_err = reverse((syndrome_start && encode_accepted) ? error[BITS-1:0] : flip_buf[BITS-1:0]);

  assign decoder_in = encoded_data ^ flip_err;

  always @(posedge clk) begin
    if (encode_accepted) begin
      if (syndrome_start) begin
        flip_buf <= #TCQ error >> BITS;
      end
      else begin
        flip_buf <= #TCQ error;
      end
    end
    else if (syndrome_ce && encode_ce) begin
      flip_buf <= #TCQ flip_buf >> BITS;
    end
  end

  /* Process syndromes */
  bch_syndrome #(
    .P               ( P              ),
    .BITS            ( BITS           ),
    .REG_RATIO       ( REG_RATIO      ),
    .PIPELINE_STAGES ( 0              )
  ) bch_syndrome_i0 (
    .clk             ( clk            ), // input
    .start           ( syndrome_start ), // input
    .ready           ( syndrome_ready ), // output
    .ce              ( syndrome_ce    ), // input
    .data_in         ( decoder_in     ), // output
    .syndromes       ( syndromes      ), // output
    .done            ( syn_done       )  // output
  );

  /* Test for errors */

  // Also inside bch_syndrome.v
  bch_errors_present #(
    .P               ( P                     ),
    .PIPELINE_STAGES ( 0                     )
  ) bch_errors_present_i0 (
    .clk             ( clk                   ), // input
    .start           ( syn_done && key_ready ), // input
    .syndromes       ( syndromes             ), // input
    .done            ( errors_present_done   ), // output
    .errors_present  ( errors_present        )  // output
  );

  wire err_present_wrong = errors_present_done && (errors_present !== err_present_stack[err_present_rd_pos]);

  always @(posedge clk) begin
    if (errors_present_done) begin
      err_present_rd_pos = (err_present_rd_pos + 1) % STACK_SZ;
    end
  end

  wire err_count_wrong;

  if (T > 1 && (OPTION == "SERIAL" || OPTION == "PARALLEL" || OPTION == "NOINV")) begin : TMEC

    wire ch_start;
    wire [`BCH_SIGMA_SZ(P)-1:0] sigma;

    /* Solve key equation */
    if (OPTION == "SERIAL") begin : BMA_SERIAL

      bch_sigma_bma_serial #(
        .P         ( P                     )
      ) bch_sigma_bma_serial_i0 (
        .clk       ( clk                   ), // input
        .start     ( syn_done && key_ready ), // input
        .ready     ( key_ready             ), // output
        .syndromes ( syndromes             ), // input
        .sigma     ( sigma                 ), // output
        .done      ( ch_start              ), // output
        .ack_done  ( 1'b1                  ), // input
        .err_count ( err_count             )  // output
      );

    end
    else if (OPTION == "PARALLEL") begin : BMA_PARALLEL

      bch_sigma_bma_parallel #(
        .P         ( P                     )
      ) bch_sigma_bma_parallel_i0 (
        .clk       ( clk                   ), // input
        .start     ( syn_done && key_ready ), // input
        .ready     ( key_ready             ), // output
        .syndromes ( syndromes             ), // input
        .sigma     ( sigma                 ), // output
        .done      ( ch_start              ), // output
        .ack_done  ( 1'b1                  ), // input
        .err_count ( err_count             )  // output
      );

    end
    else if (OPTION == "NOINV") begin : BMA_NOINV

      bch_sigma_bma_noinv #(
        .P         ( P                     )
      ) bch_sigma_bma_noinv_i0 (
        .clk       ( clk                   ), // input
        .start     ( syn_done && key_ready ), // input
        .ready     ( key_ready             ), // output
        .syndromes ( syndromes             ), // input
        .sigma     ( sigma                 ), // output
        .done      ( ch_start              ), // output
        .ack_done  ( 1'b1                  ), // input
        .err_count ( err_count             )  // output
      );
    end

    assign err_count_wrong = ch_start && (err_count !== err_count_stack[err_count_rd_pos*`BCH_ERR_SZ(P)+:`BCH_ERR_SZ(P)]);

    always @(posedge clk) begin
      if (ch_start) begin
        err_count_rd_pos <= #TCQ (err_count_rd_pos + 1) % STACK_SZ;
      end
    end

    wire [BITS-1:0] err1;
    wire err_first1;

    /* Locate errors */
    bch_error_tmec #(
      .P         ( P         ),
      .BITS      ( BITS      ),
      .REG_RATIO ( REG_RATIO )
      //.PIPELINE_STAGES
      //.ACCUM
    ) bch_error_tmec_i0 (
      .clk       ( clk       ), // input
      .start     ( ch_start  ), // input
      .sigma     ( sigma     ), // input
      .first     ( err_first ), // output
      .err       ( err       )  // output
    );

    bch_error_one #(
      .P               ( P             ),
      .BITS            ( BITS          ),
      .PIPELINE_STAGES ( 0             )
    ) bch_error_one_i0 (
      .clk             ( clk           ), // input
      .start           ( ch_start      ), // input
      .sigma           ( sigma[0+:2*M] ), // input
      .first           ( err_first1    ), // output
      .err             ( err1          )  // output
    );

  end
  else begin : DEC

    assign key_ready = 1'b1;

    /* Locate errors */
    bch_error_dec #(
      .P               ( P                     ),
      .BITS            ( BITS                  ),
      .REG_RATIO       ( REG_RATIO             ),
      .PIPELINE_STAGES ( 0                     )
    ) bch_error_dec_i0 (
      .clk             ( clk                   ), // input
      .start           ( syn_done && key_ready ), // input
      .syndromes       ( syndromes             ), // input
      .first           ( err_first             ), // output
      .err             ( err                   ), // output
      .err_count       ( err_count             )  // output
    );

    assign err_count_wrong = err_first && (err_count !== err_count_stack[err_count_rd_pos*`BCH_ERR_SZ(P)+:`BCH_ERR_SZ(P)]);
    always @(posedge clk) begin
      if (err_first)
        err_count_rd_pos <= #TCQ (err_count_rd_pos + 1) % STACK_SZ;
    end

  end

  // Located inside bch_chien.v
  // Weird 1-bit thingy, what does it do?
  bch_chien_counter #(
    .P     ( P         ),
    .BITS  ( BITS      )
  ) bch_chien_counter_i0 (
    .clk   ( clk       ), // input
    .first ( err_first ), // input
    .last  ( err_last  ), // output
    .valid ( err_valid )  // output
  );

reg  err_done = 0;

wire err_wrong = err_done && (err_buf !== err_stack[err_rd_pos*B+:B]);
wire new_wrong = err_count_overflow || err_overflow || err_present_wrong || err_count_wrong || err_wrong;

always @(posedge clk) begin
  if (err_first) begin
    err_buf <= #TCQ reverse(err) << (`BCH_DATA_BITS(P) - BITS);
  end
  else if (err_valid) begin
    err_buf <= #TCQ (reverse(err) << (`BCH_DATA_BITS(P) - BITS)) | (err_buf >> BITS);
  end

  err_done <= #TCQ err_last;
  if (err_done) begin
    err_rd_pos <= #TCQ (err_rd_pos + 1) % STACK_SZ;
  end

  if (reset) begin
    wrong <= #TCQ 1'b0;
  end
  else if (new_wrong) begin
    wrong <= #TCQ 1'b1;
  end
end

endmodule
