////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2022 Fredrik Åkerlund
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

module gf_div_bin_alg #(
    parameter int             M_P    = 8,
    parameter logic [M_P : 0] POLY_P = 'b100011011
  )(
    input  wire              clk,
    input  wire              rst_n,
    input  wire  [M_P-1 : 0] x0,
    input  wire  [M_P-1 : 0] x1,
    input  wire              x_valid,
    output logic             x_ready,
    output logic [M_P-1 : 0] y,
    output logic             y_valid
  );

  localparam int M      = M_P;
  localparam int LOGM_C = $clog2(M_P) + 1; // With sign bit

  logic        [M : 0] a;
  logic      [M-1 : 0] b;
  logic      [M-1 : 0] c;
  logic      [M-1 : 0] d;
  logic      [M-1 : 0] next_b;
  logic      [M-1 : 0] next_d;
  logic [LOGM_C-1 : 0] alpha;
  logic [LOGM_C-1 : 0] beta;
  logic [LOGM_C-1 : 0] next_beta;
  logic [LOGM_C-1 : 0] dec_input;
  logic                ce_ac;
  logic                ce_bd;
  logic                load;
  logic                beta_non_negative;
  logic                alpha_gt_beta;
  logic                b_zero;

  logic done;
  logic start;
  assign start = x_valid;


  typedef enum logic [2 : 0] {
    STATE_0_E,
    STATE_2_E,
    STATE_3_E,
    STATE_4_E
  } state_t;

  state_t state_now;
  state_t state_next;

  genvar i;
  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  //always_comb begin: first_iteration
  //  next_b = '0;
  generate
    for (i = 0; i < M-1; i++) begin
      assign next_b[i] = (b[0] & (b[i+1] ^ a[i+1])) | (!b[0] & b[i+1]);
    end
  endgenerate
  assign next_b[M-1] = b[0] & a[M];
  //end

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  //always_comb begin: second_iteration
  //  next_d = '0;
  generate
    for (i = 0; i < M-1; i++) begin
      assign next_d[i] = (POLY_P[i+1] & next_d[M-1]) ^ ((b[0] & (d[i+1] ^ c[i+1])) | (!b[0] & d[i+1]));
    end
  endgenerate
  assign next_d[M-1] = (b[0] & (d[0] ^ c[0])) | (!b[0] & d[0]);
  //end

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  always_ff @ (posedge clk or negedge rst_n) begin: registers_ac
    if (!rst_n) begin
      a <= '0;
      c <= '0;
    end
    else begin
      if (load) begin
        a <= POLY_P;
        c <= '0;
      end
      else if (ce_ac) begin
        a <= {'0, b};
        c <= d;
      end
    end
  end

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  always_ff @ (posedge clk or negedge rst_n) begin: registers_bd
    if (!rst_n) begin
      b <= '0;
      d <= '0;
    end
    else begin
      if (load) begin
        b <= x1;
        d <= x0;
      end
      else if (ce_bd) begin
        b <= next_b;
        d <= next_d;
      end
    end
  end

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  always_ff @ (posedge clk or negedge rst_n) begin: register_alpha
    if (!rst_n) begin
      alpha <= '0;
    end
    else begin
      if (load) begin
        alpha <= M;
      end
      else if (ce_ac) begin
        alpha <= beta;
      end
    end
  end

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------

  // always_comb begin
  //   dec_input = '0;
  //   if (!ce_ac) begin
  //     dec_input = beta;
  //   end
  //   else begin
  //     dec_input = alpha;
  //   end
  //   next_beta = dec_input - 1;
  // end

  assign dec_input = ce_ac ? alpha : beta;
  assign next_beta = dec_input - 1;

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  always_ff @ (posedge clk or negedge rst_n) begin: register_beta
    if (!rst_n) begin
      beta <= '0;
    end
    else begin
      if (load) begin
        beta <= M - 1;
      end
      else if (ce_bd) begin
        beta <= next_beta;
      end
    end
  end

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------

  assign y                 = c;
  assign beta_non_negative = beta[LOGM_C-1] ? '0 : '1;
  assign alpha_gt_beta     = alpha > beta   ? '1 : '0;
  assign b_zero            = b[0]           ? '0 : '1;

  always_ff @ (posedge clk or negedge rst_n) begin: control_unit
    if (!rst_n) begin
      state_now <= STATE_0_E;
    end
    else begin
      state_now <= state_next;
    end
  end

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------

  always_comb begin

    x_ready = '0;
    y_valid = '0;
    ce_ac   = '0;
    ce_bd   = '0;
    load    = '0;
    done    = '0;
    state_next = state_now;

    case (state_now)

      STATE_0_E: begin
        x_ready = '1;
        ce_ac   = '0;
        ce_bd   = '0;
        load    = '0;
        done    = '1;
        if (start) begin
          state_next = STATE_2_E;
        end
      end

      STATE_2_E: begin
        x_ready = '0;
        ce_ac = '0;
        ce_bd = '0;
        load  = '1;
        done  = '0;
        state_next = STATE_3_E;
      end


      STATE_3_E: begin
        load = '0;
        done = '0;
        if (!beta_non_negative) begin
          state_next = STATE_4_E;
          ce_ac = '0;
          ce_bd = '0;
        end
        else if (b_zero) begin
          ce_ac = '0;
          ce_bd = '1;
        end
        else if (alpha_gt_beta) begin
          ce_ac = '1;
          ce_bd = '1;
        end
        else begin
          ce_ac = '0;
          ce_bd = '1;
        end
      end

      STATE_4_E: begin
        state_next = STATE_0_E;
        ce_ac   = '0;
        ce_bd   = '0;
        load    = '0;
        done    = '0;
        y_valid = '1;
      end
    endcase

    // if (state_now == STATE_0_E || state_now == STATE_1_E) begin
    //   x_ready = '1;
    //   ce_ac   = '0;
    //   ce_bd   = '0;
    //   load    = '0;
    //   done    = '1;
    //   if (start) begin
    //     x_ready = '0;
    //     state_next = STATE_2_E;
    //   end
    // end

    // else if (state_now == STATE_2_E) begin
    //   ce_ac = '0;
    //   ce_bd = '0;
    //   load  = '1;
    //   done  = '0;
    //   state_next = STATE_3_E;
    // end


    // else if (state_now == STATE_3_E) begin
    //   load = '0;
    //   done = '0;
    //   if (!beta_non_negative) begin
    //     state_next = STATE_4_E;
    //     ce_ac = '0;
    //     ce_bd = '0;
    //   end
    //   else if (b_zero) begin
    //     ce_ac = '0;
    //     ce_bd = '1;
    //   end
    //   else if (alpha_gt_beta) begin
    //     ce_ac = '1;
    //     ce_bd = '1;
    //   end
    //   else begin
    //     ce_ac = '0;
    //     ce_bd = '1;
    //   end
    // end

    // else begin
    //   state_next = STATE_0_E;
    //   ce_ac   = '0;
    //   ce_bd   = '0;
    //   load    = '0;
    //   done    = '0;
    //   y_valid = '1;
    // end
  end

endmodule

`default_nettype wire
