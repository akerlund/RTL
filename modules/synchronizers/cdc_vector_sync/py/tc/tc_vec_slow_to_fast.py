from __future__ import annotations

import cocotb

from tc.vec_test_lib import run_vec_test


@cocotb.test(timeout_time=2, timeout_unit="ms")
async def tc_vec_slow_to_fast(dut):
  await run_vec_test(dut, clk0_period_ns=6.0, clk1_period_ns=10.0)
