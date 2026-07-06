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

class tc_fi_slow_to_fast extends tc_fi_basic;

  `uvm_component_utils(tc_fi_slow_to_fast)

  function new(string name = "tc_fi_slow_to_fast", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    clk_rst_config0.clock_period = 333.3; // 3MHz
    clk_rst_config1.clock_period = 58.8;  // 17MHz
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass
