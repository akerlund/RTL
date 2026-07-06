from __future__ import annotations

import cocotb

from tb.fi_env import FiEnv


@cocotb.test(timeout_time=10, timeout_unit="ms")
async def tc_fi_stress_random(dut):
  env = FiEnv(dut, wp_period_ns=17.3, rp_period_ns=61.7)
  await env.start(wp_release_cycles=3, rp_release_cycles=11)
  env.start_random_reader(seed=0xA51F_0001)

  count = await env.write_counter_bursts(bursts=24, burst_len=17)
  await env.wait_for_compares(count, timeout_rp_cycles=12000)
  env.scoreboard.check(count)
