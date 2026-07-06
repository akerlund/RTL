from __future__ import annotations

from tb.vec_env import VecEnv


async def run_vec_test(dut, clk0_period_ns: float, clk1_period_ns: float,
                       bursts: int = 16, burst_len: int = 16) -> None:
  env = VecEnv(dut, clk0_period_ns=clk0_period_ns, clk1_period_ns=clk1_period_ns)
  await env.start()
  count = await env.send_counter_bursts(bursts=bursts, burst_len=burst_len)
  await env.wait_for_compares(count, timeout_clk0_cycles=max(4000, count * 40))
  env.scoreboard.check(count)
