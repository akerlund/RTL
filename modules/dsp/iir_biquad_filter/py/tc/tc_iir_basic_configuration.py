from __future__ import annotations

import cocotb

from tb.iir_env import IirEnv


@cocotb.test(timeout_time=500, timeout_unit="us")
async def tc_iir_basic_configuration(dut):
  env = IirEnv(dut)
  await env.start()
  env.configure(f0=500, fs=64000, q=1, iir_type=0, bypass=0)
  await env.wait_for_coefficients()
