from __future__ import annotations

import cocotb

from tc.fi_test_lib import run_fi_test


@cocotb.test(timeout_time=5, timeout_unit="ms")
async def tc_fi_fast_to_slow(dut):
  await run_fi_test(dut, wp_period_ns=9.0, rp_period_ns=200.0, bursts=8, burst_len=16)
