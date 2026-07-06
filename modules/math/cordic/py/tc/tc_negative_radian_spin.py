import math

import cocotb

from tb.cordic_env import CordicEnv, check_angle


@cocotb.test()
async def tc_negative_radian_spin(dut):
  env = CordicEnv(dut)
  await env.start()

  for tid, degrees in enumerate(range(0, 360, 5)):
    angle = -math.radians(degrees)
    sine, cosine, got_tid = await env.send_angle(angle, tid & 0xF)
    assert got_tid == (tid & 0xF)
    check_angle(angle, sine, cosine)
