import cocotb

from tb.div_env import DivEnv, divide_ref


@cocotb.test()
async def tc_overflow_divisions(dut):
  env = DivEnv(dut)
  await env.start()

  cases = [(1 << 22, 1), (1 << 20, 0), ((1 << 23) - 1, 2)]
  for idx, (dividend, divisor) in enumerate(cases):
    quotient, overflow, _ = await env.divide(dividend, divisor, idx)
    exp_quotient, exp_overflow = divide_ref(dividend, divisor)
    assert overflow == exp_overflow
    assert quotient == exp_quotient
