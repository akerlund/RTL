from __future__ import annotations

import cocotb

from tb.fi_env import FiEnv


@cocotb.test(timeout_time=10, timeout_unit="ms")
async def tc_fi_reset_traffic(dut):
  env = FiEnv(dut, wp_period_ns=13.0, rp_period_ns=47.0)
  await env.start(wp_release_cycles=2, rp_release_cycles=19)

  first_count = await env.write_counter_bursts(bursts=2, burst_len=8)
  await env.wait_for_compares(first_count, timeout_rp_cycles=1000)
  env.scoreboard.check(first_count)

  await env.reset(wp_release_cycles=17, rp_release_cycles=4)

  second_count = await env.write_counter_bursts(bursts=4, burst_len=8)
  await env.wait_for_compares(second_count, timeout_rp_cycles=2000)
  env.scoreboard.check(second_count)
