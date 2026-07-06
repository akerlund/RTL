from __future__ import annotations

import random

import cocotb

from tb.mix_env import MixEnv


@cocotb.test(timeout_time=100, timeout_unit="us")
async def tc_random_signals(dut):
  random.seed(0x41C0_0004)
  env = MixEnv(dut)
  await env.start()

  for _ in range(10):
    data = [random.uniform(-2.0, 2.0) for _ in range(4)]
    gain = [random.uniform(0.0, 1.5) for _ in range(4)]
    await env.send_sample(
      data=data,
      gain=gain,
      pan=[random.uniform(0.0, 1.0) for _ in range(4)],
      output_gain=random.uniform(0.25, 1.25),
    )

  await env.wait_for_compares(10)
  env.scoreboard.check()
