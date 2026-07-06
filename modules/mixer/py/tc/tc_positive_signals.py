from __future__ import annotations

import cocotb

from tb.mix_env import MixEnv


@cocotb.test(timeout_time=50, timeout_unit="us")
async def tc_positive_signals(dut):
  env = MixEnv(dut)
  await env.start()

  await env.send_sample(
    data=[2.0, 2.0, 2.0, 2.0],
    gain=[1.0, 1.0, 1.0, 1.0],
    pan=[0.0, 0.25, 0.75, 1.0],
    output_gain=1.0,
  )
  await env.send_sample(
    data=[1.0, 1.5, 2.0, 2.5],
    gain=[1.25, 1.25, 1.25, 1.25],
    pan=[0.0, 0.5, 0.5, 1.0],
    output_gain=0.75,
  )
  await env.send_sample(
    data=[0.5, 1.0, 1.5, 2.0],
    gain=[0.8, 0.8, 0.8, 0.8],
    pan=[0.25, 0.5, 0.75, 1.0],
    output_gain=1.25,
  )

  await env.wait_for_compares(3)
  env.scoreboard.check()
