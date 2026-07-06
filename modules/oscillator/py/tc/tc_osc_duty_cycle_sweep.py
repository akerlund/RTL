from __future__ import annotations

import cocotb

from tb.osc_env import OscEnv


@cocotb.test(timeout_time=200, timeout_unit="us")
async def tc_osc_duty_cycle_sweep(dut):
  env = OscEnv(dut)
  await env.start()

  for duty in (1, 100, 250, 500, 750, 999, 1200, 0):
    env.configure(waveform=0, frequency_hz=1000, duty=duty)
    values = await env.collect(3000)
    assert max(values) > 0, f"Duty {duty} never produced a positive square phase"
    assert min(values) < 0, f"Duty {duty} never produced a negative square phase"
