from __future__ import annotations

import cocotb

from tb.iir_env import DirectFormIModel, IirEnv, fixed


@cocotb.test(timeout_time=500, timeout_unit="us")
async def tc_iir_coefficient_check(dut):
  env = IirEnv(dut)
  await env.start()
  env.configure(f0=500, fs=64000, q=1, iir_type=0, bypass=0)
  await env.wait_for_coefficients()

  assert int(dut.sr_w0.value) != 0
  assert int(dut.sr_alfa.value) != 0
  assert int(dut.sr_pole_a0.value) != 0

  model = DirectFormIModel(
    int(dut.sr_zero_b0.value),
    int(dut.sr_zero_b1.value),
    int(dut.sr_zero_b2.value),
    int(dut.sr_pole_a1.value),
    int(dut.sr_pole_a2.value),
  )

  for sample in (fixed(0.125), fixed(-0.0625), fixed(0.03125), 0, fixed(0.015625)):
    observed = await env.send_sample(sample)
    expected = model.step(sample)
    assert abs(observed - expected) <= 1, (
      f"IIR model mismatch: observed {observed}, expected {expected}")
