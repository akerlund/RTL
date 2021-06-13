////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module mixer_core #(
    parameter int AUDIO_WIDTH_P    = -1,
    parameter int NR_OF_CHANNELS_P = -1,
    parameter int Q_BITS_P         = -1
  )(
    // Clock and reset
    input  wire                                                       clk,
    input  wire                                                       rst_n,

    // Ingress
    input  wire signed [NR_OF_CHANNELS_P-1 : 0] [AUDIO_WIDTH_P-1 : 0] channel_data,
    input  wire                                                       channel_valid,
    output logic                                                      channel_ready,

    // Egress
    output logic signed                         [AUDIO_WIDTH_P-1 : 0] out_left,
    output logic signed                         [AUDIO_WIDTH_P-1 : 0] out_right,
    output logic                                                      out_valid,

    // Registers
    input  wire        [NR_OF_CHANNELS_P-1 : 0] [AUDIO_WIDTH_P-1 : 0] cr_mix_channel_gain,
    input  wire        [NR_OF_CHANNELS_P-1 : 0] [AUDIO_WIDTH_P-1 : 0] cr_mix_channel_pan,
    input  wire                                 [AUDIO_WIDTH_P-1 : 0] cr_mix_output_gain,
    output logic                                               [1: 0] sr_mix_out_clip,
    output logic                             [NR_OF_CHANNELS_P-1 : 0] sr_mix_channel_clip
  );

  genvar i;

  localparam int NR_OF_MASTERS_P = NR_OF_CHANNELS_P;
  localparam int ID_WIDTH_C      = $clog2(NR_OF_MASTERS_P);


  typedef enum {
    WAIT_FOR_CHANNEL_E,
    FINISH_GAIN_E,
    FINISH_PAN_E,
    FINISH_SUM_E,
    FINAL_GAIN_E
  } mixer_state_t;

  mixer_state_t mixer_state;


  // Connections to the "arbiter_m2s"
  logic [NR_OF_MASTERS_P-1 : 0]                         m2s_mst_valid;
  logic [NR_OF_MASTERS_P-1 : 0]                         m2s_mst_ready;
  logic [NR_OF_MASTERS_P-1 : 0] [2*AUDIO_WIDTH_P-1 : 0] m2s_mst_data;
  logic [NR_OF_MASTERS_P-1 : 0]      [ID_WIDTH_C-1 : 0] m2s_mst_id;

  // Connections from the "arbiter_m2s" to "nq_multiplier_axi4s_if"
  logic                                                 m2s_slv_valid;
  logic                                                 m2s_slv_ready;
  logic                         [2*AUDIO_WIDTH_P-1 : 0] m2s_slv_data;
  logic                              [ID_WIDTH_C-1 : 0] m2s_slv_id;

  // Connections from the "nq_multiplier_axi4s_if" to "arbiter_s2m"
  logic                                                 s2m_slv_valid;
  logic                                                 s2m_slv_ready;
  logic                             [AUDIO_WIDTH_P : 0] s2m_slv_data;
  logic                              [ID_WIDTH_C-1 : 0] s2m_slv_id;

  // Connections from the "arbiter_m2s"
  logic   [NR_OF_MASTERS_P-1 : 0]                       s2m_mst_valid;
  logic   [NR_OF_MASTERS_P-1 : 0]                       s2m_mst_ready;
  logic                             [AUDIO_WIDTH_P : 0] s2m_mst_data;


  logic signed [NR_OF_CHANNELS_P-1 : 0] [AUDIO_WIDTH_P-1 : 0] channel_products;

  logic signed                            [AUDIO_WIDTH_P : 0] left_channel_sum_r0;
  logic signed                            [AUDIO_WIDTH_P : 0] right_channel_sum_r0;


  // Constant signals to the arbiters
  generate
    for (i = 0; i < NR_OF_MASTERS_P; i++) begin
      assign m2s_mst_id = i;
    end
  endgenerate


  // This process registers all input registers
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mixer_state         <= WAIT_FOR_CHANNEL_E;
      m2s_mst_valid       <= '0;
      m2s_mst_data        <= '0;
      channel_ready       <= '0;
      out_left            <= '0;
      out_right           <= '0;
      out_valid           <= '0;
      sr_mix_out_clip     <= '0;
      sr_mix_channel_clip <= '0;
    end
    else begin

      case (mixer_state)

        WAIT_FOR_CHANNEL_E: begin

          channel_ready <= '1;

          if (channel_valid) begin

            mixer_state                           <= FINISH_GAIN_E;
            channel_ready                         <= '0;
            m2s_mst_valid[NR_OF_CHANNELS_P-1 : 0] <= '1;
            s2m_mst_ready[NR_OF_CHANNELS_P-1 : 0] <= '1;

            for (int i = 0; i < NR_OF_CHANNELS_P; i++) begin
              m2s_mst_data[i] <= {channel_data[i], cr_mix_channel_gain[i]};
            end
          end
        end

        FINISH_GAIN_E: begin

          if (s2m_mst_ready == '0) begin

            mixer_state                           <= FINISH_PAN_E;
            m2s_mst_valid[NR_OF_CHANNELS_P-1 : 0] <= '1;
            s2m_mst_ready[NR_OF_CHANNELS_P-1 : 0] <= '1;

            for (int i = 0; i < NR_OF_CHANNELS_P; i++) begin
              m2s_mst_data[i] <= {channel_products[i], cr_mix_channel_pan[i]};
            end
          end
        end

        FINISH_PAN_E: begin
          if (s2m_mst_ready == '0) begin

            mixer_state <= FINAL_GAIN_E;

            //
            m2s_mst_valid[1 : 0] <= '1;
            s2m_mst_ready[1 : 0] <= '1;
            m2s_mst_data[0]      <= {left_channel_sum_r0[AUDIO_WIDTH_P-1 : 0],  cr_mix_output_gain};
            m2s_mst_data[1]      <= {right_channel_sum_r0[AUDIO_WIDTH_P-1 : 0], cr_mix_output_gain};
          end
        end

        FINAL_GAIN_E: begin

          // Output clip
          if (s2m_mst_valid[0] && s2m_mst_ready[0]) begin
            sr_mix_out_clip[0] <= s2m_mst_data[AUDIO_WIDTH_P];
          end

          // Output clip
          if (s2m_mst_valid[1] && s2m_mst_ready[1]) begin
            sr_mix_out_clip[1] <= s2m_mst_data[AUDIO_WIDTH_P];
          end

          // All ready?
          if (s2m_mst_ready == '0) begin

            mixer_state   <= WAIT_FOR_CHANNEL_E;
            channel_ready <= '1;
            out_left      <= channel_products[0];
            out_right     <= channel_products[1];
            out_valid     <= '1;
          end
        end

      endcase

      // The arbiter input and output
      for (int i = 0; i < NR_OF_MASTERS_P; i++) begin

        // Set valid low if data is handshaked
        if (m2s_mst_valid[i] && m2s_mst_ready[i]) begin
          m2s_mst_valid[i] <= '0;
        end

        // Set ready low if data is received
        if (s2m_mst_valid[i] && s2m_mst_ready[i]) begin

          s2m_mst_ready[i]    <= '0;
          channel_products[i] <= s2m_mst_data[AUDIO_WIDTH_P-1 : 0];

          if (mixer_state == FINISH_GAIN_E) begin
            sr_mix_channel_clip[i] <= s2m_mst_data[AUDIO_WIDTH_P];
          end
        end
      end
    end
  end


  // This process registers the multiplier's product and forwards to the arbiter
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s2m_slv_valid <= '0;
      s2m_slv_data  <= '0;
      s2m_slv_id    <= '0;
    end
    else begin

      // Registering the ID of the first arbiter, used to route the product back again
      if (m2s_slv_valid && m2s_slv_ready) begin
        s2m_slv_id <= m2s_slv_id;
      end

      // Registering the product
      if (mul_egr_valid) begin
        s2m_slv_valid <= '1;
        s2m_slv_data  <= {mul_egr_overflow, mul_egr_product};
      end

      // Handshaking to the second arbiter
      if (s2m_slv_valid && s2m_slv_ready) begin
        s2m_slv_valid <= '0;
      end

    end
  end


  // Summing up the products
  logic [AUDIO_WIDTH_P-1 : 0] m2s_slv_datad_d0;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      left_channel_sum_r0  <= '0;
      right_channel_sum_r0 <= '0;
      m2s_slv_datad_d0     <= '0;
    end
    else begin

      if (mixer_state != FINISH_PAN_E) begin
        left_channel_sum_r0  <= '0;
        right_channel_sum_r0 <= '0;
      end
      else begin

        // Save the signal as it is pre-gain
        if (m2s_slv_valid && m2s_slv_ready) begin
          m2s_slv_datad_d0 <= ing_multiplicand_c0;
        end

        // Add the products to the sums when the Master handshakes
        if ((|s2m_mst_valid) && (|s2m_mst_ready)) begin
          left_channel_sum_r0  <= left_channel_sum_r0  + ing_multiplicand_c0;
          right_channel_sum_r0 <= right_channel_sum_r0 + (m2s_slv_datad_d0 - ing_multiplicand_c0);
        end

      end

    end
  end


  // Input channel gain
  arbiter_m2s #(
    .NR_OF_MASTERS_P ( NR_OF_MASTERS_P ),
    .DATA_WIDTH_P    ( 2*AUDIO_WIDTH_P ),
    .ID_WIDTH_P      ( ID_WIDTH_C      )
  ) arbiter_m2s_i0 (

    .clk             ( clk             ), // input
    .rst_n           ( rst_n           ), // input

    .mst_valid       ( m2s_mst_valid   ), // input
    .mst_ready       ( m2s_mst_ready   ), // output
    .mst_data        ( m2s_mst_data    ), // input
    .mst_last        ( '1              ), // input
    .mst_id          ( m2s_mst_id      ), // input

    .slv_valid       ( m2s_slv_valid   ), // output
    .slv_ready       ( m2s_slv_ready   ), // input
    .slv_data        ( m2s_slv_data    ), // output
    .slv_last        (                 ), // output
    .slv_id          ( m2s_slv_id      )  // output
  );


  logic                       mul_egr_valid;
  logic [AUDIO_WIDTH_P-1 : 0] mul_egr_product;
  logic                       mul_egr_overflow;

  // Splitting the arbited data channel
  logic [AUDIO_WIDTH_P-1 : 0] ing_multiplicand_c0;
  logic [AUDIO_WIDTH_P-1 : 0] ing_multiplier_c0;
  assign ing_multiplicand_c0 = m2s_slv_data[AUDIO_WIDTH_P-1 : 0];
  assign ing_multiplier_c0   = m2s_slv_data[2*AUDIO_WIDTH_P-1 : AUDIO_WIDTH_P];


  nq_multiplier #(
    .N_BITS_P         ( AUDIO_WIDTH_P       ),
    .Q_BITS_P         ( Q_BITS_P            )
  ) nq_multiplier_i0 (
    .clk              ( clk                 ), // input
    .rst_n            ( rst_n               ), // input
    .ing_valid        ( m2s_slv_valid       ), // input
    .ing_ready        ( m2s_slv_ready       ), // output
    .ing_multiplicand ( ing_multiplicand_c0 ), // input
    .ing_multiplier   ( ing_multiplier_c0   ), // input
    .egr_valid        ( mul_egr_valid       ), // output
    .egr_product      ( mul_egr_product     ), // output
    .egr_overflow     ( mul_egr_overflow    )  // output
  );



  arbiter_s2m #(
    .NR_OF_MASTERS_P ( NR_OF_MASTERS_P ),
    .DATA_WIDTH_P    ( AUDIO_WIDTH_P+1 ),
    .ID_WIDTH_P      ( ID_WIDTH_C      )
  ) arbiter_s2m_i0 (

    .clk             ( clk             ), // input
    .rst_n           ( rst_n           ), // input

    .slv_valid       ( s2m_slv_valid   ), // input
    .slv_ready       ( s2m_slv_ready   ), // output
    .slv_data        ( s2m_slv_data    ), // input
    .slv_last        ( '1              ), // input
    .slv_id          ( s2m_slv_id      ), // input

    .mst_valid       ( s2m_mst_valid   ), // output
    .mst_ready       ( s2m_mst_ready   ), // input
    .mst_data        ( s2m_mst_data    ), // output
    .mst_last        (                 ), // output
    .mst_id          (                 )  // output
  );

endmodule

`default_nettype wire
