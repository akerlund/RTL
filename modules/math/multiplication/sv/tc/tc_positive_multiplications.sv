////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

class tc_positive_multiplications extends mul_base_test;

  `uvm_component_utils(tc_positive_multiplications)

  function new(string name = "tc_positive_multiplications", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    multiplications = 100000;
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    for (int i = 0; i < multiplications; i++) begin
      if (i % 1000 == 0) begin
        `uvm_info(get_type_name(), $sformatf("Multiplication (%0d/%0d)", i, multiplications), UVM_LOW)
      end
      multiplicand = $urandom_range(0, 2**((N_BITS_C-Q_BITS_C)/2)-1);
      multiplier   = $urandom_range(0, 2**((N_BITS_C-Q_BITS_C)/2)-1);
      custom_data.push_back(multiplicand);
      custom_data.push_back(multiplier);
      vip_axi4s_seq0.set_custom_data(custom_data);
      vip_axi4s_seq0.start(v_sqr.mst_sequencer);
      custom_data.delete();
    end

    phase.drop_objection(this);

  endtask

endclass
