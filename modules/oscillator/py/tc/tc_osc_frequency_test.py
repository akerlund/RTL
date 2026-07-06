from __future__ import annotations

import cocotb

from tb.osc_env import OscEnv


@cocotb.test(timeout_time=200, timeout_unit="us")
async def tc_osc_frequency_test(dut):
  env = OscEnv(dut)
  await env.start()

  for frequency, duty in ((500, 250), (4000, 200), (3000, 100), (2000, 750), (1000, 800)):
    env.configure(waveform=0, frequency_hz=frequency, duty=duty)
    await env.wait_for_activity()
