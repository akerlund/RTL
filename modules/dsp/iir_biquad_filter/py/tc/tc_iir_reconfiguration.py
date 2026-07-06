from __future__ import annotations

import cocotb

from tb.iir_env import IirEnv, fixed


@cocotb.test(timeout_time=1, timeout_unit="ms")
async def tc_iir_reconfiguration(dut):
  env = IirEnv(dut)
  await env.start()

  env.configure(f0=3000, fs=64000, q=1, iir_type=0, bypass=0)
  await env.wait_for_coefficients()
  first_w0 = int(dut.sr_w0.value)

  env.configure(f0=1000, fs=64000, q=1, iir_type=0, bypass=0)
  await env.wait_for_coefficients()
  assert int(dut.sr_w0.value) != first_w0

  env.configure(f0=1000, fs=64000, q=1, iir_type=0, bypass=1)
  observed = await env.send_sample(-0.25)
  assert observed == fixed(-0.25)
