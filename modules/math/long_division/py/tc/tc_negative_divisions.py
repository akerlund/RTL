import cocotb

from tb.div_env import DivEnv, divide_ref, to_unsigned


@cocotb.test()
async def tc_negative_divisions(dut):
  env = DivEnv(dut)
  await env.start()

  cases = [(-3 << 15, 2 << 15), (7 << 15, -4 << 15), (-12345, -3333), (-1 << 20, 1 << 18)]
  for idx, (dividend, divisor) in enumerate(cases):
    quotient, overflow, tid = await env.divide(to_unsigned(dividend), to_unsigned(divisor), idx)
    exp_quotient, exp_overflow = divide_ref(dividend, divisor)
    assert tid == idx
    assert overflow == exp_overflow
    assert quotient == exp_quotient
