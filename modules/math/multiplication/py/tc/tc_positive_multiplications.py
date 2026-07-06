import cocotb

from tb.mul_env import MulEnv, multiply_ref


@cocotb.test()
async def tc_positive_multiplications(dut):
  env = MulEnv(dut)
  await env.start()

  cases = [(1 << 11, 2 << 11), (3 << 11, 4 << 11), (12345, 3333), (1 << 20, 1 << 18)]
  for idx, (lhs, rhs) in enumerate(cases):
    product, overflow, tid = await env.multiply(lhs, rhs, idx)
    exp_product, exp_overflow = multiply_ref(lhs, rhs)
    assert tid == idx
    assert overflow == exp_overflow
    assert product == exp_product
