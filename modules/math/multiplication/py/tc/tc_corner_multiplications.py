import cocotb

from tb.mul_env import MulEnv, multiply_ref, to_unsigned


@cocotb.test()
async def tc_corner_multiplications(dut):
  env = MulEnv(dut)
  await env.start()

  cases = [
    (0, (1 << 11)),
    ((1 << 11), 0),
    ((1 << 31) - 1, (1 << 11)),
    (to_unsigned(-1 << 11), to_unsigned(1 << 11)),
    (to_unsigned(-1 << 11), to_unsigned(-1 << 11)),
    ((1 << 31) - 1, (1 << 31) - 1),
  ]
  for idx, (lhs, rhs) in enumerate(cases):
    product, overflow, tid = await env.multiply(lhs, rhs, idx)
    exp_product, exp_overflow = multiply_ref(lhs, rhs)
    assert tid == idx
    assert overflow == exp_overflow
    assert product == exp_product
