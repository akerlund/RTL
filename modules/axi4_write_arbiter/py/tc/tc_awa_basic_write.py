import cocotb

from tb.awa_env import AwaEnv


@cocotb.test()
async def tc_awa_basic_write(dut):
  env = AwaEnv(dut)
  await env.start()

  env.drive_write_address(master=0, awid=2, addr=0x3100)
  await env.wait_address_forwarded()
  assert int(dut.slv_awid.value) == 2
  assert int(dut.slv_awaddr.value) == 0x3100
  await env.accept_address(master=0)
  await env.send_write_data(master=0, data=0xA5A5_0001)
  await env.send_response(master=0, bid=2)

  env.drive_write_address(master=3, awid=9, addr=0x4300)
  await env.wait_address_forwarded()
  assert int(dut.slv_awid.value) == 9
  assert int(dut.slv_awaddr.value) == 0x4300
  await env.accept_address(master=3)
  await env.send_write_data(master=3, data=0xA5A5_0003)
  await env.send_response(master=3, bid=9)
