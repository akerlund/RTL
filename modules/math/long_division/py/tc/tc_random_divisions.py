import random

import cocotb

from tb.div_env import DivEnv, divide_ref, to_unsigned


@cocotb.test()
async def tc_random_divisions(dut):
  env = DivEnv(dut)
  await env.start()
  rng = random.Random(42)

  for idx in range(100):
    dividend = rng.randint(-(1 << 22), (1 << 22) - 1)
    divisor = rng.randint(-(1 << 18), (1 << 18) - 1) or 1
    quotient, overflow, _ = await env.divide(to_unsigned(dividend), to_unsigned(divisor), idx & 0xF)
    exp_quotient, exp_overflow = divide_ref(dividend, divisor)
    assert overflow == exp_overflow
    assert quotient == exp_quotient
