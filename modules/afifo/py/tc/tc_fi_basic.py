from __future__ import annotations

import cocotb

from tc.fi_test_lib import run_fi_test


@cocotb.test(timeout_time=1, timeout_unit="ms")
async def tc_fi_basic(dut):
  await run_fi_test(dut, wp_period_ns=10.0, rp_period_ns=10.0)
