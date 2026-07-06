import random

import cocotb

from tb.mul_env import MulEnv, multiply_ref, to_unsigned


@cocotb.test()
async def tc_random_multiplications(dut):
  env = MulEnv(dut)
  await env.start()
  rng = random.Random(73)

  for idx in range(100):
    lhs = rng.randint(-(1 << 21), (1 << 21) - 1)
    rhs = rng.randint(-(1 << 21), (1 << 21) - 1)
    product, overflow, _ = await env.multiply(to_unsigned(lhs), to_unsigned(rhs), idx & 0xF)
    exp_product, exp_overflow = multiply_ref(lhs, rhs)
    assert overflow == exp_overflow
    assert product == exp_product
