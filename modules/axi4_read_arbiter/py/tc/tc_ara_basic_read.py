import cocotb

from tb.ara_env import AraEnv


@cocotb.test()
async def tc_ara_basic_read(dut):
  env = AraEnv(dut)
  await env.start()

  env.drive_read_request(master=0, arid=3, addr=0x1200, length=0)
  await env.wait_address_forwarded(master=0)
  assert int(dut.slv_arid.value) == 3
  assert int(dut.slv_araddr.value) == 0x1200
  await env.accept_address(master=0)
  await env.send_read_data_with_stall(master=0, rid=3, data=0xCAFE_1000)

  env.drive_read_request(master=2, arid=7, addr=0x2200, length=0)
  await env.wait_address_forwarded(master=2)
  assert int(dut.slv_arid.value) == 7
  assert int(dut.slv_araddr.value) == 0x2200
  await env.accept_address(master=2)
  await env.send_read_data_with_stall(master=2, rid=7, data=0xCAFE_2000)
