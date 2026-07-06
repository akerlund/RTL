from __future__ import annotations

from tb.fi_env import FiEnv


async def run_fi_test(dut, wp_period_ns: float, rp_period_ns: float, bursts: int = 16,
                      burst_len: int = 32) -> None:
  env = FiEnv(dut, wp_period_ns=wp_period_ns, rp_period_ns=rp_period_ns)
  await env.start()
  count = await env.write_counter_bursts(bursts=bursts, burst_len=burst_len)
  await env.wait_for_compares(count, timeout_rp_cycles=max(2000, count * 20))
  env.scoreboard.check(count)
